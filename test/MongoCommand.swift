#if os(Linux)
import CMongoLinux
#else
import CMongoMac
import CBsonMac
#endif

protocol CommandValue {
    func appendValueToBSON(bson: BSON, withKey key: String)
}

extension Int: CommandValue {
    func appendValueToBSON(bson: BSON, withKey key: String) {
        bson.append(key, int: self)
    }
}

struct MongoCommand<T: CommandValue> {
    let key: String
    let value: T

    init(key: String, value: T) {
        self.key = key
        self.value = value
    }

    func bson() -> BSON {
        let command = BSON()
        self.value.appendValueToBSON(command, withKey: key)
        return command
    }
}
