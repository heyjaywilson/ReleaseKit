import Foundation
import Testing

@testable import ReleaseKit

@Suite("VersionChecker Tests")
struct VersionCheckerTests {

  @Test("App is up to date when current version equals latest version")
  func upToDateWhenCurrentEqualsLatest() async throws {
    // Given: Current version 1.2.3 matches latest version 1.2.3
    let currentVersion = SemanticVersion(major: 1, minor: 2, patch: 3)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 2, patch: 3)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: State should be up to date
    #expect(state == .upToDate)
  }

  @Test("App is up to date when current version is newer than latest")
  func upToDateWhenCurrentIsNewer() async throws {
    // Given: Current version 2.0.0 is newer than latest 1.5.0 (beta/test build)
    let currentVersion = SemanticVersion(major: 2, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: State should be up to date
    #expect(state == .upToDate)
  }

  @Test("Update available when current is behind latest but meets minimum requirement")
  func updateAvailableWhenBehindLatest() async throws {
    // Given: Current 1.2.0, required 1.0.0, latest 1.5.0
    let currentVersion = SemanticVersion(major: 1, minor: 2, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update available with latest version
    let expectedLatest = SemanticVersion(major: 1, minor: 5, patch: 0)
    #expect(state == .updateAvailable(latestVersion: expectedLatest))
  }

  @Test("Update available when current equals required but latest is newer")
  func updateAvailableWhenAtMinimum() async throws {
    // Given: Current 1.2.0 equals required 1.2.0, but latest is 2.0.0
    let currentVersion = SemanticVersion(major: 1, minor: 2, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 2, patch: 0),
      latestVersion: SemanticVersion(major: 2, minor: 0, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update available
    let expectedLatest = SemanticVersion(major: 2, minor: 0, patch: 0)
    #expect(state == .updateAvailable(latestVersion: expectedLatest))
  }

  @Test("Update required when current is below minimum requirement")
  func updateRequiredWhenBelowMinimum() async throws {
    // Given: Current 1.0.0 is below required 1.2.0
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 2, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update required with required version
    let expectedRequired = SemanticVersion(major: 1, minor: 2, patch: 0)
    #expect(state == .updateRequired(requiredVersion: expectedRequired))
  }

  @Test("Update required takes priority over update available")
  func updateRequiredTakesPriority() async throws {
    // Given: Current 0.9.0 is below both required 1.0.0 and latest 2.0.0
    let currentVersion = SemanticVersion(major: 0, minor: 9, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 2, minor: 0, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update required (not update available)
    let expectedRequired = SemanticVersion(major: 1, minor: 0, patch: 0)
    #expect(state == .updateRequired(requiredVersion: expectedRequired))
  }

  @Test("Check caches requirements for later retrieval")
  func checkCachesRequirements() async throws {
    // Given: A checker with unique storage
    let suiteName = "test.cache.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )

    // When: Perform a check
    let checkState = try await checker.check()

    // Then: Cached state should match check result
    let cachedState = await checker.getCachedState()
    #expect(checkState == cachedState)

    let expectedLatest = SemanticVersion(major: 1, minor: 5, patch: 0)
    #expect(cachedState == .updateAvailable(latestVersion: expectedLatest))

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Get cached state returns up to date when no cache exists")
  func getCachedStateWithNoCache() async throws {
    // Given: A fresh checker with no previous checks
    let suiteName = "test.nocache.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 0, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )

    // When: Get cached state without checking first
    let cachedState = await checker.getCachedState()

    // Then: Should return up to date (default when no cache)
    #expect(cachedState == .upToDate)

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Cached state persists across different checker instances")
  func cachedStatePersists() async throws {
    // Given: A unique storage location
    let suiteName = "test.persist.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 2, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)

    // First checker performs a check
    let firstChecker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )
    _ = try await firstChecker.check()

    // When: Create a new checker with same storage
    let secondChecker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )

    // Then: Second checker should see first checker's cached data
    let cachedState = await secondChecker.getCachedState()
    let expectedRequired = SemanticVersion(major: 1, minor: 2, patch: 0)
    #expect(cachedState == .updateRequired(requiredVersion: expectedRequired))

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Last check date is nil before first check")
  func lastCheckDateInitiallyNil() async throws {
    // Given: A new checker with clean storage
    let suiteName = "test.nocheck.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 0, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )

    // When: Get last check date before any checks
    let lastCheckDate = await checker.getLastCheckDate()

    // Then: Should be nil
    #expect(lastCheckDate == nil)

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Last check date updates after successful check")
  func lastCheckDateUpdates() async throws {
    // Given: A checker with unique storage
    let suiteName = "test.checkdate.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 0, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let checker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )

    // Record time before check
    let beforeCheck = Date()

    // When: Perform a check
    _ = try await checker.check()

    // Then: Last check date should be set and recent
    let afterCheck = Date()
    let lastCheckDate = await checker.getLastCheckDate()

    #expect(lastCheckDate != nil)
    if let checkDate = lastCheckDate {
      #expect(checkDate >= beforeCheck)
      #expect(checkDate <= afterCheck)
    }

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Check throws error when provider throws")
  func checkThrowsProviderError() async throws {
    // Given: A provider that throws an error
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let provider = FailingVersionProvider(error: UpgradeError.noDataAvailable)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When/Then: Check should throw
    var didThrow = false
    do {
      _ = try await checker.check()
    }
    catch {
      didThrow = true
      #expect(error as? UpgradeError == .noDataAvailable)
    }

    #expect(didThrow == true)
  }

  @Test("Get cached state returns up to date after failed check")
  func getCachedStateAfterError() async throws {
    // Given: A provider that throws errors
    let suiteName = "test.error.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let provider = FailingVersionProvider(error: UpgradeError.providerError("Network error"))
    let checker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )

    // When: Try to check (will fail)
    do {
      _ = try await checker.check()
    }
    catch {
      // Expected to fail
    }

    // Then: Cached state should be up to date (no valid cache)
    let cachedState = await checker.getCachedState()
    #expect(cachedState == .upToDate)

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Get cached state returns old data after new check fails")
  func getCachedStateReturnsOldDataAfterError() async throws {
    // Given: A checker with successful cached data
    let suiteName = "test.oldcache.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 2, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )

    // First: Create successful check and cache data
    let workingProvider = MockVersionProvider(requirements: requirements)
    let firstChecker = VersionChecker(
      currentVersion: currentVersion,
      provider: workingProvider,
      suiteName: suiteName
    )
    _ = try await firstChecker.check()

    // Then: Create a failing provider with same storage
    let failingProvider = FailingVersionProvider(error: UpgradeError.noDataAvailable)
    let secondChecker = VersionChecker(
      currentVersion: currentVersion,
      provider: failingProvider,
      suiteName: suiteName
    )

    // When: Try to check with failing provider
    do {
      _ = try await secondChecker.check()
    }
    catch {
      // Expected to fail
    }

    // Then: Cached state should still have old successful data
    let cachedState = await secondChecker.getCachedState()
    let expectedRequired = SemanticVersion(major: 1, minor: 2, patch: 0)
    #expect(cachedState == .updateRequired(requiredVersion: expectedRequired))

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }
}
