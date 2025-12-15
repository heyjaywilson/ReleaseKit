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

### Basic Version Checking

```swift
import ReleaseKit

// Create a version provider (implement VersionProvider protocol)
let provider = YourVersionProvider()

// Initialize the service with automatic checking on foreground
let upgradeService = VersionUpgradeService(
    provider: provider,
    checkInterval: .onForeground
)

// Check for updates manually
await upgradeService.checkForUpdates()

// Access the current state
switch upgradeService.state {
case .upToDate:
    print("App is up to date")
case .updateAvailable(let version):
    print("Update available: \(version)")
case .updateRequired(let version):
    print("Update required: \(version)")
case .error(let error):
    print("Error checking for updates: \(error)")
}
```

### Using with SwiftUI

```swift
import SwiftUI
import ReleaseKit

struct ContentView: View {
    @State private var upgradeService: VersionUpgradeService<SemanticVersion, YourVersionProvider>
    
    init() {
        let provider = YourVersionProvider()
        _upgradeService = State(initialValue: VersionUpgradeService(
            provider: provider,
            checkInterval: .onForeground
        ))
    }
    
    var body: some View {
        VStack {
            switch upgradeService.state {
            case .upToDate:
                Text("Your app is up to date!")
            case .updateAvailable(let version):
                UpdateAvailableView(version: version)
            case .updateRequired(let version):
                UpdateRequiredView(version: version)
            case .error(let error):
                ErrorView(error: error)
            }
        }
    }
}
```

### Custom Version Provider

Implement the `VersionProvider` protocol to define your version checking logic:

```swift
import ReleaseKit

struct MyVersionProvider: VersionProvider {
    typealias V = SemanticVersion
    
    func fetchRequirement() async throws -> VersionRequirement<SemanticVersion> {
        // Fetch version requirements from your server
        let response = try await URLSession.shared.data(from: yourURL)
        // Parse and return version requirement
        return VersionRequirement(
            minimumVersion: SemanticVersion(major: 1, minor: 2, patch: 0),
            recommendedVersion: SemanticVersion(major: 1, minor: 3, patch: 0)
        )
    }
}
```

### Check Intervals

Configure how often ReleaseKit checks for updates:

```swift
// Check every time app enters foreground
let service = VersionUpgradeService(
    provider: provider,
    checkInterval: .onForeground
)

// Check at a specific time interval (in seconds)
let service = VersionUpgradeService(
    provider: provider,
    checkInterval: .interval(3600) // Check every hour
)

// Manual checking only
let service = VersionUpgradeService(
    provider: provider,
    checkInterval: .manual
)
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
