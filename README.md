# DealsDatabase

Database schema definitions for a deal and offer aggregation platform.

## Structure

- `schemas/postgres/` – SQL files for Postgres microservice databases.
- `schemas/mongodb/` – JSON samples for MongoDB collections.

Each microservice owns its database.

## Microservices

1. **Deals Service (Postgres)** – deals, categories, stores, deal types and value added services.
2. **Offers Service (Postgres)** – offer definitions, requirements, benefits and linkage across deals.
3. **User Service (Postgres)** – customer profiles, devices, payment methods and memberships.
4. **Voting Service (Postgres)** – upvotes/downvotes with reaction emojis.
5. **Contest Service (Postgres)** – contest rules, prizes and participants.
6. **Messaging Service (Postgres)** – threads and messages between customers.
7. **Analytics Service (Postgres)** – per-deal and per-user metrics.
8. **Comment Service (Postgres)** – threaded deal discussions and reactions.
9. **Moderation Service (Postgres)** – reports, warnings and moderation logs.
10. **Recommendation Service (Postgres)** – saved deals, hides and view signals.
11. **Price Comparison Service (Postgres)** – product catalog and multi-store prices.
12. **Feeds Service (Postgres)** – curated surfaces like frontpage and trending lists.
13. **Price History Service (MongoDB)** – historic price documents per store & product.
14. **Alerts Service (MongoDB)** – user configured alerts for drops, keywords or stores.
15. **Notifications Service (MongoDB)** – multichannel notification payloads.

These schemas aim to cover a wide feature set for finding the best deals with connected offers.

## Running Tests

This repository only contains schema files; no automated tests are provided yet.
