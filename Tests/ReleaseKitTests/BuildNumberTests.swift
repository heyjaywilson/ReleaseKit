import Foundation
import Testing

@testable import ReleaseKit

@Suite("BuildNumber Tests")
struct BuildNumberTests {

  @Test("BuildNumber initializes from integer")
  func initFromInteger() throws {
    // Given: Build number 42
    let buildNumber = BuildNumber(number: 42)

    // Then: Should store value correctly
    #expect(buildNumber.number == 42)
    #expect(buildNumber.stringValue == "42")
  }

  @Test("BuildNumber initializes from valid string")
  func initFromValidString() throws {
    // Given: Valid numeric string
    let buildNumber = BuildNumber(string: "100")

    // Then: Should initialize successfully
    #expect(buildNumber != nil)
    #expect(buildNumber?.number == 100)
    #expect(buildNumber?.stringValue == "100")
  }

  @Test(
    "BuildNumber returns nil for invalid string",
    arguments: ["abc", "1.2.3", "1.0", "", "12a", "a12"]
  )
  func initFromInvalidString(invalidString: String) throws {
    let buildNumber = BuildNumber(string: invalidString)
    #expect(buildNumber == nil)
  }

  @Test("BuildNumber comparison operators work correctly")
  func comparisonOperators() throws {
    // Given: Various build numbers
    let build10 = BuildNumber(number: 10)
    let build20 = BuildNumber(number: 20)
    let build20Duplicate = BuildNumber(number: 20)

    // Then: Comparison operators should work
    #expect(build10 < build20)
    #expect(build20 > build10)
    #expect(build20 == build20Duplicate)
    #expect(build10 != build20)
    #expect(build10 <= build20)
    #expect(build20 >= build10)
    #expect(build20 <= build20Duplicate)
    #expect(build20 >= build20Duplicate)
  }

  @Test(
    "BuildNumber comparison with sequential numbers",
    arguments: [
      (1, 2), (2, 3), (3, 4), (4, 5),
    ]
  )
  func sequentialComparison(lower: Int, higher: Int) throws {
    let lowerBuild = BuildNumber(number: lower)
    let higherBuild = BuildNumber(number: higher)

    #expect(lowerBuild < higherBuild)
    #expect(higherBuild > lowerBuild)
  }

  @Test(
    "BuildNumber string value formatting",
    arguments: [
      (1, "1"),
      (100, "100"),
      (1000, "1,000"),
      (1_000_000, "1,000,000"),
    ]
  )
  func stringValueFormatting(number: Int, expectedString: String) throws {
    let buildNumber = BuildNumber(number: number)
    #expect(buildNumber.stringValue == expectedString)
  }

  @Test("BuildNumber description matches string value")
  func descriptionMatchesStringValue() throws {
    // Given: A build number
    let buildNumber = BuildNumber(number: 42)

    // Then: Description should match stringValue
    #expect(buildNumber.description == buildNumber.stringValue)
  }

  @Test("App is up to date when current build equals latest")
  func upToDateWhenCurrentEqualsLatest() async throws {
    // Given: Current build 100 matches latest build 100
    let currentVersion = BuildNumber(number: 100)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 50),
      latestVersion: BuildNumber(number: 100)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: State should be up to date
    #expect(state == .upToDate)
  }

  @Test("App is up to date when current build is newer than latest")
  func upToDateWhenCurrentIsNewer() async throws {
    // Given: Current build 200 is newer than latest 150 (beta/test build)
    let currentVersion = BuildNumber(number: 200)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 150)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: State should be up to date
    #expect(state == .upToDate)
  }

  @Test("Update available when current is behind latest but meets minimum requirement")
  func updateAvailableWhenBehindLatest() async throws {
    // Given: Current 120, required 100, latest 150
    let currentVersion = BuildNumber(number: 120)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 150)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update available with latest version
    let expectedLatest = BuildNumber(number: 150)
    #expect(state == .updateAvailable(latestVersion: expectedLatest))
  }

  @Test("Update available when current equals required but latest is newer")
  func updateAvailableWhenAtMinimum() async throws {
    // Given: Current 100 equals required 100, but latest is 200
    let currentVersion = BuildNumber(number: 100)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 200)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update available
    let expectedLatest = BuildNumber(number: 200)
    #expect(state == .updateAvailable(latestVersion: expectedLatest))
  }

  @Test("Update required when current is below minimum requirement")
  func updateRequiredWhenBelowMinimum() async throws {
    // Given: Current 50 is below required 100
    let currentVersion = BuildNumber(number: 50)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 150)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update required with required version
    let expectedRequired = BuildNumber(number: 100)
    #expect(state == .updateRequired(requiredVersion: expectedRequired))
  }

  @Test("Update required takes priority over update available")
  func updateRequiredTakesPriority() async throws {
    // Given: Current 90 is below both required 100 and latest 200
    let currentVersion = BuildNumber(number: 90)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 200)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update required (not update available)
    let expectedRequired = BuildNumber(number: 100)
    #expect(state == .updateRequired(requiredVersion: expectedRequired))
  }

  @Test("Check caches requirements for later retrieval")
  func checkCachesRequirements() async throws {
    // Given: A checker with unique storage
    let suiteName = "test.buildnumber.cache.\(UUID().uuidString)"
    let currentVersion = BuildNumber(number: 100)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 150)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
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

    let expectedLatest = BuildNumber(number: 150)
    #expect(cachedState == .updateAvailable(latestVersion: expectedLatest))

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Get cached state returns up to date when no cache exists")
  func getCachedStateWithNoCache() async throws {
    // Given: A fresh checker with no previous checks
    let suiteName = "test.buildnumber.nocache.\(UUID().uuidString)"
    let currentVersion = BuildNumber(number: 100)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 100)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
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
    let suiteName = "test.buildnumber.persist.\(UUID().uuidString)"
    let currentVersion = BuildNumber(number: 100)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 120),
      latestVersion: BuildNumber(number: 150)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)

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
    let expectedRequired = BuildNumber(number: 120)
    #expect(cachedState == .updateRequired(requiredVersion: expectedRequired))

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Last check date is nil before first check")
  func lastCheckDateInitiallyNil() async throws {
    // Given: A new checker with clean storage
    let suiteName = "test.buildnumber.nocheck.\(UUID().uuidString)"
    let currentVersion = BuildNumber(number: 100)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 100)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
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
    let suiteName = "test.buildnumber.checkdate.\(UUID().uuidString)"
    let currentVersion = BuildNumber(number: 100)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 100)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
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
    let currentVersion = BuildNumber(number: 100)
    let provider = FailingBuildNumberProvider(error: UpgradeError.noDataAvailable)
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
    let suiteName = "test.buildnumber.error.\(UUID().uuidString)"
    let currentVersion = BuildNumber(number: 100)
    let provider = FailingBuildNumberProvider(error: UpgradeError.providerError("Network error"))
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
    let suiteName = "test.buildnumber.oldcache.\(UUID().uuidString)"
    let currentVersion = BuildNumber(number: 100)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 120),
      latestVersion: BuildNumber(number: 150)
    )

    // First: Create successful check and cache data
    let workingProvider = MockBuildNumberProvider(requirements: requirements)
    let firstChecker = VersionChecker(
      currentVersion: currentVersion,
      provider: workingProvider,
      suiteName: suiteName
    )
    _ = try await firstChecker.check()

    // Then: Create a failing provider with same storage
    let failingProvider = FailingBuildNumberProvider(error: UpgradeError.noDataAvailable)
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
    let expectedRequired = BuildNumber(number: 120)
    #expect(cachedState == .updateRequired(requiredVersion: expectedRequired))

    // Cleanup
    UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
  }

  @Test("Realistic build number progression scenario")
  func realisticBuildProgression() async throws {
    // Given: A typical app build progression scenario
    // Production: build 1000, TestFlight beta: build 1050
    let currentVersion = BuildNumber(number: 1000)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 950),
      latestVersion: BuildNumber(number: 1050)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update available
    let expectedLatest = BuildNumber(number: 1050)
    #expect(state == .updateAvailable(latestVersion: expectedLatest))
  }

  @Test("Deprecated build must update scenario")
  func deprecatedBuildMustUpdate() async throws {
    // Given: Old build that must update
    let currentVersion = BuildNumber(number: 50)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 100),
      latestVersion: BuildNumber(number: 150)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should require update
    let expectedRequired = BuildNumber(number: 100)
    #expect(state == .updateRequired(requiredVersion: expectedRequired))
  }

  @Test("Build numbers with large values")
  func largeBuilNumberValues() async throws {
    // Given: Large build numbers (e.g., date-based: 20231201)
    let currentVersion = BuildNumber(number: 20_231_201)
    let requirements = VersionRequirement(
      requiredVersion: BuildNumber(number: 20_231_101),
      latestVersion: BuildNumber(number: 20_231_215)
    )
    let provider = MockBuildNumberProvider(requirements: requirements)
    let checker = VersionChecker(currentVersion: currentVersion, provider: provider)

    // When: Check for updates
    let state = try await checker.check()

    // Then: Should show update available
    let expectedLatest = BuildNumber(number: 20_231_215)
    #expect(state == .updateAvailable(latestVersion: expectedLatest))
  }
}
