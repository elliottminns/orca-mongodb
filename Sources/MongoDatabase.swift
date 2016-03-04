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
//
//  MongoDatabase.swift
//  SwiftMongoDB
//
//  Created by Dan Appel on 11/23/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import CMongoC

class MongoDatabase {

    let databaseRaw: _mongoc_database

    init(client: MongoClient, name: String) {
        self.databaseRaw = mongoc_client_get_database(client.clientRaw, name)
    }

    // init(client: MongoClient) {
    //     self.databaseRaw = mongoc_client_get_default_database(client.clientRaw)
    // }

    var name: String {
        let nameRaw = mongoc_database_get_name(databaseRaw)
        return String(UTF8String: nameRaw)!
    }

    func removeUser(username: String) throws -> Bool {
        var error = bson_error_t()
        let successful = mongoc_database_remove_user(databaseRaw, username, &error)

        try error.throwIfError()

        return successful
    }

    func removeAllUsers() throws -> Bool {
        var error = bson_error_t()
        let successful = mongoc_database_remove_all_users(databaseRaw, &error)

        try error.throwIfError()

        return successful
    }

    func addUser(username username: String, password: String, roles: [String], customData: DocumentData) throws -> Bool {

        var error = bson_error_t()

        var rolesRaw = try MongoBSON(json: roles.toJSON()).bson
        var customDataRaw = try MongoBSON(data: customData).bson

        let successful = mongoc_database_add_user(databaseRaw, username, password, &rolesRaw, &customDataRaw, &error)

        try error.throwIfError()

        return successful
    }

    func command(command: DocumentData, flags: QueryFlags = .None, skip: Int = 0, limit: Int = 0, batchSize: Int = 0, fields: [String] = []) throws -> MongoCursor {

        var commandRaw = try MongoBSON(data: command).bson
        var fieldsRaw = try MongoBSON(json: fields.toJSON()).bson

        let cursorRaw = mongoc_database_command(databaseRaw, flags.rawFlag, skip.UInt32Value, limit.UInt32Value, batchSize.UInt32Value, &commandRaw, &fieldsRaw, nil)

        let cursor = MongoCursor(cursor: cursorRaw)

        return cursor
    }

    func drop() throws -> Bool {

        var error = bson_error_t()

        let successful = mongoc_database_drop(databaseRaw, &error)

        try error.throwIfError()

        return successful
    }

    func hasCollection(name: String) throws -> Bool {

        var error = bson_error_t()

        let successful = mongoc_database_has_collection(databaseRaw, name, &error)

        try error.throwIfError()

        return successful
    }

    func createCollection(name: String, options: DocumentData) throws -> MongoCollection {

        var error = bson_error_t()

        var optionsRaw = try MongoBSON(data: options).bson

        let collectionRaw = mongoc_database_create_collection(databaseRaw, name, &optionsRaw, &error)

        try error.throwIfError()

        let collection = MongoCollection(name: name, databaseName: self.name, ptr: collectionRaw)

        return collection
    }

//    func getReadPrefs() throws /* -> _mongoc_read_prefs */ {
////        _mongoc_read_prefs
//    }
//
//    func setReadPrefs(/*readPrefs: _mongoc_read_prefs*/) throws {
//
//    }
//
//    func getWriteConcern() throws /* _mongoc_write_concern */ {
//
//    }
//
//    func setWriteConcern(/*writeConcern: _mongoc_write_concern*/) throws {
//
//    }

    func findCollections(filter filter: DocumentData) throws -> MongoCursor {

        var error = bson_error_t()
        var filterRaw = try MongoBSON(data: filter).bson

        let cursorRaw = mongoc_database_find_collections(databaseRaw, &filterRaw, &error)

        try error.throwIfError()

        let cursor = MongoCursor(cursor: cursorRaw)

        return cursor
    }

    func getCollection(name: String) -> MongoCollection {


        let collectionRaw = mongoc_database_get_collection(databaseRaw, name)

        let collection = MongoCollection(name: name, databaseName: self.name, ptr: collectionRaw)

        return collection
    }

    func getCollectionNames() throws -> [String] {

        var error = bson_error_t()

        let namesRaw = mongoc_database_get_collection_names(databaseRaw, &error)

        try error.throwIfError()

        let names = namesRaw.sequence()!
            .map { String(UTF8String: $0) }
            .flatMap { $0 }

        return names
    }

    func performBasicDatabaseCommand(command: DocumentData) throws -> DocumentData {

        var command = try MongoBSON(data: command).bson

        var reply = bson_t()
        var error = bson_error_t()

        mongoc_database_command_simple(self.databaseRaw, &command, nil, &reply, &error)

        try error.throwIfError()

        return try MongoBSON(bson: reply).data
    }


    deinit {
        mongoc_database_destroy(databaseRaw)
    }
}
