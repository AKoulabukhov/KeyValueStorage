import Foundation
import Combine

extension ObservableKeyValueStorageProtocol {
    @available(iOS 13, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public func makeSubject<Value: Codable>(
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
public struct KeyValueStorageSubject<Value: Codable>: Publisher {
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

    public func setValue(_ newValue: Value?) throws {
        if let newValue {
            try storage.setValue(
                newValue,
                forKey: key
            )
        } else {
            try storage.removeValue(
                forKey: key
            )
        }
    }
    
    public var value: Value? {
        subject.value
    }
}

/// A wrapper of KeyValueStorageSubject.
/// The purpose of this type is to remove the possibility to send new values on the underlying subject
@available(iOS 13, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public struct KeyValueStoragePublisher<Value: Codable>: Publisher {
    public typealias Output = Value?
    public typealias Failure = Error
    
    private let subject: KeyValueStorageSubject<Value>
    
    init(_ subject: KeyValueStorageSubject<Value>) {
        self.subject = subject
    }
    
    public func receive<S: Subscriber>(
        subscriber: S
    ) where S.Failure == Failure, S.Input == Output {
        subject.receive(subscriber: subscriber)
    }
    
    public var value: Value? {
        subject.value
    }
}

@available(iOS 13, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
extension KeyValueStorageSubject {
    public func asPublisher() -> KeyValueStoragePublisher<Value> {
        .init(self)
    }
}
