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
//  MongoBSON.swift
//  swiftMongoDB
//
//  Created by Dan Appel on 8/20/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import CBSON
import PureJsonSerializer

class MongoBSON {

    private var _bson: bson_t
    let json: String
    let data: Json
    var bson: bson_t {
        return bson_copy(&_bson).pointee// for safety
    }

    init(bson: bson_t) throws {

        self._bson = bson

        do {
            self.json = try MongoBSON.bsonToJson(bson)
        } catch {
            self.json = ""
            self.data = [:]
            throw error
        }

        do {
            self.data = try json.parseJSON()
        } catch {
            self.data = [:]
            throw error
        }
    }

    init(json: String) throws {

        self.json = json

        do {
            self.data = try self.json.parseJSON()
        } catch {
            self.data = [:]
            self._bson = bson_t()
            throw error
        }

        do {
            self._bson = try MongoBSON.jsonToBson(json)
        } catch {
            self._bson = bson_t()
            throw error
        }
    }

    init(data: DocumentData) throws {
        self.data = data

        let json = data.serialize()

        if json == "null" {
            self.json = "{}"
        } else {
            self.json = json
        }

        do {
            self._bson = try MongoBSON.jsonToBson(self.json)
        } catch {
            self._bson = bson_t()
            throw error
        }
    }

    static func bsonToJson(bson: bson_t) throws -> String {

        var bson = bson
        let jsonRaw = bson_as_json(&bson, nil)

        if jsonRaw == nil {
            throw MongoError.CorruptDocument
        }

        return String(utf8String: jsonRaw)!
    }

    static func jsonToBson(json: String) throws -> bson_t {

        var error = bson_error_t()
        let bson = bson_new_from_json(json, json.nulTerminatedUTF8.count, &error)
        try error.throwIfError()

        return bson.pointee
    }

    func copyTo(out: _bson_ptr_mutable) {
        var bson = self.bson
        bson_copy_to(&bson, out)
    }
}
