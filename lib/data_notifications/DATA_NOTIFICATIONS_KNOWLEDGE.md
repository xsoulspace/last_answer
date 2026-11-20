# DATA_NOTIFICATIONS_KNOWLEDGE.md

**Owns:** the notifications concern — `NotificationMessageModel`
(LocalizedTextModel-based), the local data source, repository, and
`NotificationsNotifier` (update feed + unread flag).

**How to extend:** new notification kinds = model field + repository verb;
state is cold — provider-backed by law (ADR 0036).
