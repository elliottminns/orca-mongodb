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
//  MongoDB.swift
//  swiftMongoDB
//
//  Created by Dan Appel on 8/20/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import CMongoC

class MongoClient {

    let clientURI: String

    let port: Int
    let host: String

    let clientRaw: _mongoc_client

    init(host: String, port: Int) throws {

        self.clientURI = "mongodb://\(host):\(port)"

        self.host = host
        self.port = port

        mongoc_init()

        self.clientRaw = mongoc_client_new(self.clientURI)

        try checkConnection()
    }

    // authenticated connection - required specific database
    convenience init(host: String, port: Int, database: String, usernameAndPassword: (username: String, password: String)) throws {
        try self.init(
            host: host,
            port: port,
            database: database,
            authenticationDatabase: database,
            usernameAndPassword: usernameAndPassword
        )
    }

    // authenticated connection - required specific database and specific database for authentication
    init(host: String, port: Int, database: String, authenticationDatabase: String, usernameAndPassword: (username: String, password: String)) throws {

        let userAndPass = "\(usernameAndPassword.username):\(usernameAndPassword.password)@"

        self.clientURI = "mongodb://\(userAndPass)\(host):\(port)/\(database)?authSource=\(authenticationDatabase)"

        self.host = host
        self.port = port

        mongoc_init()

        self.clientRaw = mongoc_client_new(self.clientURI)

        try checkConnection()
    }

    /**
     Attempts to run the `ping` command on the database. If it executes without throwing errors, you are successfully connected.

     - throws: Any errors it encounters while connecting to the database.
     */
    func checkConnection() throws {
        try performBasicClientCommand(["ping":1], databaseName: "local")
    }

    deinit {
        mongoc_client_destroy(self.clientRaw)
        mongoc_cleanup()
    }


    func getDatabaseNames() throws -> [String] {
        var error = bson_error_t()
        let namesRaw = mongoc_client_get_database_names(self.clientRaw, &error)

        try error.throwIfError()
        let names = namesRaw.sequence()!
            .map { (cStr: UnsafeMutablePointer<Int8>) -> String? in
                return String(utf8String: cStr)
            }
            .flatMap { $0 }

        return names
    }

    func performBasicClientCommand(command: DocumentData, databaseName: String) throws -> DocumentData {

        var command = try MongoBSON(data: command).bson

        var reply = bson_t()
        var error = bson_error_t()

        mongoc_client_command_simple(self.clientRaw, databaseName, &command,
                                     nil, &reply, &error)

        try error.throwIfError()

        return try MongoBSON(bson: reply).data
    }

    func performClientCommand(query: DocumentData, database: MongoDatabase, fields: [String], flags: QueryFlags, options: QueryOptions) throws -> MongoCursor {

        var query = try MongoBSON(data: query).bson
        var fields = try MongoBSON(json: fields.toJSON()).bson

        let cursor = mongoc_client_command(clientRaw, database.name, flags.rawFlag, options.skip.UInt32Value, options.limit.UInt32Value, options.batchSize.UInt32Value, &query, &fields, nil)

        return MongoCursor(cursor: cursor)
    }

    func getDatabasesCursor() throws -> MongoCursor {

        var error = bson_error_t()

        let cursor = mongoc_client_find_databases(clientRaw, &error)

        try error.throwIfError()

        return MongoCursor(cursor: cursor)
    }

    func getServerStatus() throws -> DocumentData {

        var reply = bson_t()
        var error = bson_error_t()

        mongoc_client_get_server_status(clientRaw, nil, &reply, &error)

        try error.throwIfError()

        return try MongoBSON(bson: reply).data
    }

    //    func getReadPrefs() throws /* -> _mongoc_read_prefs */ {
    //
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
}


// todo:
// void mongoc_client_set_ssl_opts  (mongoc_client_t *client, const mongoc_ssl_opt_t *opts);
