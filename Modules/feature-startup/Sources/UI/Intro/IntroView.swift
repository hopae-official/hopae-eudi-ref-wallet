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
      padding: .zero,
      canScroll: false,
      navigationTitle: viewModel.viewState.showDismissOption ? nil : .aboutThisApp,
      toolbarContent: viewModel.toolbarContent()
    ) {
      ScrollView {
        content(
          viewState: viewModel.viewState,
          screenWidth: getScreenRect().width,
          onToggle: { viewModel.toggleDontShowAgain() },
          onContinue: { Task { await viewModel.onContinue() } }
        )
        .padding(.horizontal, Theme.shared.dimension.padding)
        .padding(.top, Theme.shared.dimension.padding)
      }
      .scrollIndicators(.hidden)
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
  VStack(spacing: SPACING_LARGE_MEDIUM) {

    if viewState.showDismissOption {
      headerSection(
        screenWidth: screenWidth,
        appName: viewState.appName
      )
    }

    sectionView(
      title: .introWhatIsThisApp,
      body: .introWhatIsThisAppBody
    )

    Text(.introCurrentVersion([viewState.appVersion]))
      .typography(Theme.shared.font.bodySmall)
      .foregroundColor(Theme.shared.color.onSurfaceVariant)
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, -SPACING_MEDIUM)

    Divider()

    sectionView(
      title: .introMinimalModifications,
      body: .introMinimalModificationsBody
    )

    Divider()

    sectionView(
      title: .introPrivacy,
      body: .introPrivacyBody
    )

    Divider()

    sectionView(
      title: .introOpenSource,
      body: .introOpenSourceBody
    )

    if let gitHubUrl = viewState.gitHubUrl {
      gitHubLinkButton(url: gitHubUrl)
        .padding(.top, -SPACING_MEDIUM_SMALL)
    }

    Divider()

    sectionView(
      title: .introDisclaimer,
      body: .introDisclaimerBody
    )

    if viewState.showDismissOption {
      Divider()
        .padding(.top, SPACING_SMALL)

      dismissSection(
        isChecked: viewState.dontShowAgainChecked,
        onToggle: onToggle,
        onContinue: onContinue
      )
    }
  }
  .padding(.bottom, SPACING_LARGE)
}

@MainActor
@ViewBuilder
private func headerSection(
  screenWidth: CGFloat,
  appName: String
) -> some View {
  VStack(spacing: SPACING_MEDIUM) {
    HStack(spacing: SPACING_MEDIUM) {
      Theme.shared.image.logo
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: screenWidth / 6, height: screenWidth / 6)
        .clipShape(RoundedRectangle(cornerRadius: Theme.shared.shape.small))

      VStack(alignment: .leading, spacing: SPACING_EXTRA_SMALL) {
        Text(verbatim: appName)
          .typography(Theme.shared.font.titleLarge)
          .bold()
          .foregroundColor(Theme.shared.color.onSurface)
          .fixedSize(horizontal: false, vertical: true)

        Text(.aboutThisApp)
          .typography(Theme.shared.font.bodyMedium)
          .foregroundColor(Theme.shared.color.onSurfaceVariant)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer()
    }
  }
  .frame(maxWidth: .infinity)
  .padding(.bottom, SPACING_SMALL)
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
      .bold()
      .foregroundColor(Theme.shared.color.onSurface)
      .fixedSize(horizontal: false, vertical: true)

    Text(body)
      .typography(Theme.shared.font.bodyMedium)
      .foregroundColor(Theme.shared.color.onSurfaceVariant)
      .fixedSize(horizontal: false, vertical: true)
  }
  .frame(maxWidth: .infinity, alignment: .leading)
}

@MainActor
@ViewBuilder
private func gitHubLinkButton(url: URL) -> some View {
  Button {
    url.open()
  } label: {
    HStack(spacing: SPACING_MEDIUM_SMALL) {
      Image(systemName: "link")
        .foregroundColor(Theme.shared.color.primary)

      Text(.sourceRepository)
        .typography(Theme.shared.font.bodyMedium)
        .foregroundColor(Theme.shared.color.primary)
        .fixedSize(horizontal: false, vertical: true)

      Spacer()

      Image(systemName: "arrow.up.right")
        .font(.caption)
        .foregroundColor(Theme.shared.color.onSurfaceVariant)
    }
    .padding(SPACING_MEDIUM)
    .background(Theme.shared.color.surfaceVariant.opacity(0.5))
    .cornerRadius(Theme.shared.shape.small)
  }
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
          .fixedSize(horizontal: false, vertical: true)
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
}
