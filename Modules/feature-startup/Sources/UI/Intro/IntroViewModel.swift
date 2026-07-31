/*
 * Copyright (c) 2025 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
import Foundation
import logic_ui
import logic_resources

@Copyable
struct IntroViewState: ViewState {
  let appName: String
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
        appName: "",
        appVersion: "",
        gitHubUrl: nil,
        showDismissOption: config.showDismissOption,
        dontShowAgainChecked: false
      )
    )
  }

  func initialize() async {
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "EUDI Wallet"
    let appVersion = await interactor.getAppVersion()
    let gitHubUrl = await interactor.getGitHubUrl()
    setState {
      $0.copy(
        appName: appName,
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
