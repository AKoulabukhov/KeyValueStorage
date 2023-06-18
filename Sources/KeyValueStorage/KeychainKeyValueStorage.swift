import Foundation

public final class KeychainKeyValueStorage: KeyValueStorageProtocol {
    private let keychain: KeychainProtocol
    private let accessible: KeychainAccessible

    public init(
        keychain: KeychainProtocol,
        accessible: KeychainAccessible = .unlocked
    ) {
        self.keychain = keychain
        self.accessible = accessible
    }

    public func setValue<Value: Encodable>(
        _ value: Value,
        forKey key: String
    ) throws {
        try keychain.setData(
            value.data,
            forAccount: key,
            accessible: accessible
        )
    }
    
    public func value<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type
    ) throws -> Value? {
        try keychain.getData(
            forAccount: key
        ).map {
            try Value.decodeData($0)
        }
    }

    public func removeValue(
        forKey key: String
    ) throws {
        try keychain.removeData(
            forAccount: key
        )
    }
}
