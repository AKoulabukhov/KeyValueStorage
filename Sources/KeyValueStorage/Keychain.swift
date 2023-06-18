import Foundation

public enum KeychainAccessible {
    case unlocked
    case afterFirstUnlock
    case passcodeSetThisDeviceOnly
    case unlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
}

public protocol KeychainProtocol: AnyObject {
    func setData(
        _ data: Data,
        forAccount account: String,
        accessible: KeychainAccessible
    ) throws
    func getData(
        forAccount account: String
    ) throws -> Data?
    func removeData(
        forAccount account: String
    ) throws
}

extension KeychainProtocol {
    public func setData(
        _ data: Data,
        forAccount account: String,
        accessible: KeychainAccessible = .unlocked
    ) throws {
        try setData(
            data,
            forAccount: account,
            accessible: accessible
        )
    }
}

public final class Keychain: KeychainProtocol {
    private struct KeychainError: Error {
        let status: OSStatus
    }

    private let service: String

    public init(service: String) {
        self.service = service
    }

    public func setData(
        _ data: Data,
        forAccount account: String,
        accessible: KeychainAccessible
    ) throws {
        let query: [CFString: Any] = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessible: accessible.keychainValue
        ]

        var status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        if status == errSecDuplicateItem {
            let query: [CFString: Any] = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ]
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary

            status = SecItemUpdate(
                query as CFDictionary,
                attributesToUpdate
            )
        }
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    public func getData(
        forAccount account: String
    ) throws -> Data? {
        let query: [CFString: Any] = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        if status == errSecItemNotFound {
            return nil
        }

        guard let data = result as? Data else {
            throw KeychainError(status: status)
        }
        
        return data
    }

    public func removeData(
        forAccount account: String
    ) throws {
        let query: [CFString: Any] = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecItemNotFound {
            return
        }

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
}

private extension KeychainAccessible {
    var keychainValue: CFString {
        switch self {
        case .unlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .passcodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .unlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
    }
}
