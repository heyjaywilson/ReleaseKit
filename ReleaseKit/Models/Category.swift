//
//  Category.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

import SwiftUI

enum Category: String, CaseIterable {
  case feature
  case improvements
  case bugFix
  
  var featuredBackgroundColor: Color {
    switch self {
      case .feature:
          .green
      case .improvements:
          .teal
      case .bugFix:
          .red
    }
  }
}
