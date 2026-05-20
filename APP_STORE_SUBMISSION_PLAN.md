# MalaWatch — App Store Submission Plan

## Current Status

- ✅ Core counter UI complete (3D bead wheel, tap + swipe counting)
- ✅ Om Mani Padme Hum chant guide with voice synthesis (Follow / Silent modes)
- ✅ Haptic feedback per bead + completion pulse
- ✅ Bead goals: 27 / 54 / 108
- ✅ Rounds counter + progress tracking
- ✅ Custom label (mantra, prayer, affirmation)
- ✅ 7 bead themes (Sandalwood free, 6 Premium)
- ✅ Apple Watch companion (tap + Digital Crown counting)
- ✅ Offline, no account required
- ✅ Bundle IDs updated: `rkuo.MalaWatch` / `rkuo.MalaWatch.watchkitapp`
- ✅ Swift 6.0 + iOS 18.0 / watchOS 11.0 deployment targets
- ⚠️ **StoreKit 2 IAP not connected** — premium unlock is a fake flag (BLOCKER)
- ⚠️ App icons missing (no Assets.xcassets)
- ✅ Privacy policy hosted: `https://imentos.github.io/MalaWatch/privacy-policy.html`
- ⚠️ Screenshots not taken
- ⚠️ Version needs bump to 1.0.0

---

## 🏪 App Store Listing Metadata

### App Name (30 chars max)
```
MalaWatch: Prayer Bead Counter
```
*(30 chars exactly — includes primary keywords Apple indexes)*

### Subtitle (30 chars max)
```
Mala, Japa & Mantra Tracker
```
*(27 chars — covers japa, mantra, tracker search terms)*

### Keywords Field (100 chars max, no spaces after commas)
```
108,Buddhist,mindfulness,chant,meditation,rosary,affirmation,om,spiritual,zen,Hindu,daily,breath
```
*(98 chars — avoids repeating any word already in name or subtitle)*

**Why each keyword:**
- `108` — sacred bead count, very high-intent search
- `Buddhist` — primary religious audience
- `mindfulness` — secular/wellness crossover, high volume
- `chant` — unique feature (voice chant guide), low competition
- `meditation` — broad discovery traffic
- `rosary` — Catholic users searching for prayer counter (cross-niche)
- `affirmation` — secular daily habit audience
- `om` — directly tied to Om Mani Padme Hum feature
- `spiritual` — broader spiritual seeker traffic
- `zen` — Japanese/secular meditation overlap
- `Hindu` — japa mala is core Hindu practice
- `daily` — habit/routine framing for algorithm
- `breath` — breathwork/pranayama overlap

**Terms NOT in keyword field (Apple already indexes from name/subtitle):**
- `mala`, `prayer`, `bead`, `counter`, `japa`, `mantra`, `tracker`, `watch`

---

### Simplified Chinese Localization

**Subtitle (ZH-CN):**
```
佛珠念珠计数·禅修冥想助手
```

**Keywords (ZH-CN, 100 chars):**
```
佛珠,念珠,念佛,持咒,冥想,禅修,数珠,念经,静心,修行,108,计数,佛教,日课
```

---

### App Description (English)

```
MalaWatch brings your mala practice to iPhone with a beautiful 3D bead wheel, Om Mani Padme Hum chant guide, and gentle haptic feedback on every bead.

COUNT YOUR BEADS
A large tactile bead wheel scrolls as you count — tap or swipe to advance. Every bead gives soft haptic feedback. Reaching 27, 54, or 108 triggers a completion pulse. It feels like holding real beads.

FOLLOW THE CHANT
The Om Mani Padme Hum guide highlights one syllable at a time as you count. Switch to Follow mode and the app speaks each syllable aloud — Om… Ma… Ni… Pad… Me… Hum — keeping your rhythm without needing to look away from your practice.

TRACK YOUR ROUNDS
See completed rounds and current progress at a glance. Set your bead goal to 27, 54, or 108. Your practice saves automatically after every bead.

CHOOSE YOUR BEAD MATERIAL (Premium)
Sandalwood is included free. Unlock Premium for Rosewood, Walnut, Agarwood, Jade, Obsidian, and Graphite — each with its own warm, realistic 3D rendering and background palette.

APPLE WATCH COMPANION (Premium)
Count quietly from your wrist with a tap or the Digital Crown. Glanceable round and progress display. Click haptic per bead, success pattern on completion. Perfect for discrete practice at the temple, on the cushion, or anywhere.

PRIVATE AND OFFLINE
No account. No internet required. Your practice never leaves your device.

WORKS FOR ANY PRACTICE
Whether you chant mantras, count prayers, track affirmations, or practice breathwork — MalaWatch keeps the count so you can keep the focus.

—

MalaWatch Premium (one-time purchase)
• 6 premium bead materials: Rosewood, Walnut, Agarwood, Jade, Obsidian, Graphite
• Apple Watch companion app
• Future ritual packs and seasonal bead styles
```

---

### Promotional Text (170 chars — editable without a new version)
```
Count mantras on a beautiful 3D bead wheel with haptic feedback. Om Mani Padme Hum chant guide included. iPhone + Apple Watch.
```

### What's New (first release)
```
Initial release of MalaWatch.
```

### Category
- **Primary:** Health & Fitness
- **Secondary:** Lifestyle

### Age Rating
- **4+** (no objectionable content)

### Pricing
- **App:** Free
- **In-App Purchase:** MalaWatch Premium — $3.99 (non-consumable, one-time)

---

## 💰 Monetization

### IAP Product

| Field | Value |
|-------|-------|
| Product ID | `rkuo.MalaWatch.premium` |
| Type | Non-Consumable (one-time purchase) |
| Price | $3.99 (Tier 4) |
| Reference Name | MalaWatch Premium |
| Display Name | MalaWatch Premium |
| Description | Unlocks 6 premium bead materials and the Apple Watch companion app. |

**Why one-time, not subscription:**
Meditation/spiritual apps have much lower subscription conversion rates. Users feel a subscription for a ritual tool is extractive. A $3.99 one-time purchase has high perceived value and low friction.

### What Premium Unlocks
- 6 premium bead themes (Rosewood, Walnut, Agarwood, Jade, Obsidian, Graphite)
- Apple Watch companion app
- Future seasonal bead packs

### StoreKit 2 Implementation Needed
The current code has a placeholder:
```swift
// In PremiumUpgradeView:
Button { premiumUnlocked = true; dismiss() } // ← fake unlock, must replace
```

Replace with:
```swift
import StoreKit

// 1. Load product
let products = try await Product.products(for: ["rkuo.MalaWatch.premium"])
guard let product = products.first else { return }

// 2. Purchase
let result = try await product.purchase()
switch result {
case .success(let verification):
    let transaction = try verification.payloadValue
    premiumUnlocked = true
    await transaction.finish()
case .userCancelled, .pending:
    break
}

// 3. Restore on launch
for await result in Transaction.currentEntitlements {
    if let transaction = try? result.payloadValue,
       transaction.productID == "rkuo.MalaWatch.premium" {
        premiumUnlocked = true
    }
}
```

---

## 📱 App Icon Requirements

MalaWatch has no Assets.xcassets. You need to create the app icon before submission.

**Required sizes (App Store + device):**

| Size | Usage |
|------|-------|
| 1024×1024 | App Store (required) |
| 180×180 | iPhone @3x |
| 120×120 | iPhone @2x |
| 87×87 | Settings @3x |
| 58×58 | Settings @2x |
| 40×40 | Spotlight @2x |
| 60×60 | Spotlight @3x |

**watchOS icon sizes also required** (for Watch app):

| Size | Usage |
|------|-------|
| 108×108 | Watch face (large) |
| 100×100 | App launcher |
| 58×58 | Notification center |
| 55×55 | Watch face (small) |

**Icon design direction:**
- Dark warm background (deep sandalwood brown ~#1A0A06)
- A single luminous 3D bead — the current center bead from the app
- Warm golden amber glow to match the sandalwood theme
- Minimal, calm — no text

---

## 📸 Screenshots Plan

### Required Device Sizes
| Display | Resolution | Required? |
|---------|------------|-----------|
| iPhone 6.7" (iPhone 15 Pro Max) | 1290×2796 | ✅ Required |
| iPhone 6.5" (iPhone 14 Plus) | 1242×2688 | Optional |

### 5 Screenshot Sequence

**Screenshot 1 — Hero: The Bead Wheel**
- Screen: Main counter at ~37/108, Sandalwood theme
- Shows: Full 3D bead wheel with the center bead highlighted, Om chant guide at top showing current syllable, round count visible
- Caption idea: "COUNT MANTRAS ON BEAUTIFUL 3D BEADS"
- Why first: Visually distinctive, instantly shows what's different

**Screenshot 2 — Chant Guide in action**
- Screen: Main counter, Follow mode active, "Ni" syllable highlighted in chant bar
- Shows: Chant syllable bar with "Ni" lit up (mid-sequence), bead wheel below
- Caption idea: "HEAR EVERY CHANT SYLLABLE ALOUD"
- Why: Unique feature, no competitor does TTS chant guide

**Screenshot 3 — Theme Selection (Premium)**
- Screen: Settings sheet open, Bead Style section showing all 7 themes with swatches
- Shows: Premium themes with lock icon, Jade or Obsidian swatch looking beautiful
- Caption idea: "CHOOSE YOUR SACRED BEAD MATERIAL"
- Why: Drives premium upsell, shows visual variety

**Screenshot 4 — Round Complete / Progress**
- Screen: Main counter, completed round state (or settings with Rounds: 3, Progress: 100%)
- Shows: Round counter + completed rounds tiles from settings
- Caption idea: "TRACK YOUR DAILY ROUNDS & GOALS"
- Why: Habit/ritual framing, important for retention messaging

**Screenshot 5 — Apple Watch (Premium)**
- Screen: Watch simulator showing WatchCounterView with Jade or Obsidian theme, beads visible
- Shows: Beautiful Watch UI with bead count and Digital Crown hint
- Caption idea: "COUNT QUIETLY FROM YOUR WRIST"
- Why: Premium differentiator, Apple Watch = aspirational

### Simulator Status Bar Setup
Before taking screenshots, clean up the status bar:
```bash
xcrun simctl status_bar "iPhone 15 Pro Max" override \
  --time "9:41" \
  --batteryState charged \
  --batteryLevel 100 \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4
```

---

## 🔒 Privacy Policy

MalaWatch collects no user data. Write a minimal policy and host it.

### Required content
- App name, developer name, contact email
- Data not collected (none)
- No third-party SDKs
- AVSpeechSynthesizer (on-device TTS, no data sent)
- All data stored locally via UserDefaults
- StoreKit purchase handled entirely by Apple

### Hosting (GitHub Pages — live)
- Privacy Policy: `https://imentos.github.io/MalaWatch/privacy-policy.html`
- Terms of Use: `https://imentos.github.io/MalaWatch/terms.html`
- Support: `https://imentos.github.io/MalaWatch/support.html`
- Home: `https://imentos.github.io/MalaWatch/`

### Required privacy survey in App Store Connect
- Data Not Collected
- No tracking
- No third-party analytics

---

## ✅ Full Submission Checklist

### Technical (do first)

- [ ] Connect StoreKit 2 IAP (`rkuo.MalaWatch.premium`)
- [ ] Add restore purchases button to PremiumUpgradeView
- [ ] Check entitlements on launch (Transaction.currentEntitlements)
- [ ] Create app icon (1024×1024 + all device sizes)
- [ ] Add Assets.xcassets to iOS and Watch targets in project.yml
- [ ] Bump MARKETING_VERSION to `1.0.0` in project.yml
- [ ] Run `xcodegen generate` to regenerate Xcode project
- [ ] Build and test on real iPhone (haptics, voice, themes)
- [ ] Test StoreKit sandbox purchase and restore
- [ ] Test on real Apple Watch (Digital Crown, haptics)
- [ ] Wrap debug prints in `#if DEBUG`

### App Store Connect Setup

- [ ] Log into [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Create new App record:
  - Platform: iOS
  - Name: **MalaWatch: Prayer Bead Counter**
  - Primary Language: English (U.S.)
  - Bundle ID: `rkuo.MalaWatch`
  - SKU: `MALAWATCH001`
- [ ] Register `rkuo.MalaWatch` App ID in Developer portal (Certificates, IDs & Profiles)
- [ ] Register `rkuo.MalaWatch.watchkitapp` App ID for Watch target
- [ ] Create IAP product: `rkuo.MalaWatch.premium` (Non-Consumable, $3.99)
- [ ] Set pricing: Free
- [ ] Set availability: All countries

### App Store Listing

- [ ] App Name: `MalaWatch: Prayer Bead Counter`
- [ ] Subtitle: `Mala, Japa & Mantra Tracker`
- [ ] Keywords (English): `108,Buddhist,mindfulness,chant,meditation,rosary,affirmation,om,spiritual,zen,Hindu,daily,breath`
- [ ] Add Simplified Chinese localization with Chinese subtitle + keywords
- [ ] Paste full description (see above)
- [ ] Set Promotional Text (170 chars)
- [ ] Category: Health & Fitness (primary), Lifestyle (secondary)
- [ ] Age Rating: 4+
- [ ] Upload 1024×1024 app icon
- [ ] Upload 5 iPhone 6.7" screenshots
- [ ] Add privacy policy URL: `https://imentos.github.io/MalaWatch/privacy-policy.html`
- [ ] Add support URL: `https://imentos.github.io/MalaWatch/support.html`
- [ ] Add End User License Agreement (EULA) URL: `https://imentos.github.io/MalaWatch/terms.html`
  *(App Store Connect → App Information → End User License Agreement — links your ToU to the IAP purchase flow)*

### Privacy & Compliance

- [x] Write and host privacy policy (`https://imentos.github.io/MalaWatch/privacy-policy.html`)
- [x] Write and host Terms of Use / EULA (`https://imentos.github.io/MalaWatch/terms.html`)
- [x] Write and host support page (`https://imentos.github.io/MalaWatch/support.html`)
- [ ] Complete App Store Connect privacy survey (Data Not Collected)
- [ ] Export compliance: **No** (no custom encryption beyond standard iOS)
- [ ] Content rights: confirm you own all assets

### Build Upload

- [ ] Product → Archive in Xcode
- [ ] Validate archive (catches signing issues)
- [ ] Distribute → App Store Connect → Upload
- [ ] Wait for processing (10–30 minutes)
- [ ] Select build in App Store Connect version page
- [ ] Add What's New: `Initial release of MalaWatch.`
- [ ] Set release: **Manual release** (recommended — release when ready)

### Submit

- [ ] Review all sections show green checkmarks
- [ ] Add for Review → Submit

---

## 🚀 Submission Timeline

### Days 1–2: Fix Technical Blockers
- Connect StoreKit 2 IAP
- Add restore purchases
- Test sandbox purchase on device

### Days 3–4: Assets
- Design and export app icon
- Take 5 screenshots in Simulator
- Clean status bar, rich data in app

### Days 5–6: Metadata & Privacy
- Write privacy policy → host on GitHub Pages
- Fill in all App Store Connect listing fields
- Add Chinese localization

### Days 7–8: Build & Upload
- Archive and upload build
- Complete all checklists in App Store Connect
- Submit for review

### Days 9–10: Review (Apple typical: 24–48h)
- Monitor App Store Connect for status
- Respond quickly to any reviewer questions

### Day 11: Launch
- Manually release once approved
- Share link

---

## 🔧 Common Rejection Risks

| Risk | Prevention |
|------|-----------|
| IAP with no real purchase flow | Must connect StoreKit before submitting |
| Restore purchases missing | Add Restore button to PremiumUpgradeView |
| No privacy policy URL | Host before submitting |
| App crashes on review device | Test on clean iOS 18 device |
| Watch app not working | Reviewer may test Watch — verify pairing |
| AVSpeechSynthesizer requires entitlement | Usually fine, but test on device |

**iOS 18 deployment target note:** iOS 18.0 minimum means devices on iOS 17 won't see the app. By mid-2026 iOS 18 adoption is ~85%+ so acceptable. If you want broader reach, drop to iOS 17 (would require auditing APIs used).

---

## 📊 Post-Launch

### Week 1
- Monitor crash reports in Xcode Organizer
- Respond to all reviews within 24h
- Watch keyword rankings

### Month 2
- v1.1: Add watch complication (shows `37/108`)
- v1.1: iCloud sync across devices

### Month 3+
- A/B test screenshots (which converts better?)
- Add Traditional Chinese localization (Taiwan/HK)
- Consider adding seasonal bead packs (Lunar New Year jade, etc.)

---

## 📚 Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [ASO keyword best practices](https://developer.apple.com/app-store/product-page/)

---

## Technical Reference

### Bundle IDs
| Target | Bundle ID |
|--------|-----------|
| iOS App | `rkuo.MalaWatch` |
| Watch App | `rkuo.MalaWatch.watchkitapp` |
| IAP Product | `rkuo.MalaWatch.premium` |

### Build Settings
| Setting | Value |
|---------|-------|
| MARKETING_VERSION | 1.0.0 |
| CURRENT_PROJECT_VERSION | 1 |
| iOS Deployment Target | 18.0 |
| watchOS Deployment Target | 11.0 |
| Swift Version | 6.0 |
