import Foundation

/// Defines requirements for version types
public protocol Version: Codable, Sendable, Comparable, Hashable, CustomStringConvertible {
    init?(string: String)

    var stringValue: String { get }
}

extension Version {
    public var description: String {
        return stringValue
    }
}
