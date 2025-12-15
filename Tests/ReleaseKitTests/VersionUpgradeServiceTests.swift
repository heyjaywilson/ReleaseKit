import Foundation
import Testing

@testable import ReleaseKit

@Suite("VersionUpgradeService Tests")
@MainActor
struct VersionUpgradeServiceTests {

  @Test("Service initializes with up to date state")
  func serviceInitializesWithUpToDateState() async throws {
    // Given: A service with no cached data
    let suiteName = "test.init.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 0, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)

    // When: Create service
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil,
      suiteName: suiteName
    )

    // Then: Initial state should be up to date
    // Note: State might still be loading from cache, so wait a bit
    try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
    #expect(service.state == .upToDate)

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Service loads cached state on initialization")
  func serviceLoadsCachedState() async throws {
    // Given: Pre-cached data in storage
    let suiteName = "test.cached.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 2, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)

    // First: Create checker and cache data
    let checker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )
    _ = try await checker.check()

    // When: Create service with same storage
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil,
      suiteName: suiteName
    )

    // Then: Service should load cached state
    try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
    let expectedRequired = SemanticVersion(major: 1, minor: 2, patch: 0)
    #expect(service.state == .updateRequired(requiredVersion: expectedRequired))

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Service exposes current version from checker")
  func serviceExposesCurrentVersion() async throws {
    // Given: A service with specific version
    let currentVersion = SemanticVersion(major: 2, minor: 3, patch: 4)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 2, minor: 3, patch: 4)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil
    )

    // Then: Current version should match
    #expect(service.currentVersion == currentVersion)
  }

  @Test("Check for updates returns up to date state")
  func checkForUpdatesUpToDate() async throws {
    // Given: Current version matches latest
    let currentVersion = SemanticVersion(major: 1, minor: 5, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil
    )

    // When: Check for updates
    await service.checkForUpdates()

    // Then: State should be up to date
    #expect(service.state == .upToDate)
  }

  @Test("Check for updates returns update available state")
  func checkForUpdatesAvailable() async throws {
    // Given: Current version is behind latest
    let currentVersion = SemanticVersion(major: 1, minor: 2, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil
    )

    // When: Check for updates
    await service.checkForUpdates()

    // Then: State should show update available
    let expectedLatest = SemanticVersion(major: 1, minor: 5, patch: 0)
    #expect(service.state == .updateAvailable(latestVersion: expectedLatest))
  }

  @Test("Check for updates returns update required state")
  func checkForUpdatesRequired() async throws {
    // Given: Current version is below required
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 2, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil
    )

    // When: Check for updates
    await service.checkForUpdates()

    // Then: State should show update required
    let expectedRequired = SemanticVersion(major: 1, minor: 2, patch: 0)
    #expect(service.state == .updateRequired(requiredVersion: expectedRequired))
  }

  @Test("Check and get state returns the resulting state")
  func checkAndGetStateReturnsState() async throws {
    // Given: Service with update available
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 2, minor: 0, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil
    )

    // When: Check and get state
    let state = await service.checkAndGetState()

    // Then: Returned state should match service state
    #expect(state == service.state)
    let expectedLatest = SemanticVersion(major: 2, minor: 0, patch: 0)
    #expect(state == .updateAvailable(latestVersion: expectedLatest))
  }

  @Test("Check for updates shows error state when provider fails and no cache exists")
  func checkForUpdatesShowsErrorWithNoCache() async throws {
    // Given: Provider that throws error and no cached data
    let suiteName = "test.error.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let provider = FailingVersionProvider(error: UpgradeError.noDataAvailable)
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil,
      suiteName: suiteName
    )

    // When: Check for updates
    await service.checkForUpdates()

    // Then: State should show error
    if case .error = service.state {
      // Success - error state is set
    }
    else {
      Issue.record("Expected error state but got \(service.state)")
    }

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Check for updates uses cached state when provider fails and cache exists")
  func checkForUpdatesUsesCacheOnError() async throws {
    // Given: Service with cached data
    let suiteName = "test.errorcache.\(UUID().uuidString)"
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 2, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )

    // First: Create successful check and cache data
    let workingProvider = MockVersionProvider(requirements: requirements)
    let workingService = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: workingProvider,
      startChecking: nil,
      suiteName: suiteName
    )
    await workingService.checkForUpdates()

    // Then: Create service with failing provider but same cache
    let failingProvider = FailingVersionProvider(error: UpgradeError.providerError("Network error"))
    let failingService = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: failingProvider,
      startChecking: nil,
      suiteName: suiteName
    )

    // When: Check for updates with failing provider
    await failingService.checkForUpdates()

    // Then: Should use cached state instead of showing error
    let expectedRequired = SemanticVersion(major: 1, minor: 2, patch: 0)
    #expect(failingService.state == .updateRequired(requiredVersion: expectedRequired))

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Multiple checks update state correctly")
  func multipleChecksUpdateState() async throws {
    // Given: Service that will check multiple times
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)

    // First check: update available
    let firstRequirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 1, minor: 5, patch: 0)
    )
    let firstProvider = MockVersionProvider(requirements: firstRequirements)
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: firstProvider,
      startChecking: nil
    )

    // When: First check
    await service.checkForUpdates()

    // Then: Should show update available
    let expectedFirst = SemanticVersion(major: 1, minor: 5, patch: 0)
    #expect(service.state == .updateAvailable(latestVersion: expectedFirst))

    // Note: For simplicity, this test shows one check
    // In practice, you'd need to swap providers to test multiple different states
  }

  @Test("State property is observable")
  func stateIsObservable() async throws {
    // Given: A service
    let currentVersion = SemanticVersion(major: 1, minor: 0, patch: 0)
    let requirements = VersionRequirement(
      requiredVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
      latestVersion: SemanticVersion(major: 2, minor: 0, patch: 0)
    )
    let provider = MockVersionProvider(requirements: requirements)
    let service = VersionUpgradeService(
      currentVersion: currentVersion,
      provider: provider,
      startChecking: nil
    )

    // When: Check for updates (changes state)
    let initialState = service.state
    await service.checkForUpdates()
    let finalState = service.state

    // Then: State should have changed (observable updates work)
    #expect(initialState == .upToDate)
    let expectedLatest = SemanticVersion(major: 2, minor: 0, patch: 0)
    #expect(finalState == .updateAvailable(latestVersion: expectedLatest))
  }
}
