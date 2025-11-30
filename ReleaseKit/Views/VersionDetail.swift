//
//  VersionDetailView.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

import SwiftUI

public struct VersionDetail<Content: View>: View {
  let version: Version
  let content: Content?
  
  public init(_ version: Version) where Content == EmptyView {
    self.version = version
    self.content = nil
  }
  
  public init(_ version: Version, @ViewBuilder content: () -> Content) {
    self.version = version
    self.content = content()
  }
  
  public var body: some View {
    List {
      FeaturedSection(entries: version.featured)
      ForEach(version.categories) { category in
        if let entries = version.entriesByCategory[category] {
          VersionEntriesSection(category: category, entries: entries)
        }
      }
      
      if let content {
        content
      }
    }
    .toolbar {
      ToolbarItem(placement: .largeTitle) {
        VersionDetailHeader(
          icon: version.icon,
          title: version.title,
          versionNumber: version.version,
          releaseDate: version.releaseDate
        )
      }
    }
    .toolbarTitleDisplayMode(.inlineLarge)
  }
}

#if DEBUG
#Preview("No Content") {
  VersionDetail(.mock)
}
#Preview("Content") {
  VersionDetail(.mock) {
    Section {
      Text("This is another seciton added")
      Text("to the bottom of the view")
    } header: {
      Text("Header")
    }
  }
}
#Preview("NavigationStack") {
  NavigationView {
    VersionDetail(.mock) {
      Section {
        Text("This is another seciton added")
        Text("to the bottom of the view")
      } header: {
        Text("Header")
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Back", systemImage: "chevron.left") {
          print("Nothing")
        }
      }
    }
  }
}
#endif
