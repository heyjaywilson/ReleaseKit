import Foundation

/// Defines how frequently to check for updates
public enum CheckInterval {
  /// Check on every app foreground
  case onForeground

  /// Check at specified time intervals
  case interval(TimeInterval)

  /// Never automatically check (manual only)
  case manual
}
