/// Build Number implementation
///
/// Use this version type if you want to check for new versions of the app based on build numbers.
public struct BuildNumber: Version {
  public let number: Int

  public init(number: Int) {
    self.number = number
  }

  public init?(string: String) {
    guard let number = Int(string) else { return nil }
    self.init(number: number)
  }

  public var stringValue: String {
    number.formatted()
  }

  public static func < (lhs: BuildNumber, rhs: BuildNumber) -> Bool {
    return lhs.number < rhs.number
  }
}
