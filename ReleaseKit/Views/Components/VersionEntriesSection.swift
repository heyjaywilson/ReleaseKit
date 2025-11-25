//
//  VersionEntriesSection.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/25/25.
//

import SwiftUI

public struct VersionEntriesSection: View {
  public var category: Category
  public var entries: [Entry]
  
  public init(category: Category, entries: [Entry]) {
    self.category = category
    self.entries = entries
  }
  
  public var body: some View {
    Section {
      ForEach(entries) { entry in
        HStack(spacing: 16) {
          if let icon = entry.icon {
            Image(systemName: icon)
          }
          Text(entry.text)
        }
      }
    } header: {
      Text(category.name)
    }
  }
}

#if DEBUG
#Preview {
  List {
    VersionEntriesSection(category: .feature, entries: Entry.mockFeatures)
  }
}
#endif

