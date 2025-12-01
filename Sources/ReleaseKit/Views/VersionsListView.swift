//
//  VersionsListView.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/29/25.
//

import SwiftUI

struct VersionsListView: View {
  let versions: [Version]
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(versions) { version in
          NavigationLink {
            VersionDetail(version)
          } label: {
            HStack(spacing: 16) {
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
              VStack(alignment: .leading) {
                Text(version.title)
                  .font(.headline)
                HStack {
                  Text("v\(version.id)")
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
      .navigationTitle(Text("Releases"))
    }
  }
}

#if DEBUG
#Preview {
  VersionsListView(versions: Version.mockVersions)
}
#endif
