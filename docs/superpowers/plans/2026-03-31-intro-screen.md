# Intro Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an informational intro screen after splash, before PIN/Biometry, with "don't show again until next update" and Settings access.

**Architecture:** New IntroView/IntroViewModel/IntroInteractor in `feature-startup` module following existing MVVM+Interactor pattern. StartupInteractor routes to intro when version mismatch detected. Settings gets a new "About This App" menu item that pushes the same screen without dismiss controls.

**Tech Stack:** SwiftUI, Swinject DI, Cuckoo mocks, XCTest

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `Modules/logic-business/Sources/Controller/PrefsController.swift` | Add `introLastDismissedVersion` key |
| Modify | `Modules/logic-resources/Sources/Localizable/LocalizableStringKey.swift` | Add new string keys |
| Modify | `Modules/logic-resources/Sources/Manager/LocalizableManager.swift` | Map new keys to localized strings |
| Modify | `Modules/logic-resources/Sources/Resources/Localizable.xcstrings` | Add localized string values |
| Create | `Modules/feature-startup/Sources/UI/Intro/IntroView.swift` | Intro screen SwiftUI view |
| Create | `Modules/feature-startup/Sources/UI/Intro/IntroViewModel.swift` | State management, continue/dismiss logic |
| Create | `Modules/feature-startup/Sources/Interactor/IntroInteractor.swift` | Version check, prefs read/write |
| Modify | `Modules/feature-startup/Sources/DI/FeatureStartupAssembly.swift` | Register IntroInteractor |
| Modify | `Modules/logic-ui/Sources/Navigation/AppRoute.swift` | Add `.intro` route case |
| Modify | `Modules/feature-startup/Sources/Router/StartupRouter.swift` | Resolve intro route to IntroView |
| Modify | `Modules/feature-startup/Sources/Interactor/StartupInteractor.swift` | Add intro routing logic |
| Modify | `Modules/feature-dashboard/Sources/UI/Settings/SettingsViewModel.swift` | Add "About This App" menu item |
| Modify | `Modules/feature-startup/Tests/Interactor/TestStartupInteractor.swift` | Tests for intro routing |
| Create | `Modules/feature-startup/Tests/Interactor/TestIntroInteractor.swift` | Tests for IntroInteractor |

---

### Task 1: Add `introLastDismissedVersion` Prefs Key

**Files:**
- Modify: `Modules/logic-business/Sources/Controller/PrefsController.swift:72-78`

- [ ] **Step 1: Add the new key to Prefs.Key enum**

In `Modules/logic-business/Sources/Controller/PrefsController.swift`, add to the `Prefs.Key` enum:

```swift
public extension Prefs {
  enum Key: String {
    case biometryEnabled
    case cachedDeepLink
    case runAtLeastOnce
    case language
    case introLastDismissedVersion
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add Modules/logic-business/Sources/Controller/PrefsController.swift
git commit -m "Add introLastDismissedVersion prefs key"
```

---

### Task 2: Add Localization Keys

**Files:**
- Modify: `Modules/logic-resources/Sources/Localizable/LocalizableStringKey.swift`
- Modify: `Modules/logic-resources/Sources/Manager/LocalizableManager.swift`
- Modify: `Modules/logic-resources/Sources/Resources/Localizable.xcstrings`

- [ ] **Step 1: Add enum cases to LocalizableStringKey**

In `Modules/logic-resources/Sources/Localizable/LocalizableStringKey.swift`, add after the `case settings` line (line 239):

```swift
  case aboutThisApp
  case introWhatIsThisApp
  case introWhatIsThisAppBody
  case introCurrentVersion([String])
  case introMinimalModifications
  case introMinimalModificationsBody
  case introPrivacy
  case introPrivacyBody
  case introOpenSource
  case introOpenSourceBody
  case introDisclaimer
  case introDisclaimerBody
  case introDontShowAgain
  case introContinue
```

- [ ] **Step 2: Add case mappings in LocalizableManager**

In `Modules/logic-resources/Sources/Manager/LocalizableManager.swift`, add the case mappings in the `get(with:)` switch statement (after the `.settings` case around line 472):

```swift
    case .aboutThisApp:
      bundle.localizedString(forKey: "about_this_app")
    case .introWhatIsThisApp:
      bundle.localizedString(forKey: "intro_what_is_this_app")
    case .introWhatIsThisAppBody:
      bundle.localizedString(forKey: "intro_what_is_this_app_body")
    case .introCurrentVersion(let args):
      bundle.localizedStringWithArguments(forKey: "intro_current_version", arguments: args)
    case .introMinimalModifications:
      bundle.localizedString(forKey: "intro_minimal_modifications")
    case .introMinimalModificationsBody:
      bundle.localizedString(forKey: "intro_minimal_modifications_body")
    case .introPrivacy:
      bundle.localizedString(forKey: "intro_privacy")
    case .introPrivacyBody:
      bundle.localizedString(forKey: "intro_privacy_body")
    case .introOpenSource:
      bundle.localizedString(forKey: "intro_open_source")
    case .introOpenSourceBody:
      bundle.localizedString(forKey: "intro_open_source_body")
    case .introDisclaimer:
      bundle.localizedString(forKey: "intro_disclaimer")
    case .introDisclaimerBody:
      bundle.localizedString(forKey: "intro_disclaimer_body")
    case .introDontShowAgain:
      bundle.localizedString(forKey: "intro_dont_show_again")
    case .introContinue:
      bundle.localizedString(forKey: "intro_continue")
```

- [ ] **Step 3: Add string values to Localizable.xcstrings**

Add the following entries to the `strings` object in `Modules/logic-resources/Sources/Resources/Localizable.xcstrings`. Follow the existing JSON pattern — each entry has a `localizations.en.stringUnit` with `state: "translated"` and the `value`. The entries to add:

| Key | Value |
|-----|-------|
| `about_this_app` | `About This App` |
| `intro_what_is_this_app` | `What is this app?` |
| `intro_what_is_this_app_body` | `This app is a clone of the official EU Digital Identity Wallet Reference Implementation. It is maintained by Hopae and kept in sync with the latest official release.` |
| `intro_current_version` | `Current version: v%@` |
| `intro_minimal_modifications` | `Minimal modifications` |
| `intro_minimal_modifications_body` | `Minor adjustments have been made solely to meet app store review requirements, including permission descriptions and error handling. Beyond these, the app is identical to the official EUDI Reference Wallet.` |
| `intro_privacy` | `Privacy` |
| `intro_privacy_body` | `No personal information is collected or transmitted to Hopae. All data remains on your device. This app does not include any analytics or tracking.` |
| `intro_open_source` | `Open Source` |
| `intro_open_source_body` | `This project is open source. For more information, source code, and issue reporting, visit our GitHub repository.` |
| `intro_disclaimer` | `Disclaimer` |
| `intro_disclaimer_body` | `This app is provided "as is" for testing and demonstration purposes only. It is not intended for production use. Hopae assumes no liability for any use of this application.` |
| `intro_dont_show_again` | `Don't show again until next update` |
| `intro_continue` | `Continue` |

- [ ] **Step 4: Commit**

```bash
git add Modules/logic-resources/Sources/Localizable/LocalizableStringKey.swift \
       Modules/logic-resources/Sources/Manager/LocalizableManager.swift \
       Modules/logic-resources/Sources/Resources/Localizable.xcstrings
git commit -m "Add intro screen localization keys and strings"
```

---

### Task 3: Add Intro Route to AppRoute

**Files:**
- Modify: `Modules/logic-ui/Sources/Navigation/AppRoute.swift:22-31`

- [ ] **Step 1: Add intro case to FeatureStartupRouteModule**

In `Modules/logic-ui/Sources/Navigation/AppRoute.swift`, add the `intro` case to `FeatureStartupRouteModule`:

```swift
public enum FeatureStartupRouteModule: AppRouteModule {

  case startup
  case intro(config: IntroUiConfig)

  public var info: (key: String, arguments: [String: String]) {
    return switch self {
    case .startup:
      (key: "Startup", arguments: [:])
    case .intro(let config):
      (key: "Intro", arguments: ["config": config.log])
    }
  }
}
```

- [ ] **Step 2: Add IntroUiConfig struct in the same file**

Add above the `FeatureStartupRouteModule` enum in `AppRoute.swift`:

```swift
public struct IntroUiConfig: UIConfigType, Equatable {
  public let showDismissOption: Bool
  public let nextRoute: AppRoute?

  public var log: String {
    "showDismissOption: \(showDismissOption)"
  }

  public init(showDismissOption: Bool, nextRoute: AppRoute? = nil) {
    self.showDismissOption = showDismissOption
    self.nextRoute = nextRoute
  }

  public static func == (lhs: IntroUiConfig, rhs: IntroUiConfig) -> Bool {
    lhs.showDismissOption == rhs.showDismissOption
  }
}
```

Note: `nextRoute` is `AppRoute?` — nil when opened from Settings (no continue destination). `Equatable` only compares `showDismissOption` because `AppRoute` doesn't conform to `Equatable` (it has associated values with protocols).

- [ ] **Step 3: Commit**

```bash
git add Modules/logic-ui/Sources/Navigation/AppRoute.swift
git commit -m "Add intro route and IntroUiConfig to AppRoute"
```

---

### Task 4: Create IntroInteractor

**Files:**
- Create: `Modules/feature-startup/Sources/Interactor/IntroInteractor.swift`

- [ ] **Step 1: Write TestIntroInteractor test file**

Create `Modules/feature-startup/Tests/Interactor/TestIntroInteractor.swift`:

```swift
import XCTest
import logic_business
@testable import feature_startup
@testable import logic_test
@testable import feature_test
@testable import feature_common

final class TestIntroInteractor: EudiTest {

  var interactor: IntroInteractor!
  var prefsController: MockPrefsController!
  var configLogic: MockConfigLogic!

  override func setUp() {
    self.prefsController = MockPrefsController()
    self.configLogic = MockConfigLogic()
    self.interactor = IntroInteractorImpl(
      prefsController: prefsController,
      configLogic: configLogic
    )
  }

  override func tearDown() {
    self.interactor = nil
    self.prefsController = nil
    self.configLogic = nil
  }

  func testShouldShowIntro_WhenNoDismissedVersion_ThenReturnsTrue() async {
    // Given
    stub(prefsController) { mock in
      when(mock.getString(forKey: Prefs.Key.introLastDismissedVersion)).thenReturn(nil)
    }
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.0.0")
    }
    // When
    let result = await interactor.shouldShowIntro()
    // Then
    XCTAssertTrue(result)
  }

  func testShouldShowIntro_WhenDismissedVersionMatchesCurrent_ThenReturnsFalse() async {
    // Given
    stub(prefsController) { mock in
      when(mock.getString(forKey: Prefs.Key.introLastDismissedVersion)).thenReturn("1.0.0")
    }
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.0.0")
    }
    // When
    let result = await interactor.shouldShowIntro()
    // Then
    XCTAssertFalse(result)
  }

  func testShouldShowIntro_WhenDismissedVersionDiffersFromCurrent_ThenReturnsTrue() async {
    // Given
    stub(prefsController) { mock in
      when(mock.getString(forKey: Prefs.Key.introLastDismissedVersion)).thenReturn("0.9.0")
    }
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.0.0")
    }
    // When
    let result = await interactor.shouldShowIntro()
    // Then
    XCTAssertTrue(result)
  }

  func testDismissIntro_StoresCurrentVersion() async {
    // Given
    stub(prefsController) { mock in
      when(mock.setValue(any(), forKey: any())).thenDoNothing()
    }
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.0.0")
    }
    // When
    await interactor.dismissIntro()
    // Then
    verify(prefsController).setValue(equal(to: "1.0.0", type: String.self), forKey: Prefs.Key.introLastDismissedVersion)
  }

  func testGetAppVersion_ReturnsConfigVersion() async {
    // Given
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.2.3")
    }
    // When
    let version = await interactor.getAppVersion()
    // Then
    XCTAssertEqual(version, "1.2.3")
  }

  func testGetGitHubUrl_ReturnsExpectedUrl() async {
    // When
    let url = await interactor.getGitHubUrl()
    // Then
    XCTAssertEqual(url, URL(string: "https://github.com/hopae-official/hopae-eudi-ref-wallet"))
  }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/daniel/.grove/github.com/hopae-official/hopae-eudi-ref-wallet/worktrees/intro-screen && xcodebuild test -scheme "EUDI Wallet Dev" -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:feature-startup-tests/TestIntroInteractor 2>&1 | tail -20`

Expected: Build failure — `IntroInteractor` not defined yet.

- [ ] **Step 3: Create IntroInteractor implementation**

Create `Modules/feature-startup/Sources/Interactor/IntroInteractor.swift`:

```swift
import Foundation
import logic_business

public protocol IntroInteractor: Sendable {
  func shouldShowIntro() async -> Bool
  func dismissIntro() async
  func getAppVersion() async -> String
  func getGitHubUrl() async -> URL?
}

final actor IntroInteractorImpl: IntroInteractor {

  private let prefsController: PrefsController
  private let configLogic: ConfigLogic

  init(
    prefsController: PrefsController,
    configLogic: ConfigLogic
  ) {
    self.prefsController = prefsController
    self.configLogic = configLogic
  }

  public func shouldShowIntro() -> Bool {
    let dismissedVersion = prefsController.getString(forKey: .introLastDismissedVersion)
    return dismissedVersion != configLogic.appVersion
  }

  public func dismissIntro() {
    prefsController.setValue(configLogic.appVersion, forKey: .introLastDismissedVersion)
  }

  public func getAppVersion() -> String {
    configLogic.appVersion
  }

  public func getGitHubUrl() -> URL? {
    URL(string: "https://github.com/hopae-official/hopae-eudi-ref-wallet")
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `xcodebuild test -scheme "EUDI Wallet Dev" -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:feature-startup-tests/TestIntroInteractor 2>&1 | tail -20`

Expected: All 6 tests PASS.

Note: If mock generation is needed, check if `MockPrefsController` and `MockConfigLogic` already exist in `Modules/feature-startup/Tests/Mock/GeneratedMocks.swift` — they should, as the existing `TestStartupInteractor` uses them.

- [ ] **Step 5: Commit**

```bash
git add Modules/feature-startup/Sources/Interactor/IntroInteractor.swift \
       Modules/feature-startup/Tests/Interactor/TestIntroInteractor.swift
git commit -m "Add IntroInteractor with version-based intro dismissal"
```

---

### Task 5: Create IntroViewModel and IntroView

**Files:**
- Create: `Modules/feature-startup/Sources/UI/Intro/IntroViewModel.swift`
- Create: `Modules/feature-startup/Sources/UI/Intro/IntroView.swift`

- [ ] **Step 1: Create IntroViewModel**

Create `Modules/feature-startup/Sources/UI/Intro/IntroViewModel.swift`:

```swift
import Foundation
import logic_ui
import logic_resources

@Copyable
struct IntroViewState: ViewState {
  let appVersion: String
  let gitHubUrl: URL?
  let showDismissOption: Bool
  let dontShowAgainChecked: Bool
}

final class IntroViewModel<Router: RouterHost>: ViewModel<Router, IntroViewState> {

  private let interactor: IntroInteractor
  private let config: IntroUiConfig

  init(
    router: Router,
    interactor: IntroInteractor,
    config: IntroUiConfig
  ) {
    self.interactor = interactor
    self.config = config
    super.init(
      router: router,
      initialState: .init(
        appVersion: "",
        gitHubUrl: nil,
        showDismissOption: config.showDismissOption,
        dontShowAgainChecked: false
      )
    )
  }

  func initialize() async {
    let appVersion = await interactor.getAppVersion()
    let gitHubUrl = await interactor.getGitHubUrl()
    setState {
      $0.copy(
        appVersion: appVersion,
        gitHubUrl: gitHubUrl
      )
    }
  }

  func toggleDontShowAgain() {
    setState {
      $0.copy(dontShowAgainChecked: !$0.dontShowAgainChecked)
    }
  }

  func onContinue() async {
    if viewState.dontShowAgainChecked {
      await interactor.dismissIntro()
    }
    if let nextRoute = config.nextRoute {
      router.push(with: nextRoute)
    }
  }

  func toolbarContent() -> ToolBarContent {
    .init(
      trailingActions: [],
      leadingActions: config.showDismissOption ? [] : [
        .init(
          image: Theme.shared.image.chevronLeft,
          accessibilityLocator: ToolbarLocators.chevronLeft
        ) {
          self.router.pop()
        }
      ]
    )
  }
}
```

- [ ] **Step 2: Create IntroView**

Create `Modules/feature-startup/Sources/UI/Intro/IntroView.swift`:

```swift
import SwiftUI
import logic_ui
import logic_resources

struct IntroView<Router: RouterHost>: View {

  @State private var viewModel: IntroViewModel<Router>

  init(with viewModel: IntroViewModel<Router>) {
    self._viewModel = State(wrappedValue: viewModel)
  }

  var body: some View {
    ContentScreenView(
      canScroll: true,
      navigationTitle: viewModel.viewState.showDismissOption ? nil : .aboutThisApp,
      toolbarContent: viewModel.toolbarContent()
    ) {
      content(
        viewState: viewModel.viewState,
        screenWidth: getScreenRect().width,
        onToggle: { viewModel.toggleDontShowAgain() },
        onContinue: { Task { await viewModel.onContinue() } }
      )
    }
    .task {
      await viewModel.initialize()
    }
  }
}

@MainActor
@ViewBuilder
private func content(
  viewState: IntroViewState,
  screenWidth: CGFloat,
  onToggle: @escaping () -> Void,
  onContinue: @escaping () -> Void
) -> some View {
  VStack(spacing: SPACING_MEDIUM) {

    if viewState.showDismissOption {
      headerSection(screenWidth: screenWidth)
    }

    sectionView(
      title: .introWhatIsThisApp,
      body: .introWhatIsThisAppBody
    )

    Text(.introCurrentVersion([viewState.appVersion]))
      .typography(Theme.shared.font.bodyMedium)
      .foregroundColor(Theme.shared.color.onSurfaceVariant)
      .frame(maxWidth: .infinity, alignment: .leading)

    sectionView(
      title: .introMinimalModifications,
      body: .introMinimalModificationsBody
    )

    sectionView(
      title: .introPrivacy,
      body: .introPrivacyBody
    )

    sectionView(
      title: .introOpenSource,
      body: .introOpenSourceBody
    )

    if let gitHubUrl = viewState.gitHubUrl {
      Button {
        gitHubUrl.open()
      } label: {
        HStack {
          Text(.sourceRepository)
            .typography(Theme.shared.font.bodyMedium)
            .foregroundColor(Theme.shared.color.primary)
          Spacer()
        }
      }
    }

    sectionView(
      title: .introDisclaimer,
      body: .introDisclaimerBody
    )

    if viewState.showDismissOption {
      dismissSection(
        isChecked: viewState.dontShowAgainChecked,
        onToggle: onToggle,
        onContinue: onContinue
      )
    }
  }
  .padding(.bottom, SPACING_LARGE_MEDIUM)
}

@MainActor
@ViewBuilder
private func headerSection(screenWidth: CGFloat) -> some View {
  VStack(spacing: SPACING_MEDIUM_SMALL) {
    Theme.shared.image.logo
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: screenWidth / 5)

    Text(.aboutThisApp)
      .typography(Theme.shared.font.headlineMedium)
      .foregroundColor(Theme.shared.color.onSurface)
  }
  .frame(maxWidth: .infinity)
  .padding(.bottom, SPACING_MEDIUM)
}

@MainActor
@ViewBuilder
private func sectionView(
  title: LocalizableStringKey,
  body: LocalizableStringKey
) -> some View {
  VStack(alignment: .leading, spacing: SPACING_SMALL) {
    Text(title)
      .typography(Theme.shared.font.titleSmall)
      .foregroundColor(Theme.shared.color.onSurface)

    Text(body)
      .typography(Theme.shared.font.bodyMedium)
      .foregroundColor(Theme.shared.color.onSurfaceVariant)
  }
  .frame(maxWidth: .infinity, alignment: .leading)
}

@MainActor
@ViewBuilder
private func dismissSection(
  isChecked: Bool,
  onToggle: @escaping () -> Void,
  onContinue: @escaping () -> Void
) -> some View {
  VStack(spacing: SPACING_MEDIUM) {
    Button(action: onToggle) {
      HStack(spacing: SPACING_SMALL) {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
          .foregroundColor(
            isChecked
            ? Theme.shared.color.primary
            : Theme.shared.color.onSurfaceVariant
          )
        Text(.introDontShowAgain)
          .typography(Theme.shared.font.bodyMedium)
          .foregroundColor(Theme.shared.color.onSurface)
        Spacer()
      }
    }

    Button(action: onContinue) {
      Text(.introContinue)
        .typography(Theme.shared.font.labelLarge)
        .foregroundColor(Theme.shared.color.onPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, SPACING_MEDIUM_SMALL)
        .background(Theme.shared.color.primary)
        .cornerRadius(Theme.shared.shape.small)
    }
  }
  .padding(.top, SPACING_MEDIUM)
}
```

- [ ] **Step 3: Commit**

```bash
git add Modules/feature-startup/Sources/UI/Intro/IntroViewModel.swift \
       Modules/feature-startup/Sources/UI/Intro/IntroView.swift
git commit -m "Add IntroView and IntroViewModel"
```

---

### Task 6: Wire Up DI, Router, and Startup Flow

**Files:**
- Modify: `Modules/feature-startup/Sources/DI/FeatureStartupAssembly.swift`
- Modify: `Modules/feature-startup/Sources/Router/StartupRouter.swift`
- Modify: `Modules/feature-startup/Sources/Interactor/StartupInteractor.swift`

- [ ] **Step 1: Register IntroInteractor in DI**

In `Modules/feature-startup/Sources/DI/FeatureStartupAssembly.swift`, add the IntroInteractor registration after the StartupInteractor registration:

```swift
public final class FeatureStartupAssembly: Assembly {

  public init() {}

  public func assemble(container: Container) {
    container.register(StartupInteractor.self) { r in
      StartupInteractorImpl(
        walletKitController: r.force(WalletKitController.self),
        quickPinInteractor: r.force(QuickPinInteractor.self),
        keyChainController: r.force(KeyChainController.self),
        prefsController: r.force(PrefsController.self),
        configLogic: r.force(ConfigLogic.self)
      )
    }
    .inObjectScope(ObjectScope.transient)

    container.register(IntroInteractor.self) { r in
      IntroInteractorImpl(
        prefsController: r.force(PrefsController.self),
        configLogic: r.force(ConfigLogic.self)
      )
    }
    .inObjectScope(ObjectScope.transient)
  }
}
```

- [ ] **Step 2: Add intro case to StartupRouter**

In `Modules/feature-startup/Sources/Router/StartupRouter.swift`, add the `.intro` case:

```swift
@MainActor
public final class StartupRouter {

  @ViewBuilder
  public static func resolve(module: FeatureStartupRouteModule, host: some RouterHost) -> some View {
    switch module {
    case .startup:
      StartupView(
        with: .init(
          router: host,
          interactor: DIGraph.shared.resolver.force(
            StartupInteractor.self
          )
        )
      )
    case .intro(let config):
      IntroView(
        with: .init(
          router: host,
          interactor: DIGraph.shared.resolver.force(
            IntroInteractor.self
          ),
          config: config
        )
      )
    }
  }
}
```

- [ ] **Step 3: Modify StartupInteractor to route through intro**

In `Modules/feature-startup/Sources/Interactor/StartupInteractor.swift`, add `IntroInteractor` dependency and modify `initialize()`:

```swift
final actor StartupInteractorImpl: StartupInteractor {

  private let walletKitController: WalletKitController
  private let quickPinInteractor: QuickPinInteractor
  private let keyChainController: KeyChainController
  private let prefsController: PrefsController
  private let configLogic: ConfigLogic
  private let introInteractor: IntroInteractor

  init(
    walletKitController: WalletKitController,
    quickPinInteractor: QuickPinInteractor,
    keyChainController: KeyChainController,
    prefsController: PrefsController,
    configLogic: ConfigLogic,
    introInteractor: IntroInteractor
  ) {
    self.walletKitController = walletKitController
    self.quickPinInteractor = quickPinInteractor
    self.keyChainController = keyChainController
    self.prefsController = prefsController
    self.configLogic = configLogic
    self.introInteractor = introInteractor
  }

  public func initialize(with splashAnimationDuration: TimeInterval) async -> AppRoute {
    await manageStorageForFirstRun()
    try? await walletKitController.loadDocuments()
    let hasDocuments = await !walletKitController.fetchAllDocuments().isEmpty
    try? await Task.sleep(nanoseconds: splashAnimationDuration.nanoseconds)

    let authRoute = await buildAuthRoute(hasDocuments: hasDocuments)

    if await introInteractor.shouldShowIntro() {
      return .featureStartupModule(
        .intro(
          config: IntroUiConfig(
            showDismissOption: true,
            nextRoute: authRoute
          )
        )
      )
    }

    return authRoute
  }

  private func buildAuthRoute(hasDocuments: Bool) async -> AppRoute {
    if await quickPinInteractor.hasPin() {
      return .featureCommonModule(
        .biometry(
          config: UIConfig.Biometry(
            navigationTitle: .custom(""),
            title: .loginTitle,
            caption: .loginCaption,
            quickPinOnlyCaption: .loginCaptionQuickPinOnly,
            navigationSuccessType: .push(
              !hasDocuments && configLogic.forcePidActivation
              ? .featureIssuanceModule(.issuanceAddDocument(config: IssuanceFlowUiConfig(flow: .noDocument)))
              : .featureDashboardModule(.dashboard)
            ),
            navigationBackType: nil,
            isPreAuthorization: true,
            shouldInitializeBiometricOnCreate: true
          )
        )
      )
    } else {
      return .featureCommonModule(
        .quickPin(
          config: QuickPinUiConfig(
            flow: configLogic.forcePidActivation
            ? .setWithActivation
            : .setWithoutActivation
          )
        )
      )
    }
  }

  private func manageStorageForFirstRun() async {
    if !prefsController.getBool(forKey: .runAtLeastOnce) {
      await walletKitController.clearAllDocuments()
      keyChainController.clear()
      prefsController.setValue(true, forKey: .runAtLeastOnce)
    }
  }
}
```

- [ ] **Step 4: Update DI registration for StartupInteractor with new dependency**

In `Modules/feature-startup/Sources/DI/FeatureStartupAssembly.swift`, update the StartupInteractor registration to include IntroInteractor. The IntroInteractor must be registered first:

```swift
  public func assemble(container: Container) {
    container.register(IntroInteractor.self) { r in
      IntroInteractorImpl(
        prefsController: r.force(PrefsController.self),
        configLogic: r.force(ConfigLogic.self)
      )
    }
    .inObjectScope(ObjectScope.transient)

    container.register(StartupInteractor.self) { r in
      StartupInteractorImpl(
        walletKitController: r.force(WalletKitController.self),
        quickPinInteractor: r.force(QuickPinInteractor.self),
        keyChainController: r.force(KeyChainController.self),
        prefsController: r.force(PrefsController.self),
        configLogic: r.force(ConfigLogic.self),
        introInteractor: r.force(IntroInteractor.self)
      )
    }
    .inObjectScope(ObjectScope.transient)
  }
```

- [ ] **Step 5: Commit**

```bash
git add Modules/feature-startup/Sources/DI/FeatureStartupAssembly.swift \
       Modules/feature-startup/Sources/Router/StartupRouter.swift \
       Modules/feature-startup/Sources/Interactor/StartupInteractor.swift
git commit -m "Wire up intro screen in DI, router, and startup flow"
```

---

### Task 7: Update StartupInteractor Tests

**Files:**
- Modify: `Modules/feature-startup/Tests/Interactor/TestStartupInteractor.swift`

- [ ] **Step 1: Add IntroInteractor mock and update setUp**

The existing tests need updating because `StartupInteractorImpl` now requires an `introInteractor` parameter. Update the test file:

```swift
final class TestStartupInteractor: EudiTest {

  var interactor: StartupInteractor!
  var walletKitController: MockWalletKitController!
  var quickPinInteractor: MockQuickPinInteractor!
  var keyChainController: MockKeyChainController!
  var prefsController: MockPrefsController!
  var configLogic: MockConfigLogic!
  var introInteractor: MockIntroInteractor!

  override func setUp() {
    self.walletKitController = MockWalletKitController()
    self.quickPinInteractor = MockQuickPinInteractor()
    self.keyChainController = MockKeyChainController()
    self.prefsController = MockPrefsController()
    self.configLogic = MockConfigLogic()
    self.introInteractor = MockIntroInteractor()
    self.interactor = StartupInteractorImpl(
      walletKitController: walletKitController,
      quickPinInteractor: quickPinInteractor,
      keyChainController: keyChainController,
      prefsController: prefsController,
      configLogic: configLogic,
      introInteractor: introInteractor
    )

    stubConfigLogic()
    stubPrefsControllerSetValue()
    stubKeyChainClear()
    stubWalletKiControllerClearAllDocuments()
    stubIntroShouldNotShow()
  }

  override func tearDown() {
    self.interactor = nil
    self.walletKitController = nil
    self.quickPinInteractor = nil
    self.keyChainController = nil
    self.prefsController = nil
    self.configLogic = nil
    self.introInteractor = nil
  }
```

Add a stub helper and a new test in the private extension:

```swift
  func stubIntroShouldNotShow() {
    stub(introInteractor) { mock in
      when(mock.shouldShowIntro()).thenReturn(false)
    }
  }

  func stubIntroShouldShow() {
    stub(introInteractor) { mock in
      when(mock.shouldShowIntro()).thenReturn(true)
    }
  }
```

Add a new test method for the intro route:

```swift
  func testInitialize_WhenIntroShouldShow_ThenReturnIntroRoute() async throws {
    // Given
    let expectedPid = Constants.createEuPidModel()
    stubFetchDocuments(with: [expectedPid])
    stubHasPin(with: true)
    stubRunAtLeastOnce()
    stubIntroShouldShow()
    // When
    let route = await interactor.initialize(with: .zero)
    // Then
    switch route {
    case .featureStartupModule(let module):
      if case .intro(let config) = module {
        let receivedConfig = try XCTUnwrap(config as? IntroUiConfig)
        XCTAssertTrue(receivedConfig.showDismissOption)
        XCTAssertNotNil(receivedConfig.nextRoute)
      } else {
        XCTFail("Wrong route \(route)")
      }
    default:
      XCTFail("Wrong route \(route)")
    }
  }
```

Note: `MockIntroInteractor` needs to exist. Since mocks are in `GeneratedMocks.swift` (auto-generated by Cuckoo), you may need to either regenerate mocks or manually add a `MockIntroInteractor` class. If the project uses a mock generation script, run it. Otherwise, create a minimal mock manually in `Modules/feature-startup/Tests/Mock/GeneratedMocks.swift` by appending:

```swift
// MARK: - Mocks generated from file: '../Modules/feature-startup/Sources/Interactor/IntroInteractor.swift'

class MockIntroInteractor: IntroInteractor, Cuckoo.ProtocolMock {
    typealias MocksType = IntroInteractor
    typealias Stubbing = __StubbingProxy_IntroInteractor
    typealias Verification = __VerificationProxy_IntroInteractor

    let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    private var __defaultImplStub: (any IntroInteractor)?

    struct __StubbingProxy_IntroInteractor: Cuckoo.StubbingProxy {
        let cuckoo_manager: Cuckoo.MockManager
        init(manager: Cuckoo.MockManager) { self.cuckoo_manager = manager }

        func shouldShowIntro() -> Cuckoo.ProtocolStubFunction<(), Bool> {
            Cuckoo.ProtocolStubFunction(manager: cuckoo_manager, name: "shouldShowIntro()", parameterMatchers: [])
        }

        func dismissIntro() -> Cuckoo.ProtocolStubNoReturnFunction<()> {
            Cuckoo.ProtocolStubNoReturnFunction(manager: cuckoo_manager, name: "dismissIntro()", parameterMatchers: [])
        }

        func getAppVersion() -> Cuckoo.ProtocolStubFunction<(), String> {
            Cuckoo.ProtocolStubFunction(manager: cuckoo_manager, name: "getAppVersion()", parameterMatchers: [])
        }

        func getGitHubUrl() -> Cuckoo.ProtocolStubFunction<(), URL?> {
            Cuckoo.ProtocolStubFunction(manager: cuckoo_manager, name: "getGitHubUrl()", parameterMatchers: [])
        }
    }

    struct __VerificationProxy_IntroInteractor: Cuckoo.VerificationProxy {
        let cuckoo_manager: Cuckoo.MockManager
        init(manager: Cuckoo.MockManager) { self.cuckoo_manager = manager }

        @discardableResult
        func shouldShowIntro() -> Cuckoo.__DoNotUse<(), Bool> {
            Cuckoo.VerificationManager.verify(manager: cuckoo_manager, name: "shouldShowIntro()", parameterMatchers: [] as [Cuckoo.ParameterMatcher<Void>])
        }

        @discardableResult
        func dismissIntro() -> Cuckoo.__DoNotUse<(), Void> {
            Cuckoo.VerificationManager.verify(manager: cuckoo_manager, name: "dismissIntro()", parameterMatchers: [] as [Cuckoo.ParameterMatcher<Void>])
        }

        @discardableResult
        func getAppVersion() -> Cuckoo.__DoNotUse<(), String> {
            Cuckoo.VerificationManager.verify(manager: cuckoo_manager, name: "getAppVersion()", parameterMatchers: [] as [Cuckoo.ParameterMatcher<Void>])
        }

        @discardableResult
        func getGitHubUrl() -> Cuckoo.__DoNotUse<(), URL?> {
            Cuckoo.VerificationManager.verify(manager: cuckoo_manager, name: "getGitHubUrl()", parameterMatchers: [] as [Cuckoo.ParameterMatcher<Void>])
        }
    }

    func shouldShowIntro() async -> Bool {
        await cuckoo_manager.call("shouldShowIntro()", parameters: (), escapingParameters: (), superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall())
    }

    func dismissIntro() async {
        await cuckoo_manager.call("dismissIntro()", parameters: (), escapingParameters: (), superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall())
    }

    func getAppVersion() async -> String {
        await cuckoo_manager.call("getAppVersion()", parameters: (), escapingParameters: (), superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall())
    }

    func getGitHubUrl() async -> URL? {
        await cuckoo_manager.call("getGitHubUrl()", parameters: (), escapingParameters: (), superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall())
    }

    func enableDefaultImplementation(_ stub: any IntroInteractor) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }

    func stub<M1: Cuckoo.Matchable>(_ mock: MockIntroInteractor, block: (MockIntroInteractor.Stubbing) -> M1) -> M1 {
        block(__StubbingProxy_IntroInteractor(manager: cuckoo_manager))
    }

    func verify<M1: Cuckoo.Matchable>(_ mock: MockIntroInteractor, block: (MockIntroInteractor.Verification) -> M1) -> M1 {
        block(__VerificationProxy_IntroInteractor(manager: cuckoo_manager))
    }
}
```

Note: The exact mock structure depends on the Cuckoo version used. If the project has a mock generation script (e.g., a `generate_mocks.sh` or build phase), prefer running that instead. Adapt the mock to match the patterns in the existing `GeneratedMocks.swift` file.

- [ ] **Step 2: Run all startup tests**

Run: `xcodebuild test -scheme "EUDI Wallet Dev" -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:feature-startup-tests 2>&1 | tail -30`

Expected: All tests PASS (existing 4 + new 1 for intro routing).

- [ ] **Step 3: Commit**

```bash
git add Modules/feature-startup/Tests/Interactor/TestStartupInteractor.swift \
       Modules/feature-startup/Tests/Mock/GeneratedMocks.swift
git commit -m "Update StartupInteractor tests for intro routing"
```

---

### Task 8: Add "About This App" to Settings

**Files:**
- Modify: `Modules/feature-dashboard/Sources/UI/Settings/SettingsViewModel.swift:69-110`

- [ ] **Step 1: Add About This App menu item in buildUi()**

In `Modules/feature-dashboard/Sources/UI/Settings/SettingsViewModel.swift`, modify the `buildUi()` method to add the menu item. Add it after the Source Repository item (before `setState`):

```swift
  private func buildUi() async {

    let appVersion = await interactor.getAppVersion()
    let logsUrl = await interactor.retrieveLogFileUrl()
    let changelogUrl = await interactor.retrieveChangeLogUrl()

    var items: [SettingMenuItemUIModel] = [
      .init(
        title: .retrieveLogs,
        isShareLink: true,
        action: {}()
      )
    ]

    if let changelogUrl = await interactor.retrieveChangeLogUrl() {
      items.append(
        .init(
          title: .changelog,
          action: changelogUrl.open()
        )
      )
    }

    if let sourceRepoUrl = URL(string: "https://github.com/hopae-official/hopae-eudi-ref-wallet") {
      items.append(
        .init(
          title: .sourceRepository,
          action: sourceRepoUrl.open()
        )
      )
    }

    items.append(
      .init(
        title: .aboutThisApp,
        showDivider: false,
        action: self.router.push(
          with: .featureStartupModule(
            .intro(
              config: IntroUiConfig(
                showDismissOption: false
              )
            )
          )
        )
      )
    )

    setState {
      $0.copy(
        items: items,
        appVersion: appVersion,
        logsUrl: logsUrl,
        changelogUrl: changelogUrl
      )
    }
  }
```

Note: The Source Repository item above it should now have `showDivider: true` (which is the default, so no change needed — it was previously `showDivider: false` since it was the last item). Update it:

Change the source repo item's `showDivider: false` to remove that parameter (defaults to `true`):

```swift
    if let sourceRepoUrl = URL(string: "https://github.com/hopae-official/hopae-eudi-ref-wallet") {
      items.append(
        .init(
          title: .sourceRepository,
          action: sourceRepoUrl.open()
        )
      )
    }
```

- [ ] **Step 2: Verify the import**

`SettingsViewModel.swift` already imports `logic_ui` (which contains `AppRoute`, `IntroUiConfig`), `logic_core`, and `feature_common`. The `FeatureStartupRouteModule` is defined in `logic_ui/Sources/Navigation/AppRoute.swift`, so no additional import is needed.

- [ ] **Step 3: Commit**

```bash
git add Modules/feature-dashboard/Sources/UI/Settings/SettingsViewModel.swift
git commit -m "Add About This App item to Settings menu"
```

---

### Task 9: Build Verification

- [ ] **Step 1: Build the project**

Run: `xcodebuild build -scheme "EUDI Wallet Dev" -destination "platform=iOS Simulator,name=iPhone 16" 2>&1 | tail -20`

Expected: BUILD SUCCEEDED

- [ ] **Step 2: Run all tests**

Run: `xcodebuild test -scheme "EUDI Wallet Dev" -destination "platform=iOS Simulator,name=iPhone 16" 2>&1 | tail -30`

Expected: All tests PASS

- [ ] **Step 3: Fix any compilation or test failures**

If there are compilation issues, likely causes:
- Missing imports in IntroView/IntroViewModel (needs `logic_ui`, `logic_resources`)
- `@Copyable` macro not generating `copy()` method — check if the project has a build plugin or if `Copyable` is a custom macro
- Mock type mismatches — adapt `MockIntroInteractor` to match existing mock patterns

- [ ] **Step 4: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "Fix build issues for intro screen"
```
