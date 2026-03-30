# Edge Build Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Edge build configurations, xcconfig files, and scheme to the Xcode project so the `edge` branch can build a separate "HopaeEUDIWallet Edge" app.

**Architecture:** Follows the existing Dev/Demo pattern — add 2 xcconfig files, 4 XCBuildConfiguration entries (2 project-level + 2 target-level), 1 scheme, and register the new files in the Xcode project. All changes are additive to minimize diff.

**Tech Stack:** Xcode project (pbxproj), xcconfig, xcscheme XML

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `Wallet/Config/WalletEdge.xcconfig` | Debug Edge build variables |
| Create | `Wallet/Config/WalletEdgeRelease.xcconfig` | Release Edge build variables |
| Create | `EudiReferenceWallet.xcodeproj/xcshareddata/xcschemes/EUDI Wallet Edge.xcscheme` | Edge scheme definition |
| Modify | `EudiReferenceWallet.xcodeproj/project.pbxproj` | Register new files, configurations |

---

### Task 1: Create Edge xcconfig files

**Files:**
- Create: `Wallet/Config/WalletEdge.xcconfig`
- Create: `Wallet/Config/WalletEdgeRelease.xcconfig`

- [ ] **Step 1: Create WalletEdge.xcconfig**

```
BUILD_TYPE = DEBUG
BUILD_VARIANT = EDGE
CHANGELOG_URL =  https:/$()/github.com/hopae-official/hopae-eudi-ref-wallet/releases
```

- [ ] **Step 2: Create WalletEdgeRelease.xcconfig**

```
BUILD_TYPE = RELEASE
BUILD_VARIANT = EDGE
CHANGELOG_URL =  https:/$()/github.com/hopae-official/hopae-eudi-ref-wallet/releases
```

- [ ] **Step 3: Commit**

```bash
git add Wallet/Config/WalletEdge.xcconfig Wallet/Config/WalletEdgeRelease.xcconfig
git commit -m "Add Edge xcconfig files for debug and release"
```

---

### Task 2: Register xcconfig files in project.pbxproj

**Files:**
- Modify: `EudiReferenceWallet.xcodeproj/project.pbxproj`

This task adds PBXFileReference, PBXBuildFile entries, and updates the Config PBXGroup to include the new xcconfig files.

- [ ] **Step 1: Add PBXFileReference entries for the two xcconfig files**

Insert after line 77 (`F1CACAE12AC3098C00B40DED /* WalletDemo.xcconfig */`), before `/* End PBXFileReference section */`:

```
		F1EDGE012EE9000000000001 /* WalletEdge.xcconfig */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.xcconfig; path = WalletEdge.xcconfig; sourceTree = "<group>"; };
		F1EDGE022EE9000000000002 /* WalletEdgeRelease.xcconfig */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.xcconfig; path = WalletEdgeRelease.xcconfig; sourceTree = "<group>"; };
```

- [ ] **Step 2: Add PBXBuildFile entries to register them as resources**

Insert after line 38 (`F1CACAE22AC3098C00B40DED /* WalletDemo.xcconfig in Resources */`), before `/* End PBXBuildFile section */`:

```
		F1EDGE032EE9000000000003 /* WalletEdge.xcconfig in Resources */ = {isa = PBXBuildFile; fileRef = F1EDGE012EE9000000000001 /* WalletEdge.xcconfig */; };
		F1EDGE042EE9000000000004 /* WalletEdgeRelease.xcconfig in Resources */ = {isa = PBXBuildFile; fileRef = F1EDGE022EE9000000000002 /* WalletEdgeRelease.xcconfig */; };
```

- [ ] **Step 3: Add to Config PBXGroup children**

In the Config group (UUID `F09E1EA02AC33A6800779C25`), add the two new file references to the children array. Insert after `F1CACAE12AC3098C00B40DED /* WalletDemo.xcconfig */`:

```
				F1EDGE012EE9000000000001 /* WalletEdge.xcconfig */,
				F1EDGE022EE9000000000002 /* WalletEdgeRelease.xcconfig */,
```

- [ ] **Step 4: Add to PBXResourcesBuildPhase files array**

Find the Resources build phase (`PBXResourcesBuildPhase` section) and add the two build file references to the `files` array:

```
				F1EDGE032EE9000000000003 /* WalletEdge.xcconfig in Resources */,
				F1EDGE042EE9000000000004 /* WalletEdgeRelease.xcconfig in Resources */,
```

- [ ] **Step 5: Commit**

```bash
git add EudiReferenceWallet.xcodeproj/project.pbxproj
git commit -m "Register Edge xcconfig files in Xcode project"
```

---

### Task 3: Add Edge build configurations to project.pbxproj

**Files:**
- Modify: `EudiReferenceWallet.xcodeproj/project.pbxproj`

Add 4 XCBuildConfiguration entries (2 project-level, 2 target-level) and update both XCConfigurationList sections.

- [ ] **Step 1: Add project-level Debug Edge configuration**

Insert after the Release Dev project-level config (UUID `F14907DB2ABAF55000DDFE56`, ending at line 652), before the first target-level config. This is a copy of Debug Demo project-level config (UUID `F0E39F512B7A678200F162E9`) with name changed:

```
		F1EDGE052EE9000000000005 /* Debug Edge */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.6;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = "Debug Edge";
		};
```

- [ ] **Step 2: Add project-level Release Edge configuration**

Insert immediately after Debug Edge. Copy of Release Demo project-level config (UUID `F0E39F532B7A678D00F162E9`) with name changed:

```
		F1EDGE062EE9000000000006 /* Release Edge */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.6;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = "Release Edge";
		};
```

- [ ] **Step 3: Add target-level Debug Edge configuration**

Insert after the Release Dev target-level config (UUID `F14907DE2ABAF55000DDFE56`, ending at line 749). Copy of Debug Demo target-level config (UUID `F0E39F522B7A678200F162E9`) with Edge-specific values:

```
		F1EDGE072EE9000000000007 /* Debug Edge */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = F1EDGE012EE9000000000001 /* WalletEdge.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_IDENTITY = "Apple Development";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 3;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				DEVELOPMENT_ASSET_PATHS = "Wallet/Preview\\ Content";
				DEVELOPMENT_TEAM = P3A48743C4;
				ENABLE_PREVIEWS = YES;
				ENABLE_TESTING_SEARCH_PATHS = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Wallet/Wallet.plist;
				INFOPLIST_KEY_CFBundleDisplayName = "HopaeEUDIWallet Edge";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.productivity";
				INFOPLIST_KEY_NSBluetoothAlwaysUsageDescription = "Bluetooth is used to share your identity documents in person";
				INFOPLIST_KEY_NSCameraUsageDescription = "Camera is used to scan QR codes for identity verification";
				INFOPLIST_KEY_NSFaceIDUsageDescription = "Use Face ID to securely access your wallet";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 26.0;
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.hopae.eudi-ref-wallet.edge";
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 6.0;
				TARGETED_DEVICE_FAMILY = 1;
				TVOS_DEPLOYMENT_TARGET = 17.6;
				WATCHOS_DEPLOYMENT_TARGET = 26.0;
				XROS_DEPLOYMENT_TARGET = 26.0;
			};
			name = "Debug Edge";
		};
```

- [ ] **Step 4: Add target-level Release Edge configuration**

Insert immediately after Debug Edge target-level config. Copy of Release Demo target-level config (UUID `F0E39F542B7A678D00F162E9`) with Edge-specific values:

```
		F1EDGE082EE9000000000008 /* Release Edge */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = F1EDGE022EE9000000000002 /* WalletEdgeRelease.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_IDENTITY = "Apple Development";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 3;
				DEVELOPMENT_ASSET_PATHS = "Wallet/Preview\\ Content";
				DEVELOPMENT_TEAM = P3A48743C4;
				ENABLE_PREVIEWS = YES;
				ENABLE_TESTING_SEARCH_PATHS = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Wallet/Wallet.plist;
				INFOPLIST_KEY_CFBundleDisplayName = "HopaeEUDIWallet Edge";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.productivity";
				INFOPLIST_KEY_NSBluetoothAlwaysUsageDescription = "Bluetooth is used to share your identity documents in person";
				INFOPLIST_KEY_NSCameraUsageDescription = "Camera is used to scan QR codes for identity verification";
				INFOPLIST_KEY_NSFaceIDUsageDescription = "Use Face ID to securely access your wallet";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 26.0;
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.hopae.eudi-ref-wallet.edge";
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 6.0;
				TARGETED_DEVICE_FAMILY = 1;
				TVOS_DEPLOYMENT_TARGET = 17.6;
				WATCHOS_DEPLOYMENT_TARGET = 26.0;
				XROS_DEPLOYMENT_TARGET = 26.0;
			};
			name = "Release Edge";
		};
```

- [ ] **Step 5: Update project XCConfigurationList**

In the project configuration list (UUID `F14907B32ABAF54B00DDFE56`), add the two new project-level Edge configurations to `buildConfigurations`:

```
			buildConfigurations = (
				F14907DA2ABAF55000DDFE56 /* Debug Dev */,
				F0E39F512B7A678200F162E9 /* Debug Demo */,
				F1EDGE052EE9000000000005 /* Debug Edge */,
				F14907DB2ABAF55000DDFE56 /* Release Dev */,
				F0E39F532B7A678D00F162E9 /* Release Demo */,
				F1EDGE062EE9000000000006 /* Release Edge */,
			);
```

- [ ] **Step 6: Update target XCConfigurationList**

In the target configuration list (UUID `F14907DC2ABAF55000DDFE56`), add the two new target-level Edge configurations to `buildConfigurations`:

```
			buildConfigurations = (
				F14907DD2ABAF55000DDFE56 /* Debug Dev */,
				F0E39F522B7A678200F162E9 /* Debug Demo */,
				F1EDGE072EE9000000000007 /* Debug Edge */,
				F14907DE2ABAF55000DDFE56 /* Release Dev */,
				F0E39F542B7A678D00F162E9 /* Release Demo */,
				F1EDGE082EE9000000000008 /* Release Edge */,
			);
```

- [ ] **Step 7: Commit**

```bash
git add EudiReferenceWallet.xcodeproj/project.pbxproj
git commit -m "Add Edge build configurations to Xcode project"
```

---

### Task 4: Create Edge scheme

**Files:**
- Create: `EudiReferenceWallet.xcodeproj/xcshareddata/xcschemes/EUDI Wallet Edge.xcscheme`

- [ ] **Step 1: Create the Edge scheme file**

Copy of the Demo scheme with all `Demo` configuration references replaced by `Edge`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "2620"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "F14907B72ABAF54B00DDFE56"
               BuildableName = "EudiWallet.app"
               BlueprintName = "EudiWallet"
               ReferencedContainer = "container:EudiReferenceWallet.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug Edge"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <TestPlans>
         <TestPlanReference
            reference = "container:EudiWallet.xctestplan"
            default = "YES">
         </TestPlanReference>
      </TestPlans>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Release Edge"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "F14907B72ABAF54B00DDFE56"
            BuildableName = "EudiWallet.app"
            BlueprintName = "EudiWallet"
            ReferencedContainer = "container:EudiReferenceWallet.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release Edge"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "F14907B72ABAF54B00DDFE56"
            BuildableName = "EudiWallet.app"
            BlueprintName = "EudiWallet"
            ReferencedContainer = "container:EudiReferenceWallet.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug Edge">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release Edge"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
```

- [ ] **Step 2: Commit**

```bash
git add "EudiReferenceWallet.xcodeproj/xcshareddata/xcschemes/EUDI Wallet Edge.xcscheme"
git commit -m "Add EUDI Wallet Edge scheme"
```

---

### Task 5: Verify in Xcode

- [ ] **Step 1: Open project in Xcode and verify**

```bash
open EudiReferenceWallet.xcodeproj
```

Verify:
1. "EUDI Wallet Edge" scheme appears in scheme selector
2. Selecting Edge scheme and building succeeds (⌘B)
3. Build output shows bundle identifier `com.hopae.eudi-ref-wallet.edge`
4. Build output shows app name "HopaeEUDIWallet Edge"
5. Dev and Demo schemes still work as before

- [ ] **Step 2: If pbxproj UUIDs conflict, regenerate**

If Xcode fails to parse the project, open in Xcode and manually add the configurations via:
- Project settings → Info tab → Configurations → "+" → Duplicate "Debug Demo" → Rename to "Debug Edge"
- Repeat for "Release Demo" → "Release Edge"
- Update the generated configurations' target settings to match the Edge values from the plan

Then commit the Xcode-generated changes.

- [ ] **Step 3: Final commit if any Xcode-generated fixes were needed**

```bash
git add -A
git commit -m "Fix Xcode project after Edge configuration verification"
```
