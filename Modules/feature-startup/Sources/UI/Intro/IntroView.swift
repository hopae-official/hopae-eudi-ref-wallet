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
