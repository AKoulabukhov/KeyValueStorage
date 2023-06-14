import Foundation

final class UserDefaultsKeyValueStorage: KeyValueStorageProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func setValue<Value: Encodable>(
        _ value: Value,
        forKey key: String
    ) throws {
        try userDefaults.setValue(
            value.data,
            forKey: key
        )
    }
    
    func value<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type
    ) throws -> Value? {
        try userDefaults.data(
            forKey: key
        ).map {
            try Value.decodeData($0)
        }
    }

}
