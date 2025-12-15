import Foundation

/// Actor responsible for checking version requirements and managing cached state
/// This actor provides thread-safe access to version checking logic and caching
public actor VersionChecker<V: Version, P: VersionProvider>: Sendable where P.V == V {
  /// Current version of the app
  public let currentVersion: V

  private let provider: P
  private let suiteName: String?

  // UserDefaults keys
  private let lastCheckKey = "VersionUpgradeService.lastCheckDate"
  private let cachedRequirementsKey = "VersionUpgradeService.cachedRequirements"

  /// Computed property to get UserDefaults instance
  private var userDefaults: UserDefaults {
    if let suiteName {
      return UserDefaults(suiteName: suiteName) ?? .standard
    }
    return .standard
  }

  private var lastCheckDate: Date? {
    get { userDefaults.object(forKey: lastCheckKey) as? Date }
    set { userDefaults.set(newValue, forKey: lastCheckKey) }
  }

  /// Initialize the version checker
  /// - Parameters:
  ///   - currentVersion: The current version of the app
  ///   - provider: Provider for fetching version requirements
  ///   - suiteName: Optional UserDefaults suite name for storage
  public init(
    currentVersion: V,
    provider: P,
    suiteName: String? = nil
  ) {
    self.currentVersion = currentVersion
    self.provider = provider
    self.suiteName = suiteName
  }

  /// Check for updates by fetching from provider and computing state
  /// - Returns: The upgrade state based on fetched requirements
  /// - Throws: Any error from the provider
  public func check() async throws -> UpgradeState<V> {
    let requirements = try await provider.fetchVersionRequirements()
    lastCheckDate = .now
    try cacheRequirements(requirements)
    return computeState(with: requirements)
  }

  /// Get the cached state without making a network call
  /// - Returns: The upgrade state based on cached requirements, or .upToDate if no cache exists
  public func getCachedState() -> UpgradeState<V> {
    guard let requirements = try? loadCachedRequirements() else {
      return .upToDate
    }
    return computeState(with: requirements)
  }

  /// Get the last check date
  /// - Returns: The date of the last successful check, or nil if never checked
  public func getLastCheckDate() -> Date? {
    return lastCheckDate
  }

  // MARK: - Private Helpers

  private func computeState(with requirements: VersionRequirement<V>) -> UpgradeState<V> {
    if currentVersion < requirements.requiredVersion {
      return .updateRequired(requiredVersion: requirements.requiredVersion)
    }
    else if currentVersion < requirements.latestVersion {
      return .updateAvailable(latestVersion: requirements.latestVersion)
    }
    else {
      return .upToDate
    }
  }

  private func cacheRequirements(_ requirements: VersionRequirement<V>) throws {
    let encoded = try JSONEncoder().encode(requirements)
    userDefaults.set(encoded, forKey: cachedRequirementsKey)
  }

  private func loadCachedRequirements() throws -> VersionRequirement<V>? {
    guard let data = userDefaults.data(forKey: cachedRequirementsKey) else { return nil }
    return try JSONDecoder().decode(VersionRequirement<V>.self, from: data)
  }
}
