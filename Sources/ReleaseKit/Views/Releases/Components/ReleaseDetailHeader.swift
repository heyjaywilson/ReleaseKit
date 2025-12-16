//
//  ReleaseDetailHeader.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/25/25.
//

import SwiftUI

public struct ReleaseDetailHeader: View {
  var icon: String?
  var title: String
  var versionNumber: String
  var releaseDate: Date

  public init(
    icon: String? = nil,
    title: String,
    versionNumber: String,
    releaseDate: Date
  ) {
    self.icon = icon
    self.title = title
    self.versionNumber = versionNumber
    self.releaseDate = releaseDate
  }

  public var body: some View {
    HStack(spacing: 16) {
      if let icon = icon {
        ZStack {
          Circle()
            .fill(Color.blue.tertiary)
          Image(systemName: icon)
            .font(Font.largeTitle)
        }
        .frame(width: 80, height: 80)
      }
      VStack(alignment: .leading) {
        Text(title)
          .font(.largeTitle)
          .bold()
        HStack(spacing: 16) {
          Text(localizedString("Version.Prefix", versionNumber))
          Text(releaseDate.formatted(date: .abbreviated, time: .omitted))
          Spacer()
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical)
  }
}

@available(iOS 26)
#Preview("iOS 26") {
  NavigationView {
    List {
      Text("Hello")
    }
    .toolbar {
      ToolbarItem(placement: .navigation) {
        Button("Back", systemImage: "chevron.left") {
          print("Back")
        }
      }
      ToolbarItem(placement: .largeTitle) {
        ReleaseDetailHeader(
          icon: "megaphone",
          title: "It's alive",
          versionNumber: "1.0.0",
          releaseDate: .now
        )
      }
    }
    .toolbarTitleDisplayMode(.large)
  }
}
