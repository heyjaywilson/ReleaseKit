//
//  Version.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

import Foundation
import SwiftUI

public struct Version: Identifiable, Sendable {
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
  
  static let mockVersions: [Version] = [
    Version(
      title: "Winter Update",
      icon: "snowflake",
      version: "2.1.0",
      releaseDate: Date(timeIntervalSince1970: 1704067200), // January 1, 2024
      entries: [
        Entry(
          id: "1",
          text: "New dark mode theme with improved contrast",
          isFeatured: true,
          icon: "moon.stars",
          category: Category(
            id: "ui",
            name: "UI Improvements",
            featuredBackgroundColor: .blue,
            sortOrder: 1,
            icon: "paintbrush"
          )
        ),
        Entry(
          id: "2",
          text: "Added offline mode for viewing saved content",
          isFeatured: true,
          icon: "wifi.slash",
          category: Category(
            id: "features",
            name: "New Features",
            featuredBackgroundColor: .purple,
            sortOrder: 2,
            icon: "star"
          )
        ),
        Entry(
          id: "3",
          text: "Fixed crash when scrolling through large lists",
          isFeatured: false,
          icon: "wrench",
          category: Category(
            id: "bugfixes",
            name: "Bug Fixes",
            featuredBackgroundColor: .green,
            sortOrder: 3,
            icon: "ant"
          )
        )
      ]
    ),
    Version(
      title: "Spring Release",
      icon: "leaf",
      version: "2.0.0",
      releaseDate: Date(timeIntervalSince1970: 1711929600), // April 1, 2024
      entries: [
        Entry(
          id: "4",
          text: "Complete redesign with modern navigation",
          isFeatured: true,
          icon: "sparkles",
          category: Category(
            id: "ui",
            name: "UI Improvements",
            featuredBackgroundColor: .blue,
            sortOrder: 1,
            icon: "paintbrush"
          )
        ),
        Entry(
          id: "5",
          text: "Performance improvements for faster loading",
          isFeatured: false,
          icon: "bolt",
          category: Category(
            id: "performance",
            name: "Performance",
            featuredBackgroundColor: .orange,
            sortOrder: 4,
            icon: "speedometer"
          )
        )
      ]
    ),
    Version(
      title: "Summer Edition",
      icon: "sun.max",
      version: "1.5.0",
      releaseDate: Date(timeIntervalSince1970: 1719792000), // July 1, 2024
      entries: [
        Entry(
          id: "6",
          text: "Added widget support for home screen",
          isFeatured: true,
          icon: "square.grid.2x2",
          category: Category(
            id: "features",
            name: "New Features",
            featuredBackgroundColor: .purple,
            sortOrder: 2,
            icon: "star"
          )
        ),
        Entry(
          id: "7",
          text: "Improved accessibility with VoiceOver",
          isFeatured: true,
          icon: "accessibility",
          category: Category(
            id: "ui",
            name: "UI Improvements",
            featuredBackgroundColor: .blue,
            sortOrder: 1,
            icon: "paintbrush"
          )
        ),
        Entry(
          id: "8",
          text: "Fixed memory leak in image loading",
          isFeatured: false,
          icon: "memorychip",
          category: Category(
            id: "bugfixes",
            name: "Bug Fixes",
            featuredBackgroundColor: .green,
            sortOrder: 3,
            icon: "ant"
          )
        )
      ]
    )
  ]
}
#endif
