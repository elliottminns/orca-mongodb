import Echo
import Foundation

public class MongoDB {

    var client: MongoClient?
    public var database: MongoDatabase?

    public init() {

    }

    public func connect(host: String, port: Int, database: String,
        handler: (error: ErrorProtocol?) -> ()) {

            let error: ErrorProtocol?

            do {
                self.client = try MongoClient(host: "localhost", port: 27017)
                if let client = self.client {
                    self.database = MongoDatabase(client: client,
                        name: database)
                }
                error = nil

            } catch let err {
                error = err
            }

            handler(error: error)
    }

    public func connect(uri: String, callback: (error: ErrorProtocol?) -> ()) {
        let error: ErrorProtocol?

        do {
            self.client = try MongoClient(uri: uri)
            if let client = self.client, dbName = client.getDatabaseName() {
                self.database = MongoDatabase(client: client,
                    name: dbName)
            }
            error = nil
        } catch let err {
            error = err
        }

        callback(error: error)
    }

    public func disconnect() {
        self.client = nil
    }
}
