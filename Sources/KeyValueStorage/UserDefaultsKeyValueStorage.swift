import Foundation

public final class UserDefaultsKeyValueStorage: KeyValueStorageProtocol {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public func setValue<Value: Encodable>(
        _ value: Value,
        forKey key: String
    ) throws {
        try userDefaults.setValue(
            value.data,
            forKey: key
        )
    }
    
    public func value<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type
    ) throws -> Value? {
        try userDefaults.data(
            forKey: key
        ).map {
            try Value.decodeData($0)
        }
    }

    public func removeValue(
        forKey key: String
    ) throws {
        userDefaults.removeObject(
            forKey: key
        )
    }
}
