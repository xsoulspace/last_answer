import Foundation
import Security

/// An unsuccessful replacement must not destroy the existing protected item.
/// Add is admitted only by the definitive item-not-found result. A competing
/// insertion returns duplicate-item rather than overwriting another writer.
enum AtomicKeychainWriter {
    static func write(
        query: [CFString: Any],
        value: Data,
        update: (CFDictionary, CFDictionary) -> OSStatus = SecItemUpdate,
        add: (CFDictionary) -> OSStatus = { SecItemAdd($0, nil) }
    ) -> OSStatus {
        // The plugin's shared query includes read-result flags. They are not
        // update search attributes and must not make a replacement errSecParam.
        var search = query
        for key in [kSecReturnData, kSecReturnAttributes, kSecReturnRef,
                    kSecReturnPersistentRef, kSecMatchLimit] {
            search.removeValue(forKey: key)
        }
        let changes = [kSecValueData: value] as CFDictionary
        let status = update(search as CFDictionary, changes)
        guard status == errSecItemNotFound else { return status }
        var creation = search
        creation[kSecValueData] = value
        return add(creation as CFDictionary)
    }
}
