import Foundation
import UIKit

/// Service for managing version upgrades
@Observable
public final class VersionUpgradeService<V: Version, P: VersionProvider>: Sendable where P.V == V {
  /// Current upgrade state
  public private(set) var state: UpgradeState<V> = .upToDate
  
  /// Current version of the app
  public let currentVersion: V
  
  private let provider: P
  /// Used to store the last seen version
  private let userDefaults: UserDefaults
  private let lastCheckKey = "VersionUpgradeService.lastCheckDate"
  private let cachedRequirementsKey = "VersionUpgradeService.cachedRequirements"
  
  private var lastCheckDate: Date? {
    get { userDefaults.object(forKey: lastCheckKey) as? Date }
    set { userDefaults.set(newValue, forKey: lastCheckKey) }
  }
  
  private var foregroundObserver: NSObjectProtocol?
  private var intervalTask: Task<Void, Never>?
  
  /// Initializes the version upgrade service
  /// - Parameters:
  ///   - provider: Provider for fetching version requirements
  ///   - checkInterval: How frequently to check for updates (default: onForeground)
  ///   - userDefaults: UserDefaults instance for persistence (default: .standard)
  public convenience init(
    provider: P,
    checkInterval: CheckInterval = .onForeground,
    userDefaults: UserDefaults = .standard
  ) {
    guard let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
          let version = V(string: versionString) else {
      fatalError("Unable to read app version from Bundle")
    }
    self.init(
      currentVersion: version,
      provider: provider,
      startChecking: checkInterval,
      userDefaults: userDefaults
    )
  }
  
  /// Internal initializer for testing
  /// - Parameters:
  ///   - currentVersion: The current version of the app
  ///   - provider: Provider for fetching version requirements
  ///   - startChecking: Optional check interval to start automatically (default: nil)
  ///   - userDefaults: UserDefaults instance for persistence (default: .standard)
  internal init(
    currentVersion: V,
    provider: P,
    startChecking: CheckInterval? = nil,
    userDefaults: UserDefaults = .standard
  ) {
    self.currentVersion = currentVersion
    self.provider = provider
    self.userDefaults = userDefaults
    
    do {
      if let requirements = try loadCachedRequirements() {
        try cacheRequirements(requirements)
      }
    } catch {
      handleError(error: error)
    }
    
    if let interval = startChecking {
      startAutomaticChecking(interval: interval)
    }
  }
  
  deinit {
    stopAutomaticChecking()
  }
  
  /// Manually check for updates
  public func checkForUpdates() async {
    do {
      let requirements = try await provider.fetchVersionRequirements()
      updateState(with: requirements)
      lastCheckDate = .now
      try cacheRequirements(requirements)
    } catch {
      handleError(error: error)
    }
  }
  
  /// Performs a check and returns the resulting state
  public func checkAndGetState() async -> UpgradeState<V> {
    await checkForUpdates()
    return state
  }
  
  /// Starts automatic version checking
  public func startAutomaticChecking(interval: CheckInterval) {
    // Stop any automatic checking
    stopAutomaticChecking()
    // Configure the version check
    switch interval {
      case .onForeground:
        setupForegroundObserver()
      case .interval(let timeInterval):
        setupIntervalTask(timeInterval)
      case .manual:
        break
    }
  }
  
  /// Stops automatic version checking
  public func stopAutomaticChecking() {
    if let observer = foregroundObserver {
      NotificationCenter.default.removeObserver(observer)
      foregroundObserver = nil
    }
    
    intervalTask?.cancel()
    intervalTask = nil
  }
  
  private func setupForegroundObserver() {
    foregroundObserver = NotificationCenter.default
      .addObserver(
        forName: UIApplication.willEnterForegroundNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        Task {
          await self?.checkForUpdates()
        }
      }
  }
  
  private func setupIntervalTask(_ interval: TimeInterval) {
    intervalTask = Task {
      while !Task.isCancelled {
        await checkForUpdates()
        try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
      }
    }
  }
  
  private func updateState(with requirements: VersionRequirement<V>) {
    if currentVersion < requirements.requiredVersion {
      state = .updateRequired(requiredVersion: requirements.requiredVersion)
    } else if currentVersion < requirements.latestVersion {
      state = .updateAvailable(latestVersion: requirements.latestVersion)
    } else {
      state = .upToDate
    }
  }
  
  private func cacheRequirements(_ requirements: VersionRequirement<V>) throws {
    let encoded = try JSONEncoder().encode(requirements)
    userDefaults.set(encoded, forKey: cachedRequirementsKey)
  }
  
  private func handleError(error: Error) {
    if let cachedRequirements = try? loadCachedRequirements() {
      updateState(with: cachedRequirements)
    } else {
      let upgradeError: UpgradeError
      if let err = error as? UpgradeError {
        upgradeError = err
      } else {
        upgradeError = .providerError(error.localizedDescription)
      }
      state = .error(error: upgradeError)
    }
  }
  
  private func loadCachedRequirements() throws -> VersionRequirement<V>? {
    guard let data = userDefaults.data(forKey: cachedRequirementsKey) else { return nil }
    return try JSONDecoder().decode(VersionRequirement<V>.self, from: data)
  }
}

