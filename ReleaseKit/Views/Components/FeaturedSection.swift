//
//  FeaturedSection.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/25/25.
//

import SwiftUI

struct FeaturedSection: View {
  var entries: [Entry]
  
  var categorizedEntries: [Entry] {
    entries.sorted { $0.category.sortOrder < $1.category.sortOrder }
  }
  
  var body: some View {
    Group {
      ForEach(categorizedEntries) { entry in
        Section {
          HStack(spacing: 16) {
            if let iconName = entry.icon {
              Image(systemName: iconName)
            }
            Text(entry.text)
          }
          .font(.headline)
          .foregroundStyle(.white)
        .listRowBackground(entry.category.featuredBackgroundColor)
        }
        .listSectionSpacing(12)
      }
    }
  }
}

#Preview {
  List {
    FeaturedSection(entries: Entry.allEntries.filter({ $0.isFeatured }))
  }
}
