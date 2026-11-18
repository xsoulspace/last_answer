# ADR 0031: A subscription is a provider type an actor names

Status: Accepted direction
Date: 2026-11-18
North Star impact: applies

ChatGPT plan and Grok plan are providers of type `subscription`. An
actor's brain names the provider and the model:

```text
subscription:<providerId>/<modelId>
```

The provider ids are `openai_chatgpt_plan` and `xai_grok_plan`. Optional
`reasoning` uses the same query grammar as the other brains. Sign-in
stays once per provider on the device. The account store holds the
tokens. The model on the brain ref is that actor's. Resolving the brain
does not write the account's selected model, so one actor can use the
ChatGPT plan, another the Grok plan, and others OpenRouter models or a
ModelScope cast, together.

This type is not a harness palette transport. `PaletteTransport` is
closed: `openrouter`, `openai_compatible`, `system_one`. An unknown
transport is `palette_unknown_transport` and refuses the whole palette.
The daemon does not hold the OAuth account, so a live daemon does not
take a `subscription:` actor. The in-app host builds that actor's
client from the signed-in account.

The metered `openai_compatible` lane stays an API-key provider. A
coding document still names one provider for that document's harness
seat and still uses the account's selected model for that seat.
`configureNative` stays the ChatGPT path. Per-document transmission
consent stays. A signed-in plan does not authorize a document or a tool
call.

Sources: ADR 0017, ADR 0030, harness `PaletteTransport`.
