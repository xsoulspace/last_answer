# DATA_MONETIZATION_KNOWLEDGE.md

**Owns:** the monetization concern — purchases + ads data sources (local
SharedPreferences, remote), repositories, the `PurchasesNotifier` /
`AdsNotifier` state, and the monetization wiring (`monetization.dart` —
RuStore/store selection behind `Envs`).

**How to extend:** a new store backend plugs into `monetization.dart`'s
selection; purchase state changes ride `PurchasesNotifier`. Cold state —
stay notifier-backed (ADR 0036: ECS is for hot paths, not settings).
