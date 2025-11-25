//
//  VersionDetailView.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/24/25.
//

import SwiftUI

struct VersionDetailView: View {
  let version: Version
  var body: some View {
    List {
      HStack(spacing: 16) {
        if let icon = version.icon {
          ZStack {
            Circle()
              .fill(Color.blue.tertiary)
            Image(systemName: icon)
              .font(Font.largeTitle)
          }
          .frame(width: 80, height: 80)
        }
        VStack(alignment: .leading) {
          Text(version.title)
            .font(.largeTitle)
            .bold()
          HStack(spacing: 16) {
            Text("Version \(version.version)")
            Text(
              version.releaseDate.formatted(date: .abbreviated, time: .omitted)
            )
            Spacer()
          }
          .font(.footnote)
          .foregroundStyle(.secondary)
        }
      }
      .listRowBackground(Color.clear)
      ForEach(version.featured) { featuredEntry in
        Section {
          HStack(alignment: .center, spacing: 16) {
            if let icon = featuredEntry.icon {
              Image(systemName: icon)
            }
            Text(featuredEntry.text)
          }
          .font(.headline)
          .foregroundStyle(.white)
          .listRowBackground(featuredEntry.category.featuredBackgroundColor)
        }
        .listSectionSpacing(16)
      }
      if version.features.isEmpty == false {
        Section {
          ForEach(version.features) { feature in
            Text(feature.text)
          }
        } header: {
          Text("Features")
        }
      }
      if version.improvements.isEmpty == false {
        Section {
          ForEach(version.improvements) { improvement in
            Text(improvement.text)
          }
        } header: {
          Text("Improvements")
        }
      }
      if version.fixes.isEmpty == false {
        Section {
          ForEach(version.fixes) { fix in
            Text(fix.text)
          }
        } header: {
          Text("Fixes")
        }
      }
    }
  }
}

#if DEBUG
#Preview {
  VersionDetailView(version: .mock)
}
#endif
