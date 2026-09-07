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
//
// Store publishing (ADR-0014/0015): the publish targets `playPublishTarget`
// and `huaweiPublishTarget` are declared at the bottom of this file —
// including the one-time human setup (accounts, credential files, env vars)
// that each store requires. This file is the single source of truth for
// publishing: dry-run first (`oka run <target>`), real upload only after
// flipping `dryRun: false` here.
import 'package:oka_android/oka_android.dart';
import 'package:oka_huawei/oka_huawei.dart';
import 'package:oka_play/oka_play.dart';

/// The Android build identity, shared by the Play pipeline and the Huawei
/// GMS-free variant (single source of truth — the Huawei composition must
/// describe the same app).
const AndroidBuild _androidBuild = AndroidBuild(
  name: 'Last Answer',
  packageName: 'dev.xsoulspace.lastanswer',
  compileSdk: '36',
  targetSdk: '36',
  minSdk: '25',
  versionCode: 51,
  versionName: '3.22.0',
  javaVersion: 17,
);

/// Packaging fast-settings shared by the Play pipeline and the Huawei
/// GMS-free variant. No GMS Maven coordinates are declared here — the oka
/// build is GMS-free by construction (the legacy `android/` Gradle project
/// references Firebase plugins, but oka does not consume it).
const PipelineOverrides _androidOverrides = PipelineOverrides(
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
);

Future<void> main(final List<String> args) => okaRun(
  args,
  oka: const Oka(
    pipelines: [
      AndroidPipeline(
        config: _androidBuild,
        flutterConfig: FlutterBuild(entrypoint: 'lib/main_prod.dart'),
        overrides: _androidOverrides,
        // No explicit steps: AndroidPipeline composes the default no-Gradle
        // pipeline and selects APK vs AAB from --aab (an explicit list would
        // pin the artifact type).
      ),
    ],
    // ADR-0015 verb/target split: publish targets are project-declared and
    // dispatched with `oka run <target>`. Both targets below default to
    // dry-run — the plan prints exactly what a real upload would do and
    // requires no credentials (the ADR-0014 conformance law).
    targets: [playPublishTarget, huaweiPublishTarget],
  ),
);

/// Google Play publish target (ADR-0014 P1; ADR-0015 verb/target split).
///
/// Uploads the release AAB to the **internal** testing track of
/// `dev.xsoulspace.lastanswer` via the Play Publisher API (androidpublisher
/// /v3 Edits flow: create edit → upload AAB → assign track → commit).
///
/// ## What oka does automatically
///
/// - **Artifact staging** — the `stage-aab` step maps the AAB the oka
///   Android build produces onto the publish artifact; dry-run works even
///   before an AAB exists (the plan describes the path a real run uploads).
/// - **Credential resolution by path** (ADR-0014 three-tier model — the
///   JSON is *referenced*, never embedded, never carried as a value):
///   1. a path set in typed config (`serviceAccountPath:`),
///   2. the `OKA_PLAY_SERVICE_ACCOUNT_JSON` environment variable
///      (its value must be a **path** to the JSON, never the JSON itself),
///   3. the well-known location `~/.oka/credentials/play/service-account-json`.
/// - **Dry-run by default** — prints the publish plan (endpoint, track,
///   artifact, metadata) and performs zero HTTP; no credential file needs
///   to exist.
/// - **Real run** — signs a JWT with the service-account key (RS256,
///   in-memory only), exchanges it for an OAuth token, then runs the Edits
///   flow. No stdin, ever; no secret values in state, logs, or events.
/// - **On failure, names the fix** — a missing credential lists every
///   candidate tried (typed path → env var → well-known location) and how
///   to place the file; a malformed JSON names the missing *fields*, never
///   any value.
///
/// ## Human setup (once)
///
/// 1. Google Cloud Console → **IAM & Admin → Service Accounts** → create a
///    service account for publishing. Enable the **Google Play Android
///    Developer API** for the project.
/// 2. Play Console → **Users and permissions** → invite that service
///    account's email, grant it (at least) *Release to testing* — and app
///    access for Last Answer once the app exists on the account.
/// 3. On the service account: **Keys → Add key → JSON**, download the key
///    file (the service-account JSON).
/// 4. Store the JSON **outside this repo**, or under a gitignored path —
///    oka's repo-hygiene check warns if a resolved credential lives inside
///    the project un-ignored. Never commit it; it is a private key.
/// 5. Make it discoverable (any one of the three policy sources above),
///    e.g. `export OKA_PLAY_SERVICE_ACCOUNT_JSON=$HOME/.oka/credentials/play/service-account.json`
///    or place the file at the well-known path directly.
/// 6. Dry-run (safe, credential-free): `oka run publish-play`.
/// 7. Build the release bundle: `oka build aab --release`.
/// 8. Real upload: flip `dryRun: false` here (an explicit, reviewable
///    typed decision — publishing targets plan unless told to execute)
///    and run `oka run publish-play --release --aab`.
///
/// Why a path and not a dart-define: compilation-time defines are baked
/// into the shipped binary and echoed in logs — wrong tier for credential
/// material (ADR-0014, three-tier table).
const PlayPublishTarget playPublishTarget = PlayPublishTarget(
  // Safe default: plan, never upload. Flip to false only for a real run.
  dryRun: true,
  packageName: 'dev.xsoulspace.lastanswer',
  releaseTrack: PlayTrack.internal,
);

/// Huawei AppGallery publish target (ADR-0014 P2; ADR-0015 verb/target
/// split).
///
/// Uploads the release AAB to AppGallery Connect (AGC) on the **beta**
/// (open testing) track for app `appId` below, composing the GMS-free
/// Android build variant (`variant:`) per the ADR-0013 two-axis law.
///
/// ## What oka does automatically
///
/// - **GMS-free composition, proven early** — this app's oka build declares
///   no GMS Maven coordinates (no `extraDeps`), so the
///   [HuaweiBuildVariant] exclusion has nothing to drop
///   (`excludedGmsDeps` is empty) and the same GMS-free AAB serves both
///   stores. The variant keeps that property mechanical: if a GMS
///   coordinate is ever added, the exclusion filters it out of the Huawei
///   artifact, and any step that *requires* a GMS-provided artifact fails
///   the artifact validator at composition time — before any tool runs.
/// - **Credential resolution by path** (ADR-0014 three-tier model): the
///   AGC "API client" JSON is *referenced*, never embedded:
///   1. a path in typed config (`credentialPath:`),
///   2. the `OKA_HUAWEI_AGCONNECT_CREDENTIALS` environment variable
///      (a **path** to the JSON, never its contents),
///   3. the well-known location
///      `~/.oka/credentials/huawei/agconnect-credentials`.
/// - **Dry-run by default** — prints the publish plan (endpoint, track,
///   artifact, appId/phase/release-notes metadata) with zero HTTP and no
///   credential file present.
/// - **Real run** — OAuth2 client-credentials token → upload-url →
///   artifact upload → submit (track, phase percent, and release notes
///   read from their files at publish time). No stdin, ever; the client
///   secret and token never enter state, logs, or events.
/// - **On failure, names the fix** — missing credential lists every
///   candidate tried + remediation; missing release-note file names the
///   exact path.
///
/// ## Human setup (once)
///
/// 1. AppGallery Connect (developer.huawei.com/consumer/console) → create
///    a developer account, then **My apps → New app** (Android), package
///    name `dev.xsoulspace.lastanswer`. Note the numeric **app id** AGC
///    assigns (not a secret) and put it in `release: appId:` below.
/// 2. **Users and permissions → API client**: create an API client for the
///    project/app and note its `client_id` + `client_secret`; store them as
///    a JSON file of the shape `{"client_id": "...", "client_secret":
///    "..."}` (this is the credential oka resolves by path).
/// 3. Store that JSON **outside this repo** (or gitignored — oka warns on
///    un-ignored credentials inside the project) and make it discoverable
///    via any one policy source, e.g.
///    `export OKA_HUAWEI_AGCONNECT_CREDENTIALS=$HOME/.oka/credentials/huawei/agconnect-credentials`.
/// 4. Create the release-note files referenced in `release: releaseNotes:`
///    below (plain text, one per language).
/// 5. Dry-run (safe, credential-free): `oka run publish-huawei`.
/// 6. Build the release bundle: `oka build aab --release`.
/// 7. Real upload: flip `dryRun: false` here and run
///    `oka run publish-huawei --release --aab`.
const HuaweiPublishTarget huaweiPublishTarget = HuaweiPublishTarget(
  // Safe default: plan, never upload. Flip to false only for a real run.
  dryRun: true,
  release: HuaweiReleaseConfig(
    // TODO(human): fill in the numeric AGC app id (appId:) after "New app"
    // in AppGallery Connect (step 1 of the walkthrough above). Empty keeps
    // the dry-run valid; a real submit without it fails naming the fix.
    track: HuaweiReleaseConfig.defaultTrack,
    // Release notes are file paths (ADR-0014 tier rule — content is read
    // from disk at publish time, never inlined into typed config). Create
    // these before a real run (step 4 of the walkthrough above).
    releaseNotes: [
      AgcReleaseNote(language: 'en', file: 'promo/store/whatsnew-en.txt'),
      AgcReleaseNote(language: 'ru', file: 'promo/store/whatsnew-ru.txt'),
    ],
  ),
  variant: HuaweiBuildVariant(
    android: _androidBuild,
    overrides: _androidOverrides,
  ),
);
