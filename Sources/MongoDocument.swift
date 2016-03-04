/*The MIT License (MIT)

Copyright (c) 2015 Dan Appel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
import PureJsonSerializer
import CBSON

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
