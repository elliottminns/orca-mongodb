import Orca
import Foundation
import PureJsonSerializer

extension Json {
    init(_ dataType: DataType) {
        switch dataType.dynamicType.valueType {
        case .Double:
             self.init(dataType as! Double)            
        case .Int:
             self.init(Double(dataType as! Int))
        case .Float:
            self.init(dataType as! Double)            
        case .String:
            self.init(dataType as! String)
        case .Bool:
            self.init(dataType as! Bool)
        }
    }
}

public class OrcaMongoDB {

    let database: MongoDB

    public init() {
        database = MongoDB()
    }

    public func connect(host host: String, port: Int, database: String,
        handler: (error: ErrorType?) -> ()) {
        self.database.connect(host: host, port: port, database: database,
            handler: handler)
    }

    func dataTypeFromJson(json: [String: Json], 
        forSchema schema: [String: DataType.Type]) -> [String: DataType] {
            var values = [String: DataType]()

            for (key, value) in json {

                if let object = value.objectValue {
                    //values += dataTypeFromJson(object)
                    if let identifier = object["$oid"]?.stringValue {
                        values[key] = identifier
                    }

                } else if let type = schema[key] {
                    let v: DataType?

                    switch type.valueType {
                    case .Double:
                        v = value.doubleValue
                    case .Int:
                        v = value.intValue
                    case .Bool:
                        v = value.boolValue
                    case .Float:
                        v = value.floatValue
                    case .String:
                        v = value.stringValue
                    }
                    values[key] = v
                }
            }

            return values

    }

    func dataTypeFromDocument(document: MongoDocument,
        forSchema schema: [String: DataType.Type]) -> [String: DataType] {

            guard let data = document.data.objectValue else { return [:] }

            let dataTypes = dataTypeFromJson(data, forSchema: schema)

            return dataTypes
    }

    func mongoDBDocumentData(data: [String: DataType]) -> Json {
        guard let identifier = data["identifier"] as? String else {
            return [:]
        }

        var converted = [String: Json]()

        for (key, value) in data {
            converted[key] = Json(value)
        }

        converted["_id"] = Json(["$oid": Json(identifier)])
        converted["identifier"] = nil
        return Json(converted)
    }

    func parseFiltersToDocument(filters filters: [Filter]) throws
        -> Json {

        var identifier: String? = nil

        for filter in filters {
            if let filter = filter as? CompareFilter {
                if filter.key == "identifier" {
                    identifier = filter.value.toString()
                }
            }
        }

        guard let id = identifier else {
            throw DriverError.NotFound
        }

        return Json(["_id": Json(["$oid": Json(id)])])
    }
}

extension OrcaMongoDB: Driver {

    public func generateUniqueIdentifier() -> String {
        return MongoDocument.generateObjectId()
    }

    public func findOne(collection collection: String, filters: [Filter],
            schema: [String: DataType.Type]) throws -> [String: DataType] {

            guard let database = database.database else {
                throw DriverError.NotFound
            }

            let query = try parseFiltersToDocument(filters: filters)

            let collection = MongoCollection(name: collection,
                database: database)

            if let document = try collection.findOne(query) {
                let dataType = dataTypeFromDocument(document,
                    forSchema: schema)
                return dataType
            } else {
                throw DriverError.NotFound
            }
    }

    public func find(collection collection: String, filters: [Filter],
        schema: [String: DataType.Type]) throws -> [[String: DataType]] {

            guard let database = database.database else {
                throw DriverError.NotFound
            }

            let collection = MongoCollection(name: collection,
                database: database)


            let documents = try collection.find()

            var models = [[String: DataType]]()
            for document in documents {
                let model = dataTypeFromDocument(document,
                    forSchema: schema)
                models.append(model)
            }

            return models

    }

    public func update(collection collection: String, filters: [Filter],
        data: [String: DataType], schema: [String: DataType.Type]) throws {

            guard let database = database.database else {
                throw DriverError.NotFound
            }

            let collection = MongoCollection(name: collection,
                database: database)

            let query = try parseFiltersToDocument(filters: filters)
            let updateData = mongoDBDocumentData(data)
            try collection.update(query, newValue: updateData)
    }

    public func insert(collection collection: String,
        data: [String: DataType], model: Model) throws {

            guard let database = database.database else {
                throw DriverError.NotFound
            }

            let converted = mongoDBDocumentData(data)

            let collection = MongoCollection(name: collection, database: database)

            let document = try MongoDocument(data: converted)

            try collection.insert(document)

    }

    public func delete(collection collection: String, filters: [Filter],
        schema: [String: DataType.Type]) throws {

        guard let database = database.database else {
            throw DriverError.NotFound
        }

        let collection = MongoCollection(name: collection,
            database: database)

        let query = try parseFiltersToDocument(filters: filters)

        try collection.remove(query)

    }

}
