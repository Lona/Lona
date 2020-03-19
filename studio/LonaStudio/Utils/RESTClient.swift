//
//  RESTClient.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/16/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation

class RESTClient {
    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    var baseURL: URL

    var configureRequest: ((URLRequest) -> Result<URLRequest, NSError>)?

    private func makeURL(path: String) -> URL {
        let pathComponents = path.split(separator: "/").filter({ !$0.isEmpty })
        let url = pathComponents.reduce(baseURL, { result, component in result.appendingPathComponent(String(component)) })
        return url
    }

    private func send(request: URLRequest) -> Promise<Data, NSError> {
        return request.send().onSuccess({ response, data in
            let response = response as! HTTPURLResponse
            if response.statusCode >= 200 && response.statusCode < 300 {
                return .success(data)
            } else {
                return .failure(NSError("Request failed with status code \(response.statusCode). \(data.utf8String() ?? "")"))
            }
        })
    }

    func post(path: String, body: Data) -> Promise<Data, NSError> {
        var request = URLRequest(url: makeURL(path: path))
        request.httpMethod = "POST"
        request.httpBody = body

        if let configureRequest = configureRequest {
            switch configureRequest(request) {
            case .success(let request):
                return send(request: request)
            case .failure(let error):
                return .failure(error)
            }
        } else {
            return send(request: request)
        }
    }
}

extension RESTClient {
    static var githubV3: RESTClient = {
        let client = RESTClient(baseURL: URL(string: "https://api.github.com")!)

        client.configureRequest = { request in
            var request = request

            let group = DispatchGroup()
            group.enter()

            Account.shared.me().finalResult({_ in
                group.leave()
            })

            // wait for the Lona account to be fetched
            group.wait()

            if let githubToken = Account.shared.cachedMe?.githubAccessToken {
                request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
                request.addValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")

                return .success(request)
            } else {
                return .failure(NSError("User not logged in to GitHub through Lona."))
            }
        }

        return client
    }()
}

extension URLRequest {
    func send() -> Promise<(URLResponse, Data), NSError> {
        return .result({ complete in
            let task = URLSession.shared.dataTask(with: self, completionHandler: { data, response, error in
                if let error = error {
                    complete(.failure(error as NSError))
                    return
                }

                complete(.success((response!, data ?? Data())))
            })

            task.resume()
        })
    }
}
