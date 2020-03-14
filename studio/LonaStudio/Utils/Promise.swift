//
//  Promise.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/13/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation

public class Promise<Success, Failure: Swift.Error> {

    public typealias PromiseResult = Result<Success, Failure>

    // MARK: Private

    private enum State {
        case pending
        case completed(PromiseResult)
    }

    private var state: State = .pending

    private var resultEmitter: Emitter<PromiseResult> = .init()

    private init() {}

    private func addResultListener(_ listener: @escaping Emitter<PromiseResult>.Listener) {
        switch state {
        case .pending:
            resultEmitter.addListener(listener)
        case .completed(let result):
            listener(result)
        }
    }

    private func complete(_ result: PromiseResult) {
        switch state {
        case .pending:
            state = .completed(result)
            resultEmitter.emit(result)
            resultEmitter.removeAllListeners()
        case .completed:
            return
        }
    }

    private func resolve(_ value: Success) {
        complete(.success(value))
    }

    private func reject(_ error: Failure) {
        complete(.failure(error))
    }

    // MARK: Public

    public static func result<S, F>(_ result: Result<S, F>) -> Promise<S, F> {
        let promise = Promise<S, F>()
        promise.complete(result)
        return promise
    }

    public static func result<S, F>(_ resultCreator: (@escaping (Result<S, F>) -> Void) -> Void) -> Promise<S, F> {
        let promise = Promise<S, F>()
        resultCreator({ result in promise.complete(result) })
        return promise
    }

    public static func success<F>(_ value: Success) -> Promise<Success, F> {
        return .result(.success(value))
    }

    public static func failure<S>(_ error: Failure) -> Promise<S, Failure> {
        return .result(.failure(error))
    }

    @discardableResult public func onResult<S, F>(
        _ completionHandler: @escaping (PromiseResult) -> Promise<S, F>
    ) -> Promise<S, F> {
        let wrapper: Promise<S, F> = .init()

        addResultListener { result in
            completionHandler(result).addResultListener(wrapper.complete)
        }

        return wrapper
    }

    public func finalResult(
        _ completionHandler: @escaping (PromiseResult) -> Void
    ) {
        addResultListener { result in
            completionHandler(result)
        }
    }

    @discardableResult public func onSuccess<S>(
        _ successHandler: @escaping (Success) -> Promise<S, Failure>
    ) -> Promise<S, Failure> {
        return onResult { result in
            switch result {
            case .success(let value):
                return successHandler(value)
            case .failure(let error):
                return Promise<S, Failure>.failure(error)
            }
        }
    }

    public func finalSuccess(
        _ successHandler: @escaping (Success) -> Void
    ) {
        addResultListener { result in
            switch result {
            case .success(let value):
                successHandler(value)
            case .failure:
                break
            }
        }
    }

    @discardableResult public func onFailure<F>(
        _ failureHandler: @escaping (Failure) -> Promise<Success, F>
    ) -> Promise<Success, F> {
        return onResult { result in
            switch result {
            case .success(let value):
                return Promise<Success, F>.success(value)
            case .failure(let error):
                return failureHandler(error)
            }
        }
    }

    public func finalFailure(_ failureHandler: @escaping (Failure) -> Void) {
        addResultListener { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                failureHandler(error)
            }
        }
    }
}

extension Promise where Success == Void {
    public static func success<F>() -> Promise<Success, F> {
        let promise = Promise<Success, F>()
        promise.resolve(())
        return promise
    }
}

// MARK: Parallel

extension Promise {
    public static func parallel<S1, S2, F>(_ p1: Promise<S1, F>, _ p2: Promise<S2, F>) -> Promise<(S1, S2), F> {
        return .result { complete in
            var value1: S1?
            var value2: S2?

            func finalize() {
                if let value1 = value1, let value2 = value2 {
                    complete(.success((value1, value2)))
                }
            }

            p1.finalResult({ result in
                switch result {
                case .failure(let error):
                    complete(.failure(error))
                case .success(let value):
                    value1 = value
                    finalize()
                }
            })

            p2.finalResult({ result in
                switch result {
                case .failure(let error):
                    complete(.failure(error))
                case .success(let value):
                    value2 = value
                    finalize()
                }
            })
        }
    }

    public static func parallel<S1, S2, S3, F>(_ p1: Promise<S1, F>, _ p2: Promise<S2, F>, _ p3: Promise<S3, F>) -> Promise<(S1, S2, S3), F> {
        return .result { complete in
            var value1: S1?
            var value2: S2?
            var value3: S3?

            func finalize() {
                if let value1 = value1, let value2 = value2, let value3 = value3 {
                    complete(.success((value1, value2, value3)))
                }
            }

            p1.finalResult({ result in
                switch result {
                case .failure(let error):
                    complete(.failure(error))
                case .success(let value):
                    value1 = value
                    finalize()
                }
            })

            p2.finalResult({ result in
                switch result {
                case .failure(let error):
                    complete(.failure(error))
                case .success(let value):
                    value2 = value
                    finalize()
                }
            })

            p3.finalResult({ result in
                switch result {
                case .failure(let error):
                    complete(.failure(error))
                case .success(let value):
                    value3 = value
                    finalize()
                }
            })
        }
    }
}
