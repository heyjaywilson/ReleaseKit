/// Semantic Version implementation
///
/// Use this version type if your app uses semantic versioning.
public struct SemanticVersion: Version {
  public let major: Int
  public let minor: Int
  public let patch: Int

  public init(major: Int, minor: Int, patch: Int) {
    self.major = major
    self.minor = minor
    self.patch = patch
  }

  public init?(string: String) {
    let components = string.split(separator: ".")
    guard components.count == 3 else { return nil }
    guard let major = Int(components[0]),
      let minor = Int(components[1]),
      let patch = Int(components[2])
    else { return nil }
    self.init(major: major, minor: minor, patch: patch)
  }

  public var stringValue: String {
    return "\(major).\(minor).\(patch)"
  }

  public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    if lhs.major != rhs.major {
      return lhs.major < rhs.major
    }
    if lhs.minor != rhs.minor {
      return lhs.minor < rhs.minor
    }
    return lhs.patch < rhs.patch
  }

  public static func > (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    if lhs.major != rhs.major {
      return lhs.major > rhs.major
    }
    if lhs.minor != rhs.minor {
      return lhs.minor > rhs.minor
    }
    return lhs.patch > rhs.patch
  }

  public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
  }

  public static func != (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    return lhs.major != rhs.major || lhs.minor != rhs.minor || lhs.patch != rhs.patch
  }
}
