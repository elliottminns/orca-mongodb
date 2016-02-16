
#if os(Linux)
import CMongoLinux
#else
import CMongoMac
import CBsonMac
#endif


class MongoDatabase {

    var ptr: COpaquePointer

	init(client: MongoClient, databaseName: String) {
		self.ptr = mongoc_client_get_database(client.ptr, databaseName)
	}

	func close() {
		if self.ptr != nil {
			mongoc_database_destroy(self.ptr)
			self.ptr = nil
		}
	}

	func drop() -> MongoResult {
		var error = bson_error_t()
		if mongoc_database_drop(self.ptr, &error) {
			return .Success
		}
		return Result.fromError(error)
	}

	func name() -> String {
		return String.fromCString(mongoc_database_get_name(self.ptr))!
	}

	func createCollection(collectionName: String,
        options: BSON) -> MongoResult {
    		var error = bson_error_t()
    		let col = mongoc_database_create_collection(self.ptr, collectionName, options.doc, &error)
    		guard col != nil else {
    			return MongoResult.fromError(error)
    		}
    		return .ReplyCollection(MongoCollection(rawPtr: col))
	}

	func getCollection(collectionName: String) -> MongoCollection {
		let col = mongoc_database_get_collection(self.ptr, collectionName)
		return MongoCollection(rawPtr: col)
	}

	func collectionNames() -> [String] {
		let names = mongoc_database_get_collection_names(self.ptr, nil)
		var ret = [String]()
		if names != nil {
			var curr = names
			while curr.memory != nil {
				ret.append(String.fromCString(curr.memory)!)
				curr = curr.successor()
			}
			bson_strfreev(names)
		}
		return ret
	}
}
