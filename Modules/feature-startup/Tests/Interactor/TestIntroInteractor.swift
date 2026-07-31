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
    stub(prefsController) { mock in
      when(mock.getString(forKey: Prefs.Key.introLastDismissedVersion)).thenReturn(nil)
    }
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.0.0")
    }
    let result = await interactor.shouldShowIntro()
    XCTAssertTrue(result)
  }

  func testShouldShowIntro_WhenDismissedVersionMatchesCurrent_ThenReturnsFalse() async {
    stub(prefsController) { mock in
      when(mock.getString(forKey: Prefs.Key.introLastDismissedVersion)).thenReturn("1.0.0")
    }
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.0.0")
    }
    let result = await interactor.shouldShowIntro()
    XCTAssertFalse(result)
  }

  func testShouldShowIntro_WhenDismissedVersionDiffersFromCurrent_ThenReturnsTrue() async {
    stub(prefsController) { mock in
      when(mock.getString(forKey: Prefs.Key.introLastDismissedVersion)).thenReturn("0.9.0")
    }
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.0.0")
    }
    let result = await interactor.shouldShowIntro()
    XCTAssertTrue(result)
  }

  func testDismissIntro_StoresCurrentVersion() async {
    stub(prefsController) { mock in
      when(mock.setValue(any(), forKey: any())).thenDoNothing()
    }
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.0.0")
    }
    await interactor.dismissIntro()
    verify(prefsController).setValue(any(), forKey: Prefs.Key.introLastDismissedVersion)
  }

  func testGetAppVersion_ReturnsConfigVersion() async {
    stub(configLogic) { mock in
      when(mock.appVersion.get).thenReturn("1.2.3")
    }
    let version = await interactor.getAppVersion()
    XCTAssertEqual(version, "1.2.3")
  }

  func testGetGitHubUrl_ReturnsExpectedUrl() async {
    let url = await interactor.getGitHubUrl()
    XCTAssertEqual(url, URL(string: "https://github.com/hopae-official/hopae-eudi-ref-wallet"))
  }
}
