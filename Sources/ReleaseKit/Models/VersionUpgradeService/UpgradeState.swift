import Foundation

/// The state of the version upgrade service
public enum UpgradeState<V: Version>: Equatable, Sendable {
  /// The app is up to date and no update is needed
  case upToDate
  /// Optional update available
  case updateAvailable(latestVersion: V)
  /// Required update available
  case updateRequired(requiredVersion: V)
  /// Error occurred while checking for updates
  case error(error: UpgradeError)

  public static func == (lhs: UpgradeState<V>, rhs: UpgradeState<V>) -> Bool {
    switch (lhs, rhs) {
      case (.upToDate, .upToDate):
        return true
      case (.updateAvailable(let lhsVersion), .updateAvailable(let rhsVersion)):
        return lhsVersion == rhsVersion
      case (.updateRequired(let lhsVersion), .updateRequired(let rhsVersion)):
        return lhsVersion == rhsVersion
      default:
        return false
    }
  }
}
