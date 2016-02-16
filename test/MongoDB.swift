
#if os(Linux)
import CMongoLinux
#else
import CMongoMac
import CBsonMac
#endif

import Echo
import Foundation

class MongoDB {

    var client: MongoClient?
    var database: MongoDatabase?

    init() {
        mongoc_init()
    }

    func connect(uri: String, handler: (error: ErrorType?) -> ()) {
        self.client = MongoClient(url: uri)

        self.client?.checkServer() {
            (result: String?, error: ErrorType?) in
                handler(error: error)
        }

        let comps = uri.componentsSeparatedByString("/")

        if comps.count > 3 {
            if let dbName = comps.last?.componentsSeparatedByString("?").first {
                loadDatabase(dbName)
            }
        }
    }
}
