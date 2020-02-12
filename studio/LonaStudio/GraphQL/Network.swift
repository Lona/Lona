//
//  Network.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 12/02/2020.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation
import Apollo

let API_BASE_URL = Bundle.main.infoDictionary?["API_BASE_URL"] as! String

class Network {
  static let shared = Network()

  private(set) lazy var apollo: ApolloClient = {
    let httpNetworkTransport = HTTPNetworkTransport(
      url: URL(string:"\(API_BASE_URL)/graphql")!,
      delegate: self
    )

    return ApolloClient(networkTransport: httpNetworkTransport)
  }()
}

extension Network: HTTPNetworkTransportPreflightDelegate {
  func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
    return true
  }

  func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
    if let token = Account.token {
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
  }
}
