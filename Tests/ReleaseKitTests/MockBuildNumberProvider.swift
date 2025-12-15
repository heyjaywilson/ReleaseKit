import Foundation
import ReleaseKit

struct MockBuildNumberProvider: VersionProvider {
  let requirements: VersionRequirement<BuildNumber>

  func fetchVersionRequirements() async throws -> VersionRequirement<BuildNumber> {
    return requirements
  }
}
