import Foundation
import ReleaseKit

struct FailingBuildNumberProvider: VersionProvider {
  let error: Error

  func fetchVersionRequirements() async throws -> VersionRequirement<BuildNumber> {
    throw error
  }
}
