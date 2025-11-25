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
    
  /// Get all unique categories from the entries, sorted by sortOrder
  var categories: [Category] {
    return Set(entries.map { $0.category }).sorted(by: { $0.sortOrder < $1.sortOrder })
  }
  
  /// Dictionary of entries grouped by category
  var entriesByCategory: [Category: [Entry]] {
    Dictionary(grouping: entries, by: { $0.category })
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
