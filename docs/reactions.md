# Reactions Schema

The voting service stores emoji reactions and precomputed rollups for fast deal ranking.

## Tables

- **reaction_catalog** – allowed emojis with display labels, polarity (`positive`, `negative`, `neutral`), default weights and active flags.
- **reactions** – individual reaction events with user and device context, user weight multipliers and idempotency keys. Rows are soft-deleted via `deleted_at` and carry abuse signals such as `ip_hash` and `user_risk_score`.
- **deal_user_reaction_snapshots** – one row per `(deal_id, user_id)` capturing the current polarity, total emoji count by that user on the deal and `last_action_at` for conflict resolution.
- **deal_reaction_counters** – aggregate totals per deal broken out by polarity and per-emoji counts plus a cached `deal_exists` flag for orphan detection.
- **deal_reaction_hourly_counters** – time bucketed rollups (hourly) used for velocity calculations.
- **deal_scores** – derived fields like `hot_score`, `last_scored_at` and `is_hot` system tag to surface trending deals without recomputation on read.
- **reaction_events** – append-only audit log for add/remove/clear/switch actions.

## Indexing

Indexes on the `reactions` table support hot paths such as lookups by deal, user, `(deal, created_at)` and `(deal, emoji)`. Hourly counters include an index on `(deal_id, bucket_start)` for fast trend queries.
