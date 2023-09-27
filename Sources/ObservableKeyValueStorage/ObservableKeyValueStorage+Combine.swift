import Foundation
import Combine

extension ObservableKeyValueStorageProtocol {
    @available(iOS 13, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public func makeSubject<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type
    ) -> KeyValueStorageSubject<Value> {
        KeyValueStorageSubject(
            key: key,
            storage: self
        )
    }
}

@available(iOS 13, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public struct KeyValueStorageSubject<Value: Decodable>: Publisher {
    public typealias Output = Value?
    public typealias Failure = Error

    private let key: String
    private let storage: ObservableKeyValueStorageProtocol

    private let subject: CurrentValueSubject<Output, Failure>
    private let observation: AnyObject?
    
    init(
        key: String,
        storage: ObservableKeyValueStorageProtocol
    ) {
        self.key = key
        self.storage = storage

        self.subject = CurrentValueSubject<Output, Failure>(nil)

        do {
            try self.subject.send(
                self.storage.value(
                    forKey: key,
                    ofType: Value.self
                )
            )
            self.observation = self.storage.addObserver(
                forKey: key,
                ofType: Value.self,
                didChange: { [subject] value in
                    subject.send(value)
                }
            )
        } catch {
            self.subject.send(completion: .failure(error))
            self.observation = nil
        }
    }
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Failure == Failure, S.Input == Output {
        subject.receive(subscriber: subscriber)
    }
    
    public var value: Output? {
        subject.value
    }
}
