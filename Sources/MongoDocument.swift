import PureJsonSerializer

#if os(Linux)
import bsonLinux
#else
import bsonMac
#endif


class MongoDocument {

    let bson: bson_t

    var JSON: String? {
        return data.serialize()
    }

    var dataWithoutObjectId: DocumentData {
        var copy = self.data
        copy["_id"] = nil
        return copy
    }

    let data: DocumentData

    var id: String? {
        guard let data = self.data.objectValue, 
            let id = data["$oid"]?.stringValue else {
                return nil
        }

        return id
    }

    init(data: Json) throws {
        self.data = data

        do {
            self.bson = try MongoBSON(data: data).bson
        } catch {
            self.bson = bson_t()
            throw error
        }
    }

    convenience init(JSON: String) throws {

        let data = try JSON.parseJSON()

        try self.init(data: data)
    }

    static func generateObjectId() -> String {
        var oidRAW = bson_oid_t()

        bson_oid_init(&oidRAW, nil)


        let oidStrRAW = UnsafeMutablePointer<Int8>.alloc(100)
//        try to minimize this memory usage while retaining safety, reference:
//        4 bytes : The UNIX timestamp in big-endian format.
//        3 bytes : The first 3 bytes of MD5(hostname).
//        2 bytes : The pid_t of the current process. Alternatively the task-id if configured.
//        3 bytes : A 24-bit monotonic counter incrementing from rand() in big-endian.


        bson_oid_to_string(&oidRAW, oidStrRAW)

        let oidStr = String(UTF8String: oidStrRAW)

        oidStrRAW.destroy()

        return oidStr!
    }

    func generateObjectId() -> String {
        return self.dynamicType.generateObjectId()

    }

    deinit {
//        self.BSONRAW.destroy()
    }
}

import Foundation
func == (lhs: MongoDocument, rhs: MongoDocument) -> Bool {

    return (lhs.data == rhs.data)
}

func != (lhs: MongoDocument, rhs: MongoDocument) -> Bool {
    return !(lhs == rhs)
}

func != (lhs: DocumentData, rhs: DocumentData) -> Bool {
    return !(lhs == rhs)
}

