# HopaeEUDIWallet

EUDI ref wallet의 fork. 두 가지 버전을 관리한다.

## Branch Strategy

- **`main`** — upstream EUDI ref wallet과 동기화. 화이트라벨링만 적용. Dev/Demo 스킴.
- **`edge`** — main + Hopae 개선 사항 (additive). Dev/Demo/Edge 스킴.
- edge의 변경은 main 대비 **추가분만** 존재해야 한다. main의 코드를 삭제하거나 변경하는 것은 최소화.

## Build Variants

| Variant | Bundle ID | 목적 |
|---|---|---|
| Dev | `eu.europa.ec.euidi.dev` | 원본 EUDI (개발용) |
| Demo | `com.hopae.eudi-ref-wallet.demo` | 순수 EUDI + Hopae 브랜딩 (스토어 배포) |
| Edge | `com.hopae.eudi-ref-wallet.edge` | Hopae 개선 선반영 (스토어 배포) |

## Upstream Sync

1. upstream 변경 → `main`에 merge
2. `main` → `edge`로 merge
3. 개선 사항이 upstream에 머지되면 → edge의 해당 diff 제거, 공식 repo로 되돌림

## Merge Conflict Resolution (edge ← main)

### 충돌 해소 기준
- **`Package.swift`** — Hopae fork가 아직 필요한 동안은 edge 쪽 선택
- **`Package.resolved`** — 삭제 후 Xcode에서 재resolve
- **`project.pbxproj`** — Edge 빌드 구성은 main에 없으므로 양쪽 모두 수용 (accept both)
- **코드 파일** — edge의 개선 의도를 살리면서 upstream 변경 반영. upstream이 같은 개선을 채택했으면 edge 쪽 diff 제거

### 원칙
- main에서는 `#if` 컴파일 플래그나 BUILD_VARIANT 런타임 분기를 사용하지 않는다
- edge에서 코드 변경은 직접 수정한다 (브랜치가 분리 메커니즘)
- main의 "순수성"을 훼손하지 않는다

## SPM Dependencies

- main: 공식 EUDI repo의 정식 버전 참조
- edge: Hopae fork repo/branch 참조 (개선 사항 반영 시)
- 개선이 upstream에 머지되면 edge도 공식 repo로 되돌린다
