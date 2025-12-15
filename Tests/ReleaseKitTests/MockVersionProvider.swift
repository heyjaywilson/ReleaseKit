import Foundation
import ReleaseKit

/// Mock provider that returns predefined version requirements.
/// Mimics a real provider that successfully fetches data.
struct MockVersionProvider: VersionProvider {
  let requirements: VersionRequirement<SemanticVersion>

  func fetchVersionRequirements() async throws -> VersionRequirement<SemanticVersion> {
    return requirements
  }
}

/// Mock provider that always fails with an error.
/// Mimics a real provider experiencing network or data issues.
struct FailingVersionProvider: VersionProvider {
  let error: Error

  func fetchVersionRequirements() async throws -> VersionRequirement<SemanticVersion> {
    throw error
  }
}
