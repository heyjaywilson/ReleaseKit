# ReleaseKit

An almost useful Swift package to show release notes and force users to upgrade.

This is currently in development, so it is not open to contributions.

## Development Setup

### Swift Formatting with Git Hooks

This project uses `swift-format` to maintain consistent code style. To automatically format your Swift code before each commit, run the setup script:

```bash
./support/setup-git-hooks.sh
```

This will install a pre-commit hook that:
- Automatically formats staged Swift files using the project's `.swift-format` configuration
- Only runs when Swift files are being committed
- Ensures all committed code follows the project's style guidelines

The hook requires `swift-format` to be available in your Xcode toolchain. If you encounter any issues, make sure you have Xcode installed and properly configured with `xcode-select`.
