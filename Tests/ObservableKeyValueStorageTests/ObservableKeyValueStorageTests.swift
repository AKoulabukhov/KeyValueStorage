import XCTest
import Combine
@testable import KeyValueStorage
@testable import ObservableKeyValueStorage

@available(iOS 13, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
final class ObservableKeyValueStorageTests: XCTestCase {

    private var cancellable: AnyCancellable?
    
    func testObservableKeyValueStorage() throws {
        let storage = UserDefaultsKeyValueStorage(userDefaults: .standard).observable()
        try storage.setValue(1, forKey: "int")

        let subject = storage.makeSubject(
            forKey: "int",
            ofType: Int.self
        )

        var values = [Int?]()

        cancellable = subject.sink(
            receiveCompletion: { _ in },
            receiveValue: { values.append($0) }
        )

        try storage.removeValue(forKey: "int")
        try storage.setValue(2, forKey: "int")
        try storage.setValue(3, forKey: "int")
        try subject.setValue(4)
        try subject.setValue(nil)

        XCTAssertEqual(values, [1, nil, 2, 3, 4, nil])
    }
}
