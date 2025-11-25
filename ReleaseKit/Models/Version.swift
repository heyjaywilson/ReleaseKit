//
//  Version.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

import Foundation

public struct Version: Identifiable {
  /// Identifier for version
  public var id: String { version }
  var title: String
  var icon: String?
  var version: String
  var releaseDate: Date
  var entries: [Entry]
  
  public init(title: String, icon: String? = nil, version: String, releaseDate: Date, entries: [Entry]) {
    self.title = title
    self.icon = icon
    self.version = version
    self.releaseDate = releaseDate
    self.entries = entries
  }
  
  var featured: [Entry] {
    entries.filter { $0.isFeatured }
  }
  
  var features: [Entry] {
    entries
      .filter { !$0.isFeatured }
      .filter { $0.category == .feature }
  }
  
  var improvements: [Entry] {
    entries
      .filter { !$0.isFeatured }
      .filter { $0.category == .improvements }
  }
  
  var fixes: [Entry] {
    entries
      .filter { !$0.isFeatured }
      .filter { $0.category == .bugFix }
  }
}

#if DEBUG
extension Version {
  static let mock: Version = .init(
    title: "It's alive!",
    icon: "megaphone",
    version: "1.0.0",
    releaseDate: Date(),
    entries:
      Entry.mockFeatures + [Entry.mockImprovements[2]] + [
        Entry.mockBugFixes[1],
        Entry.mockBugFixes[0],
        Entry.mockBugFixes[2],
      ]
  )
}
#endif
