# Dual-Version Build Strategy Design

## Context

HopaeEUDIWallet은 EUDI ref wallet의 fork로, 두 가지 버전을 동시에 관리한다:

1. **Demo** — EUDI ref wallet의 동작을 보장하는 순수 버전. Hopae는 화이트라벨링(로고, 번들ID, 앱 이름)만 적용하고 코드 수정은 하지 않음.
2. **Edge** — Hopae가 최신 스펙(DCQL 등)을 선반영한 개선 버전. 고객에게 먼저 테스트 목적으로 제공.

## Branch Strategy

```
upstream (eu-digital-identity-wallet)
    │
    │  sync
    ▼
  main ────●────●────●────●────
    │       \         \         \
    │        merge     merge     merge
    ▼         \         \         \
  edge ────────●─────────●─────────●────
```

### `main` branch
- upstream EUDI ref wallet과 최대한 동기화
- Hopae 화이트라벨링만 적용 (로고, 번들ID, 앱 이름)
- 빌드 가능 스킴: `EUDI Wallet Dev`, `EUDI Wallet Demo`

### `edge` branch
- main에서 분기한 장기 브랜치
- Hopae 개선 사항을 **additive**로 추가 (main의 모든 내용 포함)
- main 변경을 주기적으로 merge
- 빌드 가능 스킴: `EUDI Wallet Dev`, `EUDI Wallet Demo`, `EUDI Wallet Edge`
- 코드 변경은 별도 feature flag 없이 직접 수정 (브랜치 자체가 분리 메커니즘)

### Upstream sync flow
1. upstream 변경 → `main`에 merge
2. `main` → `edge`로 merge
3. 개선 사항이 upstream에 머지되면 → edge의 해당 diff 자연 소멸

## Build Configuration

### Variant matrix (edge branch 기준, 6개 구성)

| Configuration | xcconfig | Bundle ID | App Name |
|---|---|---|---|
| Debug Dev | WalletDev | `eu.europa.ec.euidi.dev` | "EUDI Wallet" |
| Debug Demo | WalletDemo | `com.hopae.eudi-ref-wallet.demo` | "HopaeEUDIWallet" |
| Debug Edge | WalletEdge | `com.hopae.eudi-ref-wallet.edge` | "HopaeEUDIWallet Edge" |
| Release Dev | WalletDevRelease | `eu.europa.ec.euidi.dev` | "EUDI Wallet" |
| Release Demo | WalletDemoRelease | `com.hopae.eudi-ref-wallet.demo` | "HopaeEUDIWallet" |
| Release Edge | WalletEdgeRelease | `com.hopae.eudi-ref-wallet.edge` | "HopaeEUDIWallet Edge" |

### Edge-specific files (edge branch에서만 존재)
- `Wallet/Config/WalletEdge.xcconfig` — `BUILD_TYPE=DEBUG`, `BUILD_VARIANT=EDGE`
- `Wallet/Config/WalletEdgeRelease.xcconfig` — `BUILD_TYPE=RELEASE`, `BUILD_VARIANT=EDGE`
- `EUDI Wallet Edge.xcscheme` — Debug Edge / Release Edge 사용
- 앱 아이콘: 당분간 Demo와 동일한 `AppIcon` 사용 (별도 작업으로 분리)

## SPM Dependency Management

### 변경 패턴
edge 브랜치에서 Hopae fork를 참조하도록 `Package.swift` 변경:

```swift
// main
.package(url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-wallet-kit.git", exact: "0.22.0")

// edge
.package(url: "https://github.com/lukasjhan/eudi-lib-ios-wallet-kit.git", branch: "feat/dcql-null-match-localbuild")
```

### 원칙
- edge 브랜치에서 `Package.swift`의 의존성 URL/버전을 Hopae fork로 직접 변경
- 개선 사항이 upstream에 머지되면 edge의 해당 의존성을 공식 repo로 되돌림
- 이 시점에서 edge와 main의 diff가 자연스럽게 줄어듦

## Code-Level Changes

### 원칙
- `#if` 컴파일 플래그나 `BUILD_VARIANT` 런타임 분기 사용하지 않음
- 브랜치 자체가 분리 메커니즘이므로 edge에서 자유롭게 코드 수정
- main은 upstream과 동일한 코드를 유지

### 이유
- 컴파일 플래그를 쓰면 main에도 Edge 관련 코드가 들어가서 "순수성" 훼손
- 런타임 분기는 불필요한 복잡도 추가

## Merge Conflict Resolution

### 예상 충돌 파일
1. `Modules/logic-core/Package.swift` — 의존성 URL/버전
2. `Package.resolved` — 자동 재생성이므로 resolve 후 재커밋
3. `project.pbxproj` — Edge 빌드 구성 관련 (main에 없는 섹션이므로 충돌 적음)

### 충돌 해소 기준
- upstream이 같은 파일을 수정한 경우 → edge의 개선 의도를 살리면서 upstream 변경 반영 (수동 해소)
- upstream이 edge의 개선 사항을 채택한 경우 → edge 쪽 diff 제거, upstream 코드 수용
- `Package.swift` 충돌 → fork가 아직 필요한 동안은 edge 쪽 선택
- `Package.resolved` 충돌 → 삭제 후 Xcode에서 재resolve
