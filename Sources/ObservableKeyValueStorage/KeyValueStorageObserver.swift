import Foundation

final class KeyValueStorageObserver {
    let didChange: KeyValueStorageObserverBlock<Any>
    let onDeinit: () -> Void

    init<Value>(
        didChange: @escaping KeyValueStorageObserverBlock<Value>,
        onDeinit: @escaping () -> Void
    ) {
        self.didChange = { any in
            switch any {
            case .some(let value):
                guard let value = value as? Value else {
                    return assertionFailure("Type mismatch")
                }
                didChange(value)
            case .none:
                didChange(nil)
            }
        }
        self.onDeinit = onDeinit
    }

    deinit {
        onDeinit()
    }
}
