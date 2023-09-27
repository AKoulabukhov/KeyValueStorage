import Foundation
import KeyValueStorage

public typealias KeyValueStorageObserverBlock<Value> = (Value?) -> Void

public protocol ObservableKeyValueStorageProtocol: KeyValueStorageProtocol {
    func addObserver<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type,
        didChange: @escaping KeyValueStorageObserverBlock<Value>
    ) -> AnyObject
}
