//
//  Category.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

import SwiftUI
import Foundation

/// A category for organizing release notes entries.
/// Users can create custom categories or use the provided default ones.
public struct Category: Identifiable, Hashable, Sendable {
  /// Unique identifier for the category
  public let id: String
  
  /// Display name for the category
  let name: String
  
  /// Background color used when displaying featured entries of this category
  let featuredBackgroundColor: Color
  
  /// Sort order for displaying categories (lower numbers appear first)
  let sortOrder: Int
  
  /// Optional icon name (SF Symbol) for the category
  let icon: String?
  
  public init(
    id: String,
    name: String,
    featuredBackgroundColor: Color,
    sortOrder: Int,
    icon: String? = nil
  ) {
    self.id = id
    self.name = name
    self.featuredBackgroundColor = featuredBackgroundColor
    self.sortOrder = sortOrder
    self.icon = icon
  }
}

/// Default categories
extension Category {
  /// Default "Feature" category
  public static let feature = Category(
    id: "feature",
    name: "Features",
    featuredBackgroundColor: .green,
    sortOrder: 0
  )
  
  /// Default "Improvements" category
  public static let improvements = Category(
    id: "improvements",
    name: "Improvements",
    featuredBackgroundColor: .teal,
    sortOrder: 1
  )
  
  /// Default "Bug Fix" category
  public static let bugFix = Category(
    id: "bugFix",
    name: "Fixes",
    featuredBackgroundColor: .red,
    sortOrder: 2
  )
  
  /// All default categories
  public static let defaults: [Category] = [
    .feature,
    .improvements,
    .bugFix
  ]
}
