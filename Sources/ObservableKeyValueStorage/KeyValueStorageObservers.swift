import Foundation

final class KeyValueStorageObservers {
    private typealias HashTable = NSHashTable<KeyValueStorageObserver>

    private let lock = NSRecursiveLock()
    private var observers = [String: HashTable]()

    func addObserver<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type,
        didChange: @escaping KeyValueStorageObserverBlock<Value>
    ) -> AnyObject {
        lock.lock()
        defer { lock.unlock() }

        let keyObservers = observers[key] ?? {
            let keyObservers = HashTable.weakObjects()
            observers[key] = keyObservers
            return keyObservers
        }()
        let newObserver = KeyValueStorageObserver(
            didChange: didChange,
            onDeinit: { [weak self] in
                self?.onDeinit(key: key)
            }
        )
        keyObservers.add(newObserver)
        return newObserver
    }

    func didChangeValue(
        forKey key: String,
        newValue: Any?
    ) {
        lock.lock()
        defer { lock.unlock() }

        guard let keyObservers = observers[key] else { return }
        keyObservers.allObjects.forEach {
            $0.didChange(newValue)
        }
    }

    private func onDeinit(key: String) {
        lock.lock()
        defer { lock.unlock() }

        guard let keyObservers = observers[key], keyObservers.allObjects.isEmpty else { return }
        observers[key] = nil
    }
}
