# Intro Screen Design

## Overview

Add an informational intro screen shown after the splash screen and before PIN/Biometry authentication. The screen communicates what the app is, its relationship to the official EUDI Reference Wallet, privacy stance, and legal disclaimers.

Users can dismiss it with a "Don't show again until next update" checkbox. The same content is accessible from Settings via an "About This App" menu item.

## App Flow

```
Splash (1.5s) → [should show intro?] → Intro Screen → PIN/Biometry
                        ↓ no
                   PIN/Biometry (existing flow)
```

## "Don't Show Again" Logic

- New `Prefs.Key`: `introLastDismissedVersion` (String)
- On check + Continue: store current `appVersion` (e.g. `"1.0.0"`)
- On Continue without check: store nothing (intro shows again next launch)
- On app start: show intro if stored version != current `appVersion`, or if no stored value

This means the intro re-appears on every app version update, which is intentional. The checkbox text "Don't show again until next update" sets this expectation.

## Content (main branch — English only)

Scrollable single page with the following sections:

### Header
- App logo (`Theme.shared.image.logo`), small (screenWidth / 5)
- Title: "About This App"

### Sections

**1. What is this app?**
> This app is a clone of the official EU Digital Identity Wallet Reference Implementation. It is maintained by Hopae and kept in sync with the latest official release.
>
> Current version: v{appVersion}

**2. Minimal modifications**
> Minor adjustments have been made solely to meet app store review requirements, including permission descriptions and error handling. Beyond these, the app is identical to the official EUDI Reference Wallet.

**3. Privacy**
> No personal information is collected or transmitted to Hopae. All data remains on your device. This app does not include any analytics or tracking.

**4. Open Source**
> This project is open source. For more information, source code, and issue reporting, visit our GitHub repository.
>
> [github.com/hopae-official/hopae-eudi-ref-wallet](https://github.com/hopae-official/hopae-eudi-ref-wallet)

**5. Disclaimer**
> This app is provided "as is" for testing and demonstration purposes only. It is not intended for production use. Hopae assumes no liability for any use of this application.

### Footer (startup flow only)
- Checkbox: "Don't show again until next update"
- Full-width primary button: "Continue"

### Footer (Settings access)
- No checkbox or Continue button — information viewing only

## UI Design

- Wrapper: `ContentScreenView(canScroll: true)`
- Background: `Theme.shared.color.surface`
- Logo: `Theme.shared.image.logo`, scaled to `screenWidth / 5`
- Title: `Theme.shared.font.headlineMedium`, `color.onSurface`
- Section headings: `Theme.shared.font.titleSmall`, `color.onSurface`
- Section body: `Theme.shared.font.bodyMedium`, `color.onSurfaceVariant`
- Section spacing: `SPACING_MEDIUM`
- GitHub link: tappable cell or inline link button, consistent with existing Settings "Source Repository" pattern
- Checkbox: tappable HStack (checkmark image + label text)
- Continue button: full-width, `Theme.shared.color.primary` background, white text
- Settings variant: same layout, `navigationTitle` "About This App", toolbar back button, no footer

## Architecture

### Module: `feature-startup`

The intro screen lives in `feature-startup` since it's part of the startup flow.

**New files:**
- `IntroView.swift` — SwiftUI view
- `IntroViewModel.swift` — state management, checkbox state, continue action
- `IntroInteractor.swift` — version check logic, prefs read/write

### Route

Add to `FeatureStartupRouteModule`:
```swift
case intro(config: IntroUiConfig)
```

`IntroUiConfig` contains a `showDismissOption: Bool` flag to differentiate between startup (true) and Settings (false) contexts.

### Navigation Integration

**StartupInteractor change:**
After splash delay and before returning the PIN/Biometry route, check if intro should be shown:
- If `introLastDismissedVersion` != current app version → route to intro screen first
- Intro screen's Continue button then triggers the existing PIN/Biometry route

**Route handoff:** The intro route's `IntroUiConfig` carries a `nextRoute: AppRoute` field. StartupInteractor computes the PIN/Biometry route as it does today, then wraps it: if intro should show, return `.featureStartupModule(.intro(config: IntroUiConfig(showDismissOption: true, nextRoute: pinOrBiometryRoute)))`. IntroViewModel's Continue action calls `router.push(with: config.nextRoute)`. This keeps the existing routing logic in StartupInteractor untouched — intro just sits in between.

**SettingsViewModel change:**
Add "About This App" menu item that pushes the intro route with `showDismissOption: false`.

### PrefsController change

Add new key:
```swift
case introLastDismissedVersion
```

## Branch Strategy

**main branch:** Implement the full intro screen with one set of content text (sections above). No variant branching needed.

**edge branch:** After merging main, add an `AppBuildVariant` check. When variant is `EDGE`, replace the text content with edge-specific messaging (emphasizing cutting-edge spec previews, DCQL support, etc.). This is an additive change — no modification to main's existing code.

## Edge Branch Content (for reference — implemented on edge only)

Sections 3 (Privacy), 4 (Open Source), and 5 (Disclaimer) stay the same. Sections 1 and 2 change:

**1. What is this app?**
> This app is an enhanced version of the EU Digital Identity Wallet, maintained by Hopae. It includes early implementations of emerging specifications such as DCQL that are not yet available in the official reference wallet.
>
> Current version: v{appVersion}

**2. Early specification support**
> This build incorporates specifications that are currently at PR or draft level in the official standards process. Features may change as specifications evolve. This allows you to preview and test the latest digital identity capabilities ahead of official adoption.
