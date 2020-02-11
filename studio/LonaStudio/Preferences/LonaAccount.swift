//
//  LonaAccount.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 11/02/2020.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation
import Security

private let getTokenQuery: [String: Any] = [
  kSecClass as String: kSecClassGenericPassword,
  kSecAttrAccount as String: "LonaStudio",
  kSecMatchLimit as String: kSecMatchLimitOne,
  kSecReturnAttributes as String: true,
  kSecReturnData as String: true
]
private var setTokenQuery: [String: Any] = [
  kSecClass as String: kSecClassGenericPassword,
  kSecAttrAccount as String: "LonaStudio"
]
private let deleteQuery: [String: Any] = [
  kSecClass as String: kSecClassGenericPassword,
  kSecAttrAccount as String: "LonaStudio"
]

class Account {
  private static var _tokenCache: String?

  static var token: String? {
    get {
      if let cached = _tokenCache {
        return cached
      }

      var item: CFTypeRef?
      let status = SecItemCopyMatching(getTokenQuery as CFDictionary, &item)
      guard
        status == errSecSuccess,
        let existingItem = item as? [String : Any],
        let passwordData = existingItem[kSecValueData as String] as? Data,
        let password = String(data: passwordData, encoding: String.Encoding.utf8)
      else {
        return nil
      }
      _tokenCache = password
      return password
    }
    set (newValue) {
      _tokenCache = newValue
      if let newValue = newValue {
        setTokenQuery[kSecValueData as String] = newValue.data(using: String.Encoding.utf8)!
        _ = SecItemAdd(setTokenQuery as CFDictionary, nil)
      } else {
        SecItemDelete(deleteQuery as CFDictionary)
      }
    }
  }

  static func reload() {
    _tokenCache = nil
  }
}
