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
  static let shared = Account()

  private(set) lazy var token: String? = getStoredToken()

  private func getStoredToken() -> String? {
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
    return password
  }

  func refreshToken() {
    token = getStoredToken()
  }

  func logout() {
    SecItemDelete(deleteQuery as CFDictionary)
    token = nil
    cachedMe = nil
  }

  func signin(token: String) {
    setTokenQuery[kSecValueData as String] = token.data(using: String.Encoding.utf8)!
    _ = SecItemAdd(setTokenQuery as CFDictionary, nil)
    self.token = token
    _ = me(forceRefresh: true)
  }

  var signedIn: Bool {
    return token != nil
  }

  var cachedMe: GetMeQuery.Data.GetMe?
  private var pendingMePromise: Promise<GetMeQuery.Data.GetMe, NSError>?

  func me(forceRefresh: Bool = false) -> Promise<GetMeQuery.Data.GetMe, NSError> {
    if let cachedMe = cachedMe, (!forceRefresh && pendingMePromise == nil) {
      return .success(cachedMe)
    }

    if let pendingMePromise = pendingMePromise {
      return pendingMePromise
    }

    let promise: Promise<GetMeQuery.Data.GetMe, NSError> = .result({ complete in
      Network.shared.lona.fetch(query: GetMeQuery(), cachePolicy: forceRefresh ? .fetchIgnoringCacheData : .returnCacheDataElseFetch) { [weak self] result in
        guard let self = self else { return }

        switch result {
        case .success(let graphQLResult):
          if let errors = graphQLResult.errors {
            complete(.failure(NSError(errors.description)))
            return
          }

          guard let data = graphQLResult.data?.getMe else {
            complete(.failure(NSError("Missing result")))
            return
          }

          self.cachedMe = data
          self.pendingMePromise = nil

          complete(.success(data))
        case .failure(let error):
          complete(.failure(NSError(error.localizedDescription)))
        }
      }
    })

    pendingMePromise = promise
    return promise
  }
}
