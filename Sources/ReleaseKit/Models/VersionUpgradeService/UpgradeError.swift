import Foundation

/// Errors that can occur during version checking
public enum UpgradeError: Error, Equatable {
  /// Error occurred while fetching version requirements
  case providerError(String)
  /// Invalid version data received from the provider
  case invalidVersionData(String)
  /// No data available from the provider
  case noDataAvailable
}
