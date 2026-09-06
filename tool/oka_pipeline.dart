// Typed, programmable project config for Last Answer (ADR-0010).
//
// Replaces the Gradle Android build (`android/` is kept only as the source
// of truth for res/ + signing conventions during migration). Precedence:
// defaults < oka.yaml (if kept) < this file < CLI args (--release/--aab/
// --abi/--dart-define/...).
//
// Migrated from android/app/build.gradle.kts + AndroidManifest.xml:
// - applicationId dev.xsoulspace.lastanswer, minSdk 25, compile/target 36
// - version 3.22.0 (51) from pubspec
// - label "Last Answer", real mipmap PNG launcher icons (via res_dirs)
// - LaunchTheme/NormalTheme splash themes + launch_background drawables
// - cleartext traffic, deeplinks (https/http xsoulspace.dev + custom scheme)
// - resource filtering en/ru, permissions INTERNET/ACCESS_NETWORK_STATE/CAMERA
// - <queries> + <uses-feature> preserved from the original manifest
import 'package:oka_android/oka_android.dart';
import 'package:oka_core/oka_core.dart';

Future<void> main(final List<String> args) => okaRun(
  args,
  oka: const Oka(
    pipelines: [
      AndroidPipeline(
        config: AndroidBuild(
          name: 'Last Answer',
          packageName: 'dev.xsoulspace.lastanswer',
          compileSdk: '36',
          targetSdk: '36',
          minSdk: '25',
          versionCode: 51,
          versionName: '3.22.0',
          javaVersion: 17,
        ),
        flutterConfig: FlutterBuild(entrypoint: 'lib/main_prod.dart'),
        overrides: PipelineOverrides(
          // Real launcher icons + launch/splash themes from the Gradle
          // project. User res wins over generated res; because mipmaps are
          // present and no icon fast-settings are set, oka skips its
          // generated adaptive icon entirely.
          resDirs: ['android/app/src/main/res'],
          resourceConfigs: ['en', 'ru'],
          excludePlugins: ['integration_test'],
          manifest: ManifestSpec(
            permissions: [
              AndroidPermission.internet,
              AndroidPermission.accessNetworkState,
              AndroidPermission.camera,
            ],
            cleartextTraffic: true,
            flutterDeeplinking: true,
            // Project splash themes (values/styles.xml + values-night).
            activityAttributes: {'android:theme': '@style/LaunchTheme'},
            activityMetaData: [
              MetaDataSpec(
                name: 'io.flutter.embedding.android.NormalTheme',
                resource: '@style/NormalTheme',
              ),
            ],
            deeplinks: [
              // App Links (autoVerify) — assetlinks hosted at xsoulspace.dev.
              DeeplinkConfig(scheme: 'https', host: 'xsoulspace.dev'),
              DeeplinkConfig(scheme: 'http', host: 'xsoulspace.dev'),
              // RuStore billing deeplink scheme (no host).
              DeeplinkConfig(scheme: 'dev.xsoulspace.lastanswer'),
            ],
            // Manifest-level surface not modeled by the typed spec yet.
            manifestElements: [
              // Camera is optional (QR scanning) — keeps Play filtering off.
              '<uses-feature\n        android:name="android.hardware.camera"\n        android:required="false" />',
              // Required to query activities that can process text
              // (Flutter engine ProcessTextPlugin) and open http(s) links.
              '''
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT" />
            <data android:mimeType="text/plain" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="http" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="https" />
        </intent>
    </queries>''',
            ],
          ),
        ),
        // No explicit steps: AndroidPipeline composes the default no-Gradle
        // pipeline and selects APK vs AAB from --aab (an explicit list would
        // pin the artifact type).
      ),
    ],
  ),
);
