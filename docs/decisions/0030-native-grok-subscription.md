# ADR 0030: Native Grok subscription uses Last Answer's own public client

Status: Accepted direction; live qualification pending
Date: 2026-11-18
North Star impact: applies

Last Answer can use a Grok subscription the way it uses a ChatGPT plan.
The app owns browser and device sign-in, a protected account store, and
model choice. The harness owns the actor, tools, and acceptance through
an `InferenceClientBinding`. A signed-in plan does not authorize a
document or a tool call. Per-document transmission consent stays.

This client is Last Answer's own public OAuth client, so xAI can
register it the way OpenCode was registered. The Grok CLI client id is
not embedded. The app does not send Grok CLI identity headers and does
not point the default inference host at `cli-chat-proxy.grok.com`. It
does not read `~/.grok/auth.json`. The existing `openai_compatible`
API-key lane to `https://api.x.ai/v1` stays metered console billing.

## Registration packet

Send xAI these facts:

- App name: Last Answer
- Referrer: `last-answer`
- Redirect: `http://127.0.0.1:56123/callback`
- Redirect port is fixed. A busy port is `redirect_port_busy`. The app
  does not pick another port.
- Public PKCE S256 client. No client secret.
- Grants: authorization code with PKCE, refresh token, and RFC 8628
  device code.
- Issuer: `https://auth.x.ai`
  (`/oauth2/authorize`, `/oauth2/token`, `/oauth2/device/code`,
  `/oauth2/revoke`)
- Scopes: `openid profile email offline_access api:access`
- Default inference host: `https://api.x.ai/v1`
  (`POST /responses`, `GET /models`)

Sign-in stays closed until xAI issues a client id. A missing or blank
id throws `client_not_registered` before any network call. Drop-in once
issued:

```text
--dart-define=LAST_ANSWER_GROK_CLIENT_ID=...
--dart-define=LAST_ANSWER_GROK_API_BASE=...   # optional
```

`planEnabled` is true only when the token includes `api:access`.

## Account store

The account key is the OIDC `subject`, not the shared public client id.
Consent provider string: `xai_grok_plan:$subject`. Backend wire id:
`xai_grok_plan`.

The macOS login keychain service is
`dev.xsoulspace.lastAnswer.grok`, separate from the ChatGPT service.
`usesDataProtectionKeychain` is false and the item is not
synchronizable, for the same ad-hoc signing `-34018` reason as ADR 0017.
Storage key: `lastanswer.grok.accounts.v1`. Sign-out removes local
tokens even when revoke is not HTTP 200. Subject and email stay.
`invalid_grant` on refresh is `sign_in_required`. A ChatGPT-style
mutation fence is not in this version.

## What this slice does not claim

- ID-token signatures are not checked against the issuer JWKS. Claims
  (`sub`, `aud`, `exp`, `nonce`) are read from the token response that
  arrived on the issuer's TLS channel. JWKS verification is open
  qualification.
- Tool parameter schemas are open JSON objects. The host still
  validates calls. Tool-round continuation parity with the OpenAI
  client's session state is unproven until a live receipt. Text
  streaming is one delta after the full response.
- A subscription bearer sent to `https://api.x.ai/v1` is the requested
  default. It is not a live receipt. The host can move with
  `LAST_ANSWER_GROK_API_BASE` if xAI names another base.
- `configureNative` stays the ChatGPT path. Headless `open` takes an
  optional `backend` and still defaults to `openai_chatgpt_plan`.
- Actors address the plan as a provider type. The brain ref is
  `subscription:xai_grok_plan/<model>` (ADR 0031). That ref does not
  write this account's selected model.

Sources: ADR 0017; xAI public auth and API hosts as of 2026-11-18;
OpenCode's published registration shape (referrer plus a fixed loopback
redirect), without reusing its client id.
