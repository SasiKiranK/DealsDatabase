# Offer Types

This document enumerates the canonical list of offer types used in the Deals Database and outlines the mandatory and optional fields for each type. Examples are provided to help authors create consistent offers across the platform.

## Coupon
* **Definition:** A promotional code that users enter at checkout to receive a discount.
* **Required fields:** `code`
* **Optional fields:** `min_cart`, `max_uses`, `category_includes`
* **Example:** `SAVE10` gives 10% off orders above $50.

## Credit Card Offer
* **Definition:** Discount or cashback available when paying with a specific credit card issuer.
* **Required fields:** `issuer`, `card_type`
* **Optional fields:** `network`, `bin_ranges`, `category_includes`
* **Example:** 5% cashback on HDFC Bank credit cards.

## EMI
* **Definition:** Installment-based payment plan that may include subvention or zero interest.
* **Required fields:** `issuer`, `tenure_options`
* **Optional fields:** `no_cost`, `processing_fee`, `subvention_party`
* **Example:** No-cost EMI for 6 months on select credit cards.

## Cashback
* **Definition:** Amount or percentage returned to the user after completing the transaction.
* **Required fields:** `cashback_amount` or `cashback_percent`
* **Optional fields:** `cashback_type` (instant or delayed), `cap`
* **Example:** ₹100 cashback on orders above ₹500.

## Wallet
* **Definition:** Offer tied to payments made through a digital wallet.
* **Required fields:** `wallet_provider`
* **Optional fields:** `user_segment`, `platform`
* **Example:** 10% back when paying with Paytm wallet.

## Membership
* **Definition:** Perks available only to members of a loyalty or subscription program.
* **Required fields:** `program_name`
* **Optional fields:** `tier`, `user_segment`
* **Example:** Extra 5% off for Prime members.

## Exchange
* **Definition:** Discounts or bonuses when exchanging an old item for a new one.
* **Required fields:** `accepted_categories`
* **Optional fields:** `brand_includes`, `condition_tiers`
* **Example:** Up to ₹5,000 off when exchanging eligible smartphones.

---
These definitions provide a baseline for structured offers. Additional fields can be added in `attrs` for edge cases, but core data should use typed columns.
