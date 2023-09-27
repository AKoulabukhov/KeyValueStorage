import Foundation
import KeyValueStorage

public final class ObservableKeyValueStorage: ObservableKeyValueStorageProtocol {
    private let keyValueStorage: KeyValueStorageProtocol
    private let observers = KeyValueStorageObservers()

    public init(
        keyValueStorage: KeyValueStorageProtocol
    ) {
        self.keyValueStorage = keyValueStorage
    }

    public func addObserver<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type,
        didChange: @escaping KeyValueStorageObserverBlock<Value>
    ) -> AnyObject {
        observers.addObserver(
            forKey: key,
            ofType: type,
            didChange: didChange
        )
    }
    
    public func setValue<Value: Encodable>(
        _ value: Value,
        forKey key: String
    ) throws {
        try keyValueStorage.setValue(
            value,
            forKey: key
        )
        observers.didChangeValue(
            forKey: key,
            newValue: value
        )
    }
    
    public func value<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type
    ) throws -> Value? {
        try keyValueStorage.value(
            forKey: key,
            ofType: type
        )
    }
    
    public func removeValue(
        forKey key: String
    ) throws {
        try keyValueStorage.removeValue(
            forKey: key
        )
        observers.didChangeValue(
            forKey: key,
            newValue: nil
        )
    }
}

extension KeyValueStorageProtocol {
    public func observable() -> ObservableKeyValueStorage {
        ObservableKeyValueStorage(keyValueStorage: self)
    }
}
