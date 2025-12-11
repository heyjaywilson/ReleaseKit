import Foundation

/// Protocol for providing version information from your data source
public protocol VersionProvider: Sendable {
    associatedtype V: Version

    /// Fetch the version requirements from your data source.
    func fetchVersionRequirements() async throws -> VersionRequirement<V>
}
