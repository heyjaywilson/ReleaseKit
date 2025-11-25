//
//  Entry.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

public struct Entry: Identifiable {
  public var id: String
  var text: String
  var isFeatured: Bool
  var icon: String?
  var category: Category
  
  public init(
    id: String,
    text: String,
    isFeatured: Bool,
    icon: String? = nil,
    category: Category
  ) {
    self.id = id
    self.text = text
    self.isFeatured = isFeatured
    self.icon = icon
    self.category = category
  }
}

#if DEBUG
extension Entry {
  static let allEntries = mockFeatures + mockImprovements + mockBugFixes
  static let mockFeatures = [
    Entry(
      id: "1",
      text: "Added dark mode support across all screens",
      isFeatured: true,
      icon: "moon.stars.fill",
      category: .feature
    ),
    Entry(
      id: "4",
      text: "Added support for multiple user accounts",
      isFeatured: false,
      icon: "person.2.fill",
      category: .feature
    ),
    Entry(
      id: "7",
      text: "Added biometric authentication",
      isFeatured: false,
      icon: "faceid",
      category: .feature
    ),
    Entry(
      id: "10",
      text: "Added export to PDF functionality",
      isFeatured: false,
      icon: "doc.fill",
      category: .feature
    ),
    Entry(
      id: "13",
      text: "Added widget support for home screen",
      isFeatured: false,
      icon: "square.grid.2x2.fill",
      category: .feature
    )
  ]
  
  static let mockImprovements = [
    Entry(
      id: "3",
      text: "Improved app launch time by 40%",
      isFeatured: true,
      icon: "bolt.fill",
      category: .improvements
    ),
    Entry(
      id: "6",
      text: "Enhanced search with fuzzy matching",
      isFeatured: true,
      icon: "magnifyingglass",
      category: .improvements
    ),
    Entry(
      id: "9",
      text: "Improved accessibility with VoiceOver support",
      isFeatured: false,
      icon: "accessibility",
      category: .improvements
    ),
    Entry(
      id: "12",
      text: "Reduced network data usage by 30%",
      isFeatured: true,
      icon: "antenna.radiowaves.left.and.right",
      category: .improvements
    ),
    Entry(
      id: "15",
      text: "Improved animation smoothness throughout the app",
      isFeatured: false,
      icon: "sparkles",
      category: .improvements
    )
  ]
  
  static let mockBugFixes = [
    Entry(
      id: "2",
      text: "Fixed crash when uploading large images",
      isFeatured: true,
      icon: "exclamationmark.triangle.fill",
      category: .bugFix
    ),
    Entry(
      id: "5",
      text: "Fixed notification badge not clearing after viewing",
      isFeatured: false,
      icon: nil,
      category: .bugFix
    ),
    Entry(
      id: "8",
      text: "Fixed memory leak in video player",
      isFeatured: false,
      icon: nil,
      category: .bugFix
    ),
    Entry(
      id: "11",
      text: "Fixed incorrect date formatting in certain locales",
      isFeatured: false,
      icon: nil,
      category: .bugFix
    ),
    Entry(
      id: "14",
      text: "Fixed keyboard dismissal issues on iPad",
      isFeatured: false,
      icon: nil,
      category: .bugFix
    )
  ]
}
#endif
