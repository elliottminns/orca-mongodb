#if os(Linux)
import CMongoLinux
#else
import CMongoMac
import CBsonMac
#endif

import Foundation
import Echo

enum MongoResult {
	case Success
	case Error(UInt32, UInt32, String)
	case ReplyDoc(BSON)
	case ReplyInt(Int)
	case ReplyCollection(MongoCollection)

	static func fromError(error: bson_error_t) -> MongoResult {
		var vError = error
		let message = withUnsafePointer(&vError.message) {
			String.fromCString(UnsafePointer($0))!
		}
		return .Error(error.domain, error.code, message)
	}
}

public enum MongoError: ErrorType {
    case ConnectionError(message: String)
}

class MongoClient {

    var ptr: COpaquePointer

    init(url: String) {
        ptr = mongoc_client_new(url)
    }

    func checkServer(handler: (json: String?, error: ErrorType?) -> ()) {
         dispatch_async(dispatch_get_global_queue(0, 0)) {
            let result = self.serverStatus()
            switch result {
            case .Error(_, _, let message):
                let error = MongoError.ConnectionError(message: message)
                handler(json: nil, error: error)
            default:
                handler(json: nil, error: nil)
            }
        }
    }

    func performSimpleCommand<T>(command: MongoCommand<T>,
        handler: (json: String?, error: ErrorType?) -> ()) {
            dispatch_async(dispatch_get_global_queue(0, 0)) {

                let bson = command.bson()

                var error = bson_error_t()

                let reply = BSON()

                mongoc_client_command_simple(self.ptr, "admin", bson.doc,
                    nil, reply.doc, &error)

                    print(reply)
            }
    }

    func serverStatus() -> MongoResult {
        var error = bson_error_t()

        let readPrefs = mongoc_read_prefs_new(MONGOC_READ_PRIMARY)

        defer {
            mongoc_read_prefs_destroy(readPrefs)
        }

        let bson = BSON()

        guard mongoc_client_get_server_status(self.ptr, readPrefs,
            bson.doc, &error) else {
                return MongoResult.fromError(error)
        }
        return .ReplyDoc(bson)
    }
}
