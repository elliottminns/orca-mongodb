import Echo
import Foundation

class MongoDB {

    var client: MongoClient?
    var database: MongoDatabase?

    func connect(host host: String, port: Int, database: String,
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
}
