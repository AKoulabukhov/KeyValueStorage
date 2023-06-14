import Foundation

public protocol KeyValueStorageProtocol: AnyObject {
    func setValue<Value: Encodable>(
        _ value: Value,
        forKey key: String
    ) throws
    func value<Value: Decodable>(
        forKey key: String,
        ofType type: Value.Type
    ) throws -> Value?
}

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

extension Encodable {
    var data: Data {
        get throws {
            try encoder.encode(self)
        }
    }
}

extension Decodable {
    static func decodeData(_ data: Data) throws -> Self {
        try decoder.decode(self, from: data)
    }
}
