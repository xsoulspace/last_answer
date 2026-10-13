import Foundation
import Security

@main
struct AtomicKeychainOSControl {
    static func main() throws {
        // Only this newly minted synthetic item is touched. Never use the
        // subscription service, account IDs, or any existing Keychain item.
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "dev.xsoulspace.lastAnswer.synthetic-atomic-control",
            kSecAttrAccount: UUID().uuidString,
            kSecAttrSynchronizable: false,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecReturnData: true,
        ]
        var deletion = query
        deletion.removeValue(forKey: kSecReturnData)
        defer {
            let status = SecItemDelete(deletion as CFDictionary)
            if status != errSecSuccess && status != errSecItemNotFound {
                print("Synthetic item cleanup failed with OSStatus \(status)")
            }
        }
        func check(_ status: OSStatus, _ stage: String) throws {
            guard status == errSecSuccess else {
                throw NSError(domain: "AtomicKeychainOSControl.\(stage)", code: Int(status))
            }
        }
        let original = Data("synthetic-not-a-credential-original".utf8)
        let replacement = Data("synthetic-not-a-credential-replacement".utf8)
        try check(AtomicKeychainWriter.write(query: query, value: original), "create")
        try check(AtomicKeychainWriter.write(query: query, value: replacement), "replace")
        let injectedFailure = AtomicKeychainWriter.write(query: query, value: original,
            update: { _, _ in errSecInteractionNotAllowed })
        guard injectedFailure == errSecInteractionNotAllowed else {
            throw NSError(domain: "AtomicKeychainOSControl.failure", code: Int(injectedFailure))
        }
        var found: CFTypeRef?
        try check(SecItemCopyMatching(query as CFDictionary, &found), "read")
        guard found as? Data == replacement else {
            throw NSError(domain: "AtomicKeychainOSControl.preservation", code: 1)
        }
        try check(SecItemDelete(deletion as CFDictionary), "cleanup")
        print("Synthetic OS login-Keychain create/update/read and injected-failure preservation passed")
    }
}
