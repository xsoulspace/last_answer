# flutter_secure_storage_darwin

This is the platform-specific implementation of `flutter_secure_storage` for iOS macOS.

## Features

- Secure storage using the Keychain API.
- Fully integrated with iOS and macOS security features.

## Installation

Add the dependency in your `pubspec.yaml` and run `flutter pub get`.

## Configuration

You also need to add Keychain Sharing as capability to your iOS or macOS runner. To achieve this, please add the following in *both* your `(ios/macos)/Runner/DebugProfile.entitlements` *and* `(ios/macos)/Runner/Release.entitlements`.

```
<key>keychain-access-groups</key>
<array/>
```

If you have set your application up to use App Groups then you will need to add the name of the App Group to the `keychain-access-groups` argument above. Failure to do so will result in values appearing to be written successfully but never actually being written at all. For example if your app has an App Group named "aoeu" then your value for above would instead read:

```
<key>keychain-access-groups</key>
<array>
	<string>$(AppIdentifierPrefix)aoeu</string>
</array>
```

If you are configuring this value through XCode then the string you set in the Keychain Sharing section would simply read "aoeu" with XCode appending the `$(AppIdentifierPrefix)` when it saves the configuration.

## Usage

Refer to the main [flutter_secure_storage README](../README.md) for common usage instructions.

## License

This project is licensed under the BSD 3 License. See the [LICENSE](../LICENSE) file for details.
