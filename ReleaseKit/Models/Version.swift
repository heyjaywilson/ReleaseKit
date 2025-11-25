//
//  Version.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

import Foundation

struct Version: Identifiable {
  /// Identifier for version
  var id: String { version }
  var title: String
  var icon: String?
  var version: String
  var releaseDate: Date
  /// Entries broken into categories
  var entries: [Entry]
  
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
      mockFeatures + [mockImprovements[2]] + [
        mockBugFixes[1],
        mockBugFixes[0],
        mockBugFixes[2],
      ]
  )
}
#endif
