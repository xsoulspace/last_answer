import Foundation
import Security

private func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() { fatalError(message) }
}

@main
struct AtomicKeychainWriterTests {
    static func main() {
        let old = Data("synthetic-old-protected-record".utf8)
        let next = Data("synthetic-next-protected-record".utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "synthetic-only",
        ]
        var record = old
        var additions = 0
        let failed = AtomicKeychainWriter.write(query: query, value: next,
            update: { _, _ in errSecInteractionNotAllowed },
            add: { _ in additions += 1; record = next; return errSecSuccess })
        expect(failed == errSecInteractionNotAllowed, "original update failure must survive")
        expect(record == old && additions == 0, "failed replacement must preserve prior record")

        let updated = AtomicKeychainWriter.write(query: query, value: next,
            update: { _, changes in
                let values = changes as NSDictionary
                expect(values[kSecValueData] as? Data == next, "exact replacement bytes")
                record = next
                return errSecSuccess
            }, add: { _ in fatalError("successful update must never add") })
        expect(updated == errSecSuccess && record == next, "update commits exact bytes")

        let created = AtomicKeychainWriter.write(query: query, value: next,
            update: { _, _ in errSecItemNotFound },
            add: { item in
                let values = item as NSDictionary
                expect(values[kSecAttrAccount] as? String == "synthetic-only", "creation retains identity")
                expect(values[kSecValueData] as? Data == next, "creation retains bytes")
                additions += 1
                return errSecSuccess
            })
        expect(created == errSecSuccess && additions == 1, "only absent item permits creation")

        let raced = AtomicKeychainWriter.write(query: query, value: next,
            update: { _, _ in errSecItemNotFound }, add: { _ in errSecDuplicateItem })
        expect(raced == errSecDuplicateItem, "racing insertion must refuse, never overwrite/replay")
        var pluginQuery = query
        for key in [kSecReturnData, kSecReturnAttributes, kSecReturnRef, kSecReturnPersistentRef] {
            pluginQuery[key] = true
        }
        pluginQuery[kSecMatchLimit] = kSecMatchLimitOne
        let pluginShaped = AtomicKeychainWriter.write(query: pluginQuery, value: next,
            update: { search, _ in
                let values = search as NSDictionary
                expect(values[kSecReturnData] == nil && values[kSecMatchLimit] == nil,
                    "update strips read-result flags")
                expect(values[kSecReturnAttributes] == nil && values[kSecReturnRef] == nil &&
                    values[kSecReturnPersistentRef] == nil, "all result flags stripped")
                expect(values[kSecAttrAccount] as? String == "synthetic-only", "identity preserved")
                return errSecItemNotFound
            }, add: { creation in
                let values = creation as NSDictionary
                expect(values[kSecReturnData] == nil && values[kSecMatchLimit] == nil,
                    "creation strips read-result flags")
                return errSecSuccess
            })
        expect(pluginShaped == errSecSuccess, "plugin-shaped write is admitted")
        print("5 native atomic Keychain write controls passed; no OS items touched")
    }
}
