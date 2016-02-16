public class MongoCursor {

	var ptr: COpaquePointer

	init(rawPtr: COpaquePointer) {
		self.ptr = rawPtr
	}

	func close() {
		if self.ptr != nil {
			mongoc_cursor_destroy(self.ptr)
			self.ptr = nil
		}
	}

	func next() -> BSON? {
		var bson = UnsafePointer<bson_t>()
		if mongoc_cursor_next(self.ptr, &bson) {
			return NoDestroyBSON(rawBson: UnsafeMutablePointer<bson_t>(bson))
		}
		return nil
	}
}
