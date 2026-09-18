# Beacons Pro — ASO Plan

**App:** Beacons Pro (Apple ID 1587012836) · Developer Tools · iOS 17.6+ / iPadOS / macOS (Apple Silicon) / visionOS
**Plan created:** September 10, 2026
**Baseline:** ASO score 46/100 · ~$10–12/month · ~6–7 sales/month · no visible rating · English only

## Goal

Grow passive revenue from ~$12/month to $50–70/month within 90 days by fixing discoverability (title keywords, keyword field, localization) and conversion (visible star rating, screenshot order, preview video) — with near-zero ongoing maintenance.

## Why the app sells at all

All revenue comes from organic App Store search by high-intent buyers (developers and field technicians who need an iBeacon tool for work today). There is no other funnel. Every action in this plan either widens that search surface or converts more of the people already landing on the page.

---

## Phase 0 — Done

- [x] Price raised from $1.99 (verify new price is live in App Store Connect — US listing still showed $1.99 on Sep 10)
- [x] Engagement-gated review prompt implemented and pushed (`bbd8b34`, Sep 10, 2026) — ships with v2.1
- [x] Verify Small Business Program enrollment (15% commission instead of 30%)

## Phase 1 — Ship with v2.1 (target: week of September 14, 2026)

Metadata only takes effect with a version release, so bundle everything into one submission.

- [ ] **Title** (28/30 chars): `Beacons Pro: iBeacon Scanner`
- [ ] **Subtitle** (29/30 chars): `BLE Beacon Broadcaster & RSSI`
- [ ] **Keyword field** (100/100 chars):
  `bluetooth,eddystone,uuid,transmitter,simulator,proximity,signal,detector,tracker,ranging,monitor,tag`
- [ ] **Promotional text** (updatable anytime, no review needed):
  "v2.1 — live radar, RSSI charts, fleet management and CSV export. One price. No subscriptions, no ads, ever."
- [ ] **Description hook** — replace the first three lines with the job-to-be-done:
  "Debugging a beacon deployment? See every iBeacon around you — live RSSI, distance, and signal history — and turn your iPhone into a beacon transmitter."
- [ ] **What's New** for 2.1 — lead with a user-facing improvement, not "bug fixes"
- [ ] Archive, submit, release v2.1 (contains the review prompt — the single highest-impact item in this plan)

**Indexed roots after this change (18):** ibeacon, scanner, ble, beacon, broadcaster, rssi, bluetooth, eddystone, uuid, transmitter, simulator, proximity, signal, detector, tracker, ranging, monitor, tag — plus all phrase combinations ("ibeacon simulator", "bluetooth scanner", "beacon transmitter", …).

Rationale notes:
- Title/subtitle/keyword field index as one pool — never repeat a word across them.
- Category words ("developer", "tools") are indexed automatically — never spend field chars on them.
- `simulator` deliberately targets Beacon Walker's audience (they charge $99 lifetime for simulation alone).
- `airtag` excluded: trademark-adjacent, inconsistent App Review risk, marginal relevance.

## Phase 2 — Creative refresh (target: by September 30, 2026)

Source of truth: `Beacons Pro/Views/Screenshots/AppStoreScreenshots.swift` (8 iPhone + 2 iPad shots already built).

- [ ] **Reorder screenshots** — first three must be the differentiators:
  1. Real-Time Beacon Radar
  2. Broadcast as a Beacon ("Turn your iPhone into an iBeacon transmitter")
  3. Signal Analytics (RSSI charts)
- [ ] **Drop as standalone subjects:** onboarding ("Welcome to Beacons Pro") and "Beautiful Dark Mode" — use dark mode as the *style* of a feature shot instead
- [ ] **Fill all 10 slots** (add fleet management, export, live monitoring, UUID tools)
- [ ] **App preview video** (15–20s screen capture, no editing needed): radar detecting a live beacon → open analytics chart → start a broadcast. Captions burned in; must work without sound
- [ ] Keep the icon — orange radar on black is distinctive and correct

## Phase 3 — Localization (target: by October 31, 2026)

Metadata-only localization (title/subtitle/keywords/captions). The app itself stays English — buyers of a dev tool accept that; localized keywords index separately per storefront and multiply the search surface.

- [ ] **Japanese** — largest beacon/retail-IoT market
- [ ] **German** — industrial IoT
- [ ] **Simplified Chinese** — hardware makers
- [ ] Localize screenshot captions in `AppStoreScreenshots.swift` for those three locales

## Phase 4 — Ongoing cadence (from November 2026)

- [ ] Ship a release every 6–8 weeks, however small — fresh "last updated" is a ranking and trust signal (the May → September gap read as abandonment)
- [ ] Rotate promotional text around events (WWDC, embedded/IoT conference seasons)
- [ ] Respond to every review within a week (Developer Tools apps get few — each response is visible)
- [ ] Revisit price after 60 days of data; if unit sales hold, test the next tier up
- [ ] Consider: dedicated Mac App Store positioning (already runs on Apple Silicon; Mac Developer Tools chart is far less crowded)

---

## KPIs — check monthly in App Store Connect

| Metric | Baseline (Sep 2026) | 90-day target |
|---|---|---|
| Revenue / month | $10–12 | $50–70 |
| Unit sales / month | 6–7 | 12–15 |
| Visible rating (US) | none | 4.5★+, 5+ ratings |
| Impressions / month | (record at v2.1 launch) | +100% |
| Conversion rate (page view → sale) | (record at v2.1 launch) | +30% |
| Storefronts with localized metadata | 1 | 4 |

**Review-prompt health check (December 2026):** confirm ratings are accumulating; if fewer than 5 after 90 days, lower `minimumScore` in `ReviewPromptService.swift` from 4 to 3.

## Competitive positioning (for all copy decisions)

One line: **"Scan, analyze, and broadcast iBeacons — one price, no subscription."**

| | Beacons Pro | BLE Scanner 4.0 | Beacon Walker | NanoBeacon |
|---|---|---|---|---|
| Model | one-time purchase | free + IAP | $4.99/mo or $99 lifetime | free |
| Scan + broadcast + analytics | ✅ all three | scan-focused | simulate-focused | scan only |
| Rating | building via v2.1 | 4.3★ (615) | 4.0★ (3) | 4.2★ (5) |

The wedge: competitors either subscribe you or do one job. Every screenshot caption, description line, and promotional text should reinforce "complete toolkit, one honest price."
