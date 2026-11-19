# DATA_AGENTS_KNOWLEDGE.md

**Owns:** the agent APIs — the article's data_remote_api analog. Subfolders:
`harness/` (in-process ACP v1 daemon composition: HarnessHost, session
controller, turn queue, cutoff, headless CLI), `acp/` (external ACP agents as
actors), `subscriptions/` (ChatGPT + Grok gateway sets — twins, dedup pending
per ADR 0031), `supervised/` (oka supervisor DesiredState adapter),
`meaning/` (the greeting experiment flow), `product/` (product_* operations),
`config/` (model/provider/device config + permission doc router),
`project_operations/` (oka-owned execution glue).

**How to extend:** a new agent transport = a subfolder (client + contract +
io/stub conditional pair) + one line here. UI surfaces read through this
barrel; the gateways' secure-storage lanes stay in their subfolders.
