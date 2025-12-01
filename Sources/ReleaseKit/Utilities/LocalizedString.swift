//
//  String.swift
//  ReleaseKit
//
//  Created by Jay Wilson on 11/30/25.
//

import Foundation

func localizedString(_ key: String, _ args: CVarArg...) -> String {
  let mainString = NSLocalizedString(key, bundle: .main, value: "", comment: "")
  let format: String
  if !mainString.isEmpty && mainString != key {
    format = mainString
  } else {
    format = NSLocalizedString(key, bundle: .module, value: "", comment: "")
  }
  return String(format: format, arguments: args)
}


func localizedString(_ key: String) -> String {
  let mainString = NSLocalizedString(key, bundle: .main, value: "", comment: "")
  let format: String
  if !mainString.isEmpty && mainString != key {
    format = mainString
  } else {
    format = NSLocalizedString(key, bundle: .module, value: "", comment: "")
  }
  return String(format: format)
}
