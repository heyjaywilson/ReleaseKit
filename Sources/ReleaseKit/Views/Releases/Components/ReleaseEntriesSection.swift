//
//  ReleaseEntriesSection.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/25/25.
//

import SwiftUI

public struct ReleaseEntriesSection: View {
  public var category: Category
  public var entries: [Entry]
  
  var hasIcons: Bool {
    entries.contains(where: { $0.icon != nil })
  }
  
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
          } else if hasIcons {
            Image(systemName: "circle")
              .opacity(0)
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
    ReleaseEntriesSection(category: .bugFix, entries: Entry.mockBugFixes)
  }
}
#endif

