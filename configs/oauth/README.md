# GitHub App setup

## 1. Create the app (one click, pre-filled)

Open `https://github.com/settings/apps/new?manifest=<...>` (regenerate the
URL below). Review and click **Create GitHub App**.

```bash
python3 - <<'PY'
import json, urllib.parse
m = json.load(open('github_app_manifest.json'))
print("https://github.com/settings/apps/new?manifest=" +
      urllib.parse.quote(json.dumps(m), safe=''))
PY
```

The manifest does NOT configure callback URLs (GitHub doesn't support that
at creation time for GitHub Apps). After creation:

## 2. Post-creation settings (github.com/settings/apps/<name>)

- **Callback URL**: `dev.xsoulspace.lastanswer://oauth/github/callback`
- **Enable Device Flow**: ✅ check this — required for Linux/Windows/web
  (see below)
- Note the **Client ID**. Generate a **client secret** only if you later
  need server-side token exchange; the user-agent flows below don't use it.
- Store the Client ID in app config (`--dart-define` or configs); never
  commit secrets.

## 3. Auth strategy per platform

| Platform | Flow | Why |
|----------|------|-----|
| Android  | device flow | no loopback/deep-link plumbing needed beyond opening browser |
| macOS    | device flow | same; avoids sandbox URL-scheme round-trip |
| Linux    | device flow | no deep-link support needed at all |
| Windows  | device flow | same |
| iOS      | device flow or redirect | both work |
| Web      | ❌ direct device flow blocked by CORS — needs proxy | see below |

### Device flow (recommended default everywhere)

1. App opens browser: `https://github.com/login/device` and shows the
   one-time code (e.g. `ABCD-1234`). User types it in and authorizes.
2. App polls `POST https://github.com/login/oauth/access_token` with
   `{client_id, device_code, grant_type: "urn:ietf:params:oauth:grant-type:device_code"}`
   until it returns `access_token` (interval + slow_down respected).
3. Token → `SecureCredentialStorage` → `GitHubApiStorageProvider`.

Implementation is ~100 lines of plain HTTP (no redirect capture, no custom
scheme on desktop) — to be added to `universal_storage_oauth`.

### Web: CORS limitation

`github.com/login/*` endpoints do not send CORS headers, so a pure browser
client cannot call the device-flow/token endpoints directly. Options:
- Proxy through your existing Firebase backend (repo already has
  `firebase.json`): a single Cloud Function forwarding the two POSTs.
- Or a tiny self-hosted relay.

Everything else (secure storage fallback, sync itself) works on web via
the github_api provider once the token exists.

## 4. Platform plumbing still required regardless of flow

- macOS entitlements: network (server client) + keychain-sharing for
  flutter_secure_storage.
- Android `INTERNET` permission (already present).

## 5. Wiring the Client ID into the app

Copy the Client ID (not a secret) into `configs/envs/prod.json`:

```json
{
  "GITHUB_OAUTH_CLIENT_ID": "Iv1.xxxxxxxxxxxxxxxx"
}
```

(Also present as an empty key in `prod.sample.json`. For quick local runs:
`flutter run --dart-define=GITHUB_OAUTH_CLIENT_ID=Iv1.xxx`.)

Builds already pass the file via `--dart-define-from-file=configs/envs/prod.json`
(see `justfile`). Without it, the settings toggle shows the feature as
unavailable.

### Is a token or client secret needed?

**No — neither.** The device flow is an OAuth "public client" flow
(RFC 8628): the app only ever sends the **Client ID**, which is safe to
embed in a distributed app. The user authorizes on github.com directly and
GitHub issues the access token to the polling app; no secret participates
anywhere, so there is nothing private to keep out of the repo.

Do **not** put a personal access token or the client secret in
`configs/envs/*.json` for this feature.
