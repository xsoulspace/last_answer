# Local atomic replacement patch

Upstream: flutter_secure_storage_darwin 0.3.2 from pub.dev, repository
https://github.com/juliansteenbakker/flutter_secure_storage.
The original BSD-3-Clause license is retained. UPSTREAM_SHA256.json records the
unmodified package files imported from the installed source archive.
UPSTREAM_SOURCE.json retains the public archive URL and SHA-256.
Local version: 0.3.2+lastanswer.1; publish_to:none.

The ordinary Keychain write previously deleted an existing item when
SecItemUpdate failed, then attempted SecItemAdd. A failed replacement could lose
the protected credential bundle, pending mutation fence and cleanup uncertainty.
The patch uses update-first and permits addition only on errSecItemNotFound.
Other failures and a racing duplicate insertion return their original status;
there is no deletion, automatic retry or credential-domain fallback.

Only the ordinary single-item write is qualified by this change. The optional
Secure Enclave two-item path is unchanged and is not an atomic credential-bundle
contract. Last Answer subscription storage does not select that path.

Run `bash tool/test_atomic_keychain.sh` from this package, or use its full path
from Last Answer root. Five native injected-operation controls exercise failure
preservation, exact update/creation and duplicate refusal without touching OS
Keychain items. The plugin-shaped query control strips read-result flags before
update/add, while preserving item identity. A separate
`bash tool/test_atomic_keychain_os.sh` control creates, updates, reads and deletes
only one newly minted synthetic login-Keychain item; injected replacement failure
leaves its replacement bytes intact. It never touches subscription items. Compile the actual plugin through the macOS app before runtime
claims. iOS compile/runtime qualification is separate.

Removal route: replace this path override with an upstream release that preserves
failed updates, rerun native controls against its actual implementation, rebuild
and verify the product account/store journey. Do not drop the override solely
because a newer version exists.
