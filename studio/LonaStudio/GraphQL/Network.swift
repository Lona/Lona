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

  private(set) lazy var lona: ApolloClient = {
    let httpNetworkTransport = HTTPNetworkTransport(
      url: URL(string:"\(API_BASE_URL)/graphql")!,
      delegate: self
    )

    httpNetworkTransport.clientName = "Lona API Transport"

    return ApolloClient(networkTransport: httpNetworkTransport)
  }()

  private(set) lazy var github: ApolloClient = {
    let httpNetworkTransport = HTTPNetworkTransport(
      url: URL(string:"https://api.github.com/graphql")!,
      delegate: self
    )

    httpNetworkTransport.clientName = "GitHub API Transport"

    return ApolloClient(networkTransport: httpNetworkTransport)
  }()
}

extension Network: HTTPNetworkTransportPreflightDelegate {
  func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
    return true
  }

  func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
    if networkTransport.clientName == "Lona API Transport" {
      if let token = Account.shared.token {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }
    }

    if networkTransport.clientName == "GitHub API Transport" {
      // We need this to get the check suites
      request.addValue("application/vnd.github.antiope-preview+json", forHTTPHeaderField: "Accept")

      // this will be up to date when using *AfterGitHubAuth
      // might not be otherwise
      if let githubToken = Account.shared.cachedMe?.githubAccessToken {
        request.addValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")
      }
    }
  }
}

/// Support waiting for the GitHub token to be fetched
extension ApolloClient {
  @discardableResult
  public func fetchAfterGitHubAuth<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy = .returnCacheDataElseFetch,
    context: UnsafeMutableRawPointer? = nil,x
    queue: DispatchQueue = DispatchQueue.main,
    resultHandler: GraphQLResultHandler<Query.Data>? = nil
  ) -> Cancellable {
    Account.shared.me().finalResult({_ in
      self.fetch(query: query, cachePolicy: cachePolicy, context: context, queue: queue, resultHandler: resultHandler)
    })

    // TODO: return the result of self.fetch when available
    return EmptyCancellable()
  }

  @discardableResult
  public func performAfterGitHubAuth<Mutation: GraphQLMutation>(
    mutation: Mutation,
    cachePolicy: CachePolicy = .returnCacheDataElseFetch,
    context: UnsafeMutableRawPointer? = nil,x
    queue: DispatchQueue = DispatchQueue.main,
    resultHandler: GraphQLResultHandler<Mutation.Data>? = nil
  ) -> Cancellable {
    Account.shared.me().finalResult({_ in
      self.perform(mutation: mutation, context: context, queue: queue, resultHandler: resultHandler)
    })

    // TODO: return the result of self.perform when available
    return EmptyCancellable()
  }
}
