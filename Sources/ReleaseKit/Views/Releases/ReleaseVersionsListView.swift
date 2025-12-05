//
//  VersionsListView.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/29/25.
//

import SwiftUI

public struct ReleaseVersionsListView: View {
  let versions: [Release]
  
  var hasIcons: Bool {
    versions.contains(where: { $0.icon != nil })
  }
  
  public init(versions: [Release]) {
    self.versions = versions
  }
  
  public var body: some View {
    List {
      ForEach(versions) { version in
        NavigationLink {
          ReleaseDetail(version)
        } label: {
          HStack(spacing: 16) {
            if hasIcons {
              Group {
                if let icon = version.icon {
                  ZStack {
                    Circle()
                      .fill(Color.blue.tertiary)
                    Image(systemName: icon)
                      .font(Font.largeTitle)
                  }
                } else {
                  Circle()
                    .opacity(0)
                }
              }
              .frame(width: 64)
            }
            VStack(alignment: .leading) {
              Text(version.title)
                .font(.headline)
              HStack {
                Text(localizedString("Version.Prefix", version.version))
                Spacer()
                Text(
                  version.releaseDate.formatted(date: .abbreviated, time: .omitted)
                )
              }
              .font(.caption)
            }
          }
        }
        
      }
    }
    .navigationTitle(Text(localizedString("VersionListView.Title")))
  }
}

#if DEBUG
#Preview {
  NavigationStack {
    ReleaseVersionsListView(versions: Release.mockVersions)
  }
}
#endif
