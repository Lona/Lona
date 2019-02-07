// Copyright 2016 The xi-editor Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// most of it is taken from https://github.com/xi-editor/xi-mac/blob/master/Sources/XiEditor/RPCSending.swift

import Foundation

// An error returned from core
class RPCError {
    let code: Int
    let message: String
    let data: AnyObject?

    init(code: Int, message: String, data: AnyObject? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }

    init?(json: [String: AnyObject]) {
        guard let code = json["code"] as? Int,
            let message = json["message"] as? String else { return nil }
        self.code = code
        self.message = message
        self.data = json["data"]
    }

    static func ParseError(_ data: AnyObject? = nil) -> RPCError {
        return RPCError(code: -32700, message: "Parse error", data: data)
    }

    static func InvalidRequest(_ data: AnyObject? = nil) -> RPCError {
        return RPCError(code: -32600, message: "Invalid Request", data: data)
    }

    static func MethodNotFound(_ data: AnyObject? = nil) -> RPCError {
        return RPCError(code: -32601, message: "Method not found", data: data)
    }

    static func InvalidParams(_ data: AnyObject? = nil) -> RPCError {
        return RPCError(code: -32602, message: "Invalid params", data: data)
    }

    static func InternalError(_ data: AnyObject? = nil) -> RPCError {
        return RPCError(code: -32603, message: "Internal error", data: data)
    }

    func toJSON() -> [String: AnyObject] {
        var json = [
            "code": self.code as AnyObject,
            "message": self.message as AnyObject
        ]
        if let data = self.data {
            json["data"] = data
        }
        return json
    }
}

// The return value of a synchronous RPC
enum RpcResult {
    case error(RPCError)
    case ok(AnyObject)
}

// A completion handler for a synchronous RPC
typealias RpcCallback = (RpcResult) -> Void

class RPCService {
    // RPC state
    private var queue = DispatchQueue(label: "com.devinabbott.ComponentStudio.CoreConnection", attributes: [])
    private var rpcIndex = 0
    private var pending = Dictionary<Int, RpcCallback>()

    var sendData: ((_ data: Data) -> Void)?

    private func sendJson(_ json: Any) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            sendData?(data)
        } catch _ {
            print("error serializing to json")
        }
    }

    private func sendResult(id: Int, result: Any) {
        let json = ["id": id, "result": result]
        sendJson(json)
    }

    private func sendError(id: Int, error: RPCError) {
        let json = ["id": id, "error": error.toJSON()] as [String: Any]
        sendJson(json)
    }

    func handleData(_ data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            handleRpc(json)
        } catch {
            print("json error \(error.localizedDescription)")
            print(String(data: data, encoding: String.Encoding.utf8)!)
        }
    }

    /// handle a JSON RPC call. Determines whether it is a request, response or notification
    /// and executes/responds accordingly
    private func handleRpc(_ json: Any) {
        guard let obj = json as? [String: AnyObject] else { fatalError("malformed json \(json)") }
        if let index = obj["id"] as? Int {
            if obj["result"] != nil || obj["error"] != nil {
                var callback: RpcCallback?
                queue.sync {
                    callback = self.pending.removeValue(forKey: index)
                }
                if let result = obj["result"] {
                    callback?(.ok(result))
                } else if let errJson = obj["error"] as? [String: AnyObject],
                    let err = RPCError(json: errJson) {
                    callback?(.error(err))
                } else {
                    print("failed to parse response \(obj)")
                }
            } else {
                self.handleRequest(json: obj)
            }
        } else {
            self.handleNotification(json: obj)
        }
    }

    private func handleRequest(json: [String: AnyObject]) {
        guard let id = json["id"] as? Int else {
                assertionFailure("unknown json from core: \(json)")
                return
        }
        guard let jsonMethod = json["method"] as? String else {
                sendError(id: id, error: RPCError.MethodNotFound())
                return
        }

        PluginAPI.handleRequest(jsonMethod, json["params"], onSuccess: { result in
            sendResult(id: id, result: result)
        }, onFailure: { error in
            sendError(id: id, error: error)
        })
    }

    private func handleNotification(json: [String: AnyObject]) {
        guard let jsonMethod = json["method"] as? String else {
            print("unknown method")
            return
        }

        PluginAPI.handleNotification(jsonMethod, json["params"])
    }

    /// send an RPC request, returning immediately. The callback will be called when the
    /// response comes in, likely from a different thread
    func sendRpcAsync(_ method: String, params: Any, callback: RpcCallback? = nil) {
        var req = ["method": method, "params": params] as [String: Any]
        if let callback = callback {
            queue.sync {
                let index = self.rpcIndex
                req["id"] = index
                self.rpcIndex += 1
                self.pending[index] = callback
            }
        }
        sendJson(req as Any)
    }

    /// send RPC synchronously, blocking until return. Note: there is no ordering guarantee on
    /// when this function may return. In particular, an async notification sent by the core after
    /// a response to a synchronous RPC may be delivered before it.
    func sendRpc(_ method: String, params: Any) -> RpcResult {
        let semaphore = DispatchSemaphore(value: 0)
        var result: RpcResult? = nil

        sendRpcAsync(method, params: params) { (r) in
            result = r
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return result!
    }
}
