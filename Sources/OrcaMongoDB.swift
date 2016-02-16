import Orca
import Foundation

public class OrcaMongoDB {

    let database: MongoDB

    init() {
        database = MongoDB()
    }

    public func connect(host host: String, port: Int, database: String,
        handler: (error: ErrorType?) -> ()) {
        self.database.connect(host: host, port: port, database: database,
            handler: handler)
    }

    func dataTypeFromDocument(document: MongoDocument,
        forSchema schema: [String: DataType.Type]) -> [String: DataType] {

            var dataTypes = [String: DataType]()

            for (key, object) in document.data {

                if let schemaType = schema[key] {
                    let value: DataType?
                    switch schemaType.valueType {
                        case .Double:
                            let num = object as? NSNumber
                            value = num?.doubleValue
                        case .Int:
                            let num = object as? NSNumber
                            value = num?.integerValue
                        case .Bool:
                            let num = object as? NSNumber
                            value = num?.boolValue
                        case .Float:
                            let num = object as? NSNumber
                            value = num?.floatValue
                        case .String:
                            let string = object as? NSString
                            value = String(string)
                    }

                    dataTypes[key] = value
                }

                let identifier = document.id
                dataTypes["identifier"] = identifier
            }

            return dataTypes
    }

    func mongoDBDocumentData(data: [String: DataType]) -> [String: Any] {
        guard let identifier = data["identifier"] as? String else {
            return [:]
        }
        var converted = [String: Any]()

        for (key, value) in data {
            converted[key] = value
        }

        converted["_id"] = ["$oid": identifier]
        converted["identifier"] = nil
        return converted
    }

    func parseFiltersToDocument(filters filters: [Filter]) throws
        -> [String: Any]  {
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

        return ["_id": ["$oid": id]]
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
