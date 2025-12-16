//
//  VersionDetailView.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

import SwiftUI

public struct ReleaseDetail<Content: View>: View {
  let release: Release
  let content: Content?

  public init(_ release: Release) where Content == EmptyView {
    self.release = release
    self.content = nil
  }

  public init(_ version: Release, @ViewBuilder content: () -> Content) {
    self.release = version
    self.content = content()
  }

  public var body: some View {
    if #available(iOS 26, *) {
      listContent
        .toolbar {
          ToolbarItem(placement: .largeTitle) {
            ReleaseDetailHeader(
              icon: release.icon,
              title: release.title,
              versionNumber: release.version,
              releaseDate: release.releaseDate
            )
          }
        }
        .navigationTitle(Text(release.title))
        .toolbarTitleDisplayMode(.inlineLarge)
    }
    else {
      listContent
        .navigationTitle(Text(release.title))
        .navigationBarTitleDisplayMode(.large)
    }
  }

  @ViewBuilder
  private var listContent: some View {
    List {
      FeaturedSection(entries: release.featured)
      ForEach(release.categories) { category in
        if let entries = release.entriesByCategory[category] {
          ReleaseEntriesSection(category: category, entries: entries)
        }
      }

      if let content {
        content
      }
    }
    .overlay {
      if release.entries.isEmpty {
        ContentUnavailableView(
          "No Release Notes",
          systemImage: "list.bullet.clipboard",
          description: Text("No release notes found for \(release.version)")
        )
      }
    }
  }
}

#if DEBUG
  #Preview("No Content") {
    ReleaseDetail(.init(title: "Test", version: "1.0.0", releaseDate: .now, entries: []))
  }

  #Preview("Content") {
    ReleaseDetail(.mock) {
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
      ReleaseDetail(.mock) {
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

  #Preview("In List") {
    NavigationStack {
      ReleaseVersionsListView(versions: Release.mockVersions)
    }
  }
#endif
