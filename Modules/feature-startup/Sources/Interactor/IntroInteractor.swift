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
