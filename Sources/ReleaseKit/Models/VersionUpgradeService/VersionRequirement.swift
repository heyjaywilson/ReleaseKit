/// Represents version upgrade requirements
///
/// requiredVersion: The version that is required to use the app
/// latestVersion: The version that is the latest version of the app
public struct VersionRequirement<V: Version>: Codable {
    public let requiredVersion: V
    public let latestVersion: V

    public init(requiredVersion: V, latestVersion: V) {
        self.requiredVersion = requiredVersion
        self.latestVersion = latestVersion
    }
}
