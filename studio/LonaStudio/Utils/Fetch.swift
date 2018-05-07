//
//  Fetch.swift
//  LonaStudio
//
//  Created by devin_abbott on 4/17/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

typealias FetchRequestId = Int

class Fetch {
    public static var shared = DefaultFetch()
}

class DefaultFetch {

    // MARK: - Private

    private var nextRequestId = 1

    private var inflightRequests: [FetchRequestId: URLSessionDataTask] = [:]

    private func getNextRequestId() -> FetchRequestId {
        let requestId = nextRequestId
        nextRequestId += 1
        return requestId
    }

    // MARK: - Public

    @discardableResult
    public func data(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> FetchRequestId {
        let requestId = getNextRequestId()

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            self.inflightRequests.removeValue(forKey: requestId)
            completion(data, response, error)
        }

        inflightRequests[requestId] = task

        task.resume()

        return 0
    }

    @discardableResult
    public func image(_ url: URL, completion: @escaping (NSImage?, URLResponse?, Error?) -> Void) -> FetchRequestId {
        let requestId = data(url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, response, error)
                return
            }
            completion(NSImage(data: data), response, error)
        }

        return requestId
    }

    public func cancel(request requestId: FetchRequestId) {
        if let request = inflightRequests[requestId] {
            request.cancel()
        }
    }
}
