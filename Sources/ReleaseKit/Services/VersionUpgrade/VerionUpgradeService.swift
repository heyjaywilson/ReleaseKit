import Foundation
import UIKit

/// Service for managing version upgrades
/// This is a MainActor-isolated observable class that coordinates UI state updates
/// and delegates actual version checking to a VersionChecker actor
@MainActor
@Observable
public final class VersionUpgradeService<V: Version, P: VersionProvider> where P.V == V {
  /// Current upgrade state
  public private(set) var state: UpgradeState<V> = .upToDate

  /// Current version of the app
  public var currentVersion: V {
    checker.currentVersion
  }

  private let checker: VersionChecker<V, P>
  private var foregroundObserver: NSObjectProtocol?
  private var intervalTask: Task<Void, Never>?

  /// Initializes the version upgrade service based on the short version string in the bundle
  ///
  /// - Parameters:
  ///   - provider: Provider for fetching version requirements
  ///   - checkInterval: How frequently to check for updates (default: onForeground)
  ///   - suiteName: Optional UserDefaults suite name for persistence (default: nil, uses standard)
  public convenience init(
    provider: P,
    checkInterval: CheckInterval = .onForeground,
    suiteName: String? = nil
  ) {
    guard let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
      let version = V(string: versionString)
    else {
      fatalError("Unable to read app version from Bundle")
    }
    self.init(
      currentVersion: version,
      provider: provider,
      startChecking: checkInterval,
      suiteName: suiteName
    )
  }

  /// Initializes the version upgrade service based on the version given
  ///
  /// Use this when you do not want to use the short version string in the bundle
  /// - Parameters:
  ///   - currentVersion: The current version of the app
  ///   - provider: Provider for fetching version requirements
  ///   - startChecking: Optional check interval to start automatically (default: nil)
  ///   - suiteName: Optional UserDefaults suite name for persistence (default: nil, uses standard)
  public init(
    currentVersion: V,
    provider: P,
    startChecking: CheckInterval? = nil,
    suiteName: String? = nil
  ) {
    self.checker = VersionChecker(
      currentVersion: currentVersion,
      provider: provider,
      suiteName: suiteName
    )

    if let interval = startChecking {
      startAutomaticChecking(interval: interval)
    }

    // Load cached state asynchronously after initialization
    Task {
      self.state = await checker.getCachedState()
    }
  }

  /// Manually check for update
  public func checkForUpdates() async {
    do {
      state = try await checker.check()
    }
    catch {
      // On error, fall back to cached state
      state = await handleError(error: error)
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
    // Perform initial check on first run
    Task { @MainActor in
      await checkForUpdates()
    }

    // Set up observer for future foreground events
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

  private func handleError(error: Error) async -> UpgradeState<V> {
    // Try to get cached state from checker
    let cachedState = await checker.getCachedState()

    // If cached state is not .upToDate, use it
    if cachedState != .upToDate {
      return cachedState
    }

    // Otherwise, return error state
    let upgradeError: UpgradeError
    if let err = error as? UpgradeError {
      upgradeError = err
    }
    else {
      upgradeError = .providerError(error.localizedDescription)
    }
    return .error(error: upgradeError)
  }
}
