import XCTest
import Combine
@testable import KeyValueStorage
@testable import ObservableKeyValueStorage

@available(iOS 13, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
final class ObservableKeyValueStorageTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    
    func testObservableKeyValueStorage() throws {
        let storage = UserDefaultsKeyValueStorage(userDefaults: .standard).observable()
        try storage.setValue(1, forKey: "int")

        let subject = storage.makeSubject(
            forKey: "int",
            ofType: Int.self
        )
        var subjectValues = [Int?]()
        subject.sink(
            receiveCompletion: { _ in },
            receiveValue: { subjectValues.append($0) }
        ).store(in: &cancellables)

        let publisher = subject.asPublisher()
        var publisherValues = [Int?]()
        publisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { publisherValues.append($0) }
        ).store(in: &cancellables)

        try storage.removeValue(forKey: "int")
        try storage.setValue(2, forKey: "int")
        try storage.setValue(3, forKey: "int")
        try subject.setValue(4)
        try subject.setValue(nil)

        XCTAssertEqual(subjectValues, [1, nil, 2, 3, 4, nil])
        XCTAssertEqual(publisherValues, subjectValues)
    }
}
