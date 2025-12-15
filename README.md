# ReleaseKit

[![Swift Version](https://img.shields.io/badge/Swift-6.2+-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-26.0+-blue.svg)](https://www.apple.com/ios)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

A Swift package for managing app version upgrades and displaying release notes in iOS applications. ReleaseKit provides a flexible, protocol-oriented approach to version checking and enforcing updates when needed.

## Features

- **Version Upgrade Management**: Check for app updates and enforce critical updates
- **Release Notes Display**: Present release information with categorized entries
- **Flexible Check Intervals**: Automatic checks, timed intervals, or manual triggers
- **Custom Version Types**: Use semantic versioning, build numbers, or define your own

## Requirements

- iOS 26.0 or later
- Swift 6.2 or later
- Xcode 26.0 or later

## Installation

### Swift Package Manager

Add ReleaseKit to your project using Swift Package Manager:

1. In Xcode, select **File > Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/heyjaywilson/ReleaseKit
   ```
3. Select the version you want to use
4. Add the package to your target

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/heyjaywilson/ReleaseKit", from: "1.0.0")
]
```

Then add ReleaseKit as a dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ReleaseKit"]
)
```

## Usage

ReleaseKit provides two main features: displaying release notes and managing version upgrades.

### Displaying Release Notes

Create release objects and display them using the built-in views:

```swift
import ReleaseKit
import SwiftUI

let releases = [
    Release(
        title: "Winter Update",
        icon: "snowflake",
        version: "2.1.0",
        releaseDate: Date(),
        entries: [
            Entry(
                id: "1",
                text: "New dark mode theme",
                isFeatured: true,
                icon: "moon.stars",
                category: Category(
                    id: "features",
                    name: "New Features",
                    featuredBackgroundColor: .purple,
                    sortOrder: 1,
                    icon: "star"
                )
            )
        ]
    )
]

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ReleaseVersionsListView(versions: releases)
        }
    }
}
```

### Version Upgrade Management

To use the version upgrade service, implement a version provider:

#### Step 1: Create a Version Provider

Implement `VersionProvider` to fetch version requirements from your server:

```swift
import ReleaseKit

struct AppVersionProvider: VersionProvider {
    func fetchVersionRequirements() async throws -> VersionRequirement<SemanticVersion> {
        let url = URL(string: "https://api.yourapp.com/version")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Example JSON response: 
        // {"minimum": "1.2.0", "recommended": "1.3.0"}
        let json = try JSONDecoder().decode(VersionResponse.self, from: data)
        
        return VersionRequirement(
            minimumVersion: SemanticVersion(major: json.minimum.major, minor: json.minimum.minor, patch: json.minimum.patch),
            recommendedVersion: SemanticVersion(major: json.recommended.major, minor: json.recommended.minor, patch: json.recommended.patch)
        )
    }
}

struct VersionResponse: Codable {
    let minimum: VersionData
    let recommended: VersionData
}

struct VersionData: Codable {
    let major: Int
    let minor: Int
    let patch: Int
}
```

#### Step 2: Use in Your App

Add the upgrade service to your main app view:

```swift
import SwiftUI
import ReleaseKit

@main
struct MyApp: App {
    @State private var upgradeService = VersionUpgradeService(
        provider: AppVersionProvider(),
        checkInterval: .onForeground
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay {
                    if case .updateRequired(let version) = upgradeService.state {
                        UpdateRequiredView(version: version)
                    }
                }
                .alert("Update Available", isPresented: .constant(isUpdateAvailable)) {
                    Button("Update") { openAppStore() }
                    Button("Later", role: .cancel) { }
                } message: {
                    if case .updateAvailable(let version) = upgradeService.state {
                        Text("Version \(version.stringValue) is available")
                    }
                }
        }
    }
    
    private var isUpdateAvailable: Bool {
        if case .updateAvailable = upgradeService.state {
            return true
        }
        return false
    }
    
    private func openAppStore() {
        // Open your app's App Store page
    }
}
```

#### Check Intervals

Configure how often the service checks for updates:

```swift
// Check every time app enters foreground (default)
VersionUpgradeService(provider: provider, checkInterval: .onForeground)

// Check every hour
VersionUpgradeService(provider: provider, checkInterval: .interval(3600))

// Manual checking only
VersionUpgradeService(provider: provider, checkInterval: .manual)
```

#### Manual Checking

Trigger an update check manually:

```swift
Button("Check for Updates") {
    Task {
        await upgradeService.checkForUpdates()
    }
}
```

## Contributing

ReleaseKit is not currently accepting contributions as it is under active development. 

When contributions are opened in the future, all commits and pull request titles must follow the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
feat: add new feature
fix: resolve bug in version checking
docs: update README
```

### Development Setup

This project uses `swift-format` to maintain consistent code style. To automatically format your Swift code before each commit, run the setup script:

```bash
./support/setup-git-hooks.sh
```

This will install a pre-commit hook that:
- Automatically formats staged Swift files using the project's `.swift-format` configuration
- Only runs when Swift files are being committed
- Ensures all committed code follows the project's style guidelines

The hook requires `swift-format` to be available in your Xcode toolchain. If you encounter any issues, make sure you have Xcode installed and properly configured with `xcode-select`.

## Documentation

Additional documentation is coming soon.

## License

ReleaseKit is available under the MIT license. See the [LICENSE.md](LICENSE.md) file for more information.

## Author

Created by Jay Wilson ([@heyjaywilson](https://github.com/heyjaywilson))

Copyright (c) 2025 CCT Plus LLC
