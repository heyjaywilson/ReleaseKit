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
      VersionDetailHeader(
        icon: version.icon,
        title: version.title,
        versionNumber: version.version,
        releaseDate: version.releaseDate
      )
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
#endif
