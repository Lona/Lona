//
//  LonaJS.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/11/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import JavaScriptCore

enum LonaJS {
    private static let svgContext: JSContext = {
        guard
            let libraryPath = Bundle.main.path(forResource: "svg-model.umd.js", ofType: nil),
            let libraryScript = FileManager.default.contents(atPath: libraryPath)?.utf8String(),
            let context = JSContext()
            else { fatalError("Failed to initialize JSContext") }

        context.exceptionHandler = { _, exception in
            guard let exception = exception else {
                Swift.print("Unknown JS exception")
                return
            }
            Swift.print("JS exception", exception.toString() ?? "")
        }

        // The library assigns its export, `svgModel`, to `this`
        context.evaluateScript("global = this;")
        context.evaluateScript(libraryScript)
        context.evaluateScript("function convert(svgString) { return JSON.stringify(global.svgModel(svgString)) };")

        return context
    }()

    static func convertSvg(contents svgString: String) -> Data? {
        let script = "convert(`\(svgString)`)"
        return svgContext.evaluateScript(script)?.toString()?.data(using: .utf8)
    }
}
