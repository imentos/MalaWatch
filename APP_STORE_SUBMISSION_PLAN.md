# MalaWatch - App Store Submission Plan

## Current Status

- Core counter UI complete: 3D bead wheel, swipe counting, haptics.
- 唵嘛呢叭咪吽 chant guide complete with Follow / Silent voice modes.
- Bead goals complete: 27 / 54 / 108.
- Round counter and progress tracking complete.
- Seven bead themes included for all users.
- Apple Watch app included for all users: tap and Digital Crown counting.
- App is offline and requires no account.
- Bundle IDs configured: `rkuo.MalaWatch` / `rkuo.MalaWatch.watchkitapp`.
- Swift 6.0, iOS 18.0, watchOS 11.0.
- App icon is present for iOS and watchOS.
- iPhone portrait-only orientation is configured.
- Privacy policy, terms, support page are hosted on GitHub Pages.
- No In-App Purchases in the current submission.
- No paywall, unlock button, restore purchases button, StoreKit flow, or paid Apple Watch claim in the app.
- Chinese App Store upload copy is available in `APP_STORE_SUBMISSION_PLAN_ZH.md`.
- Japanese App Store upload copy is available in `APP_STORE_SUBMISSION_PLAN_JA.md`.
- Bhutan / English (U.K.) App Store upload copy is available in `APP_STORE_SUBMISSION_PLAN_BT.md`.

## App Store Listing Metadata

### App Name

```text
MalaWatch: Prayer Bead Counter
```

### Subtitle

```text
Mala, Japa & Mantra Tracker
```

### Keywords

```text
108,Buddhist,mindfulness,chant,meditation,rosary,affirmation,om,spiritual,zen,Hindu,daily,breath
```

### Simplified Chinese Localization

Subtitle:

```text
佛珠念珠计数·禅修冥想助手
```

Keywords:

```text
佛珠,念珠,念佛,持咒,冥想,禅修,数珠,念经,静心,修行,108,计数,佛教,日课
```

## App Description

```text
The mala counter that actually feels like practice.

MalaWatch gives you a tactile 3D bead wheel, 唵嘛呢叭咪吽 chant guidance, voice support, and haptic feedback on every bead - on iPhone and Apple Watch.

FEEL EVERY BEAD
A weighted 3D bead wheel moves as you count. Swipe down to advance one bead. Every bead returns a soft haptic click. Reaching your goal - 27, 54, or 108 - sends a completion pulse and starts the next round.

HEAR THE CHANT
The 唵嘛呢叭咪吽 guide lights up one syllable at a time as you count. In Follow mode, the app speaks each syllable aloud - 唵、嘛、呢、叭、咪、吽 - so your eyes and breath can stay with your practice instead of the screen. In Silent mode, the syllable guide stays visual only.

TRACK YOUR ROUNDS
Your bead count and completed rounds are always visible. Progress saves automatically, so you can leave and return to your practice without losing your place.

COUNT FROM YOUR WRIST
The Apple Watch app lets you count privately from your wrist with tap or Digital Crown input, haptic feedback on each bead, and a completion haptic at the end of a round.

CHOOSE YOUR BEAD STYLE
Choose from seven included bead styles: Basic Wood, Rosewood, Walnut, Agarwood, Jade, Obsidian, and Graphite. Each style has its own color palette and 3D bead feel.

PRIVATE AND OFFLINE
No account. No login. No internet connection required. Your practice data stays on your device.

WORKS FOR ANY TRADITION
Buddhist japa, Catholic rosary, Hindu mantra, breathwork rounds, affirmations, or any counting practice - MalaWatch holds the count so your mind does not have to.

Terms of Use: https://imentos.github.io/MalaWatch/terms.html
Privacy Policy: https://imentos.github.io/MalaWatch/privacy-policy.html
```

### Promotional Text

```text
Count mantras on a tactile 3D bead wheel with haptic feedback, 唵嘛呢叭咪吽 guidance, and Apple Watch support.
```

### What's New

```text
Initial release of MalaWatch.
```

### Category

- Primary: Health & Fitness
- Secondary: Lifestyle

### Age Rating

- 4+

### Pricing

- App: Free
- In-App Purchases: None in the current submission

## Review Notes

Use this in App Review Information if needed:

```text
MalaWatch does not require an account or login.

This build does not offer In-App Purchases. All current features, including Apple Watch support and bead styles, are included without purchase.

The app is an offline mala / prayer bead counter for iPhone and Apple Watch. Core flows: launch the app, swipe down on the 3D bead wheel to count, follow the 唵嘛呢叭咪吽 syllable guide, change the bead goal between 27/54/108, choose a bead style, switch voice mode between Follow and Silent, and reset the current round.

MalaWatch does not collect user data, does not use third-party SDKs, and does not require network access for core functionality. Voice guidance uses Apple's on-device AVSpeechSynthesizer.
```

## Screenshot Plan

### Required Device Sizes

| Display | Resolution | Required |
|---|---:|---|
| iPhone 6.7 inch | 1290 x 2796 | Yes |
| iPhone 6.5 inch | 1242 x 2688 | Optional |

### Screenshot Sequence

1. Hero bead wheel
   - Main counter around 37/108.
   - Shows 3D bead wheel, current syllable, round/progress line.
   - Caption: `COUNT MANTRAS ON BEAUTIFUL 3D BEADS`

2. Chant guide
   - Main counter with Follow mode active and a mid-sequence syllable highlighted.
   - Caption: `FOLLOW OM MANI PADME HUM`

3. Bead styles
   - Settings sheet open, showing all seven included bead styles.
   - Caption: `CHOOSE YOUR BEAD STYLE`

4. Goals and progress
   - Settings or main view showing 27/54/108 and round progress.
   - Caption: `TRACK YOUR DAILY ROUNDS`

5. Apple Watch
   - Watch app showing bead count and Digital Crown/tap counting experience.
   - Caption: `COUNT QUIETLY FROM YOUR WRIST`

## Privacy Policy

MalaWatch collects no user data.

Required App Store privacy answers:

- Data Collection: Data Not Collected
- Tracking: No
- Third-party analytics: No
- Account creation: No
- Network requirement: No for core functionality

Hosted pages:

- Privacy Policy: `https://imentos.github.io/MalaWatch/privacy-policy.html`
- Terms of Use: `https://imentos.github.io/MalaWatch/terms.html`
- Support: `https://imentos.github.io/MalaWatch/support.html`
- Home: `https://imentos.github.io/MalaWatch/`

## Submission Checklist

### Technical

- [x] Remove all IAP, unlock, restore, and paid Apple Watch UI from the app.
- [x] Include Apple Watch support without purchase.
- [x] Include all bead styles without purchase.
- [x] Add app icon assets.
- [x] Configure portrait-only iPhone orientation.
- [x] Set bundle IDs.
- [x] Build iOS target.
- [x] Build watchOS target.
- [x] Archive release build.
- [ ] Test on physical iPhone.
- [ ] Test on physical Apple Watch if available.
- [ ] Capture physical-device screen recording for App Review.

### App Store Connect

- [ ] Remove any In-App Purchase products from this app version.
- [ ] Confirm pricing is Free.
- [ ] Confirm metadata does not mention unlocks, paid Apple Watch, or paid themes.
- [ ] Add App Review Notes saying this build has no IAP and all current features are included.
- [ ] Upload iPhone screenshots showing actual app use.
- [ ] Add privacy policy URL.
- [ ] Add support URL.
- [ ] Add terms URL if desired.
- [ ] Complete privacy survey as Data Not Collected.
- [ ] Submit for review.

## Common Rejection Risks

| Risk | Prevention |
|---|---|
| IAP button does nothing | Current build has no IAP UI. |
| Missing Restore Purchases | Current build has no IAP, so Restore is not needed. |
| Charging for Apple Watch | Watch support is included for all users. |
| Metadata still mentions paid features | Remove paid-feature wording from description, screenshots, review notes, and IAP section. |
| Reviewer cannot see core flow | Provide physical-device recording starting from app launch. |
| iPad landscape looks wrong | iPhone app is portrait-only and targeted to iPhone. |

## Future Monetization

Do not charge for Apple Watch support or basic device capabilities.

Safer future options:

- Make the app paid upfront.
- Add an optional tip jar / supporter purchase that does not unlock required features.
- Sell extra creative content only, such as additional bead art packs, bell sounds, guided chant recordings, or seasonal ritual packs.
- Keep core counting, Apple Watch support, reset, 27/54/108 goals, and current included themes available without purchase unless the entire app becomes paid upfront.

If adding IAP later:

- Implement real StoreKit 2 purchase flow.
- Add a distinct Restore Purchases button.
- Test purchase and restore in sandbox on physical devices.
- Ensure App Store Connect has a Paid Apps Agreement in effect.
- Do not market Apple Watch access as a paid feature.

## Technical Reference

| Target | Bundle ID |
|---|---|
| iOS App | `rkuo.MalaWatch` |
| Watch App | `rkuo.MalaWatch.watchkitapp` |

| Setting | Value |
|---|---|
| MARKETING_VERSION | 0.1.0 |
| CURRENT_PROJECT_VERSION | 3 |
| iOS Deployment Target | 18.0 |
| watchOS Deployment Target | 11.0 |
| Swift Version | 6.0 |
