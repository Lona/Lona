//
//  AnimationUtils.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/23/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit
import Lottie

class AnimationUtils {
    static func updateAssets(in dictionary: NSMutableDictionary, withFile url: URL, assetMap: [String: URL]) {
        if let assets = dictionary["assets"] as? NSMutableArray {
            for asset in assets {
                guard let assetJSON = asset as? NSMutableDictionary else { continue }

                if let imagePath = assetJSON["p"] as? String, let imageDirectory = assetJSON["u"] as? String {
                    let imageURL = assetMap[imagePath] ?? url
                        .deletingLastPathComponent() // Delete lottie-file-name.json
                        .appendingPathComponent(imageDirectory)
                        .appendingPathComponent(imagePath)

                    assetJSON["url"] = imageURL.absoluteString

                    if let components = URLComponents(url: imageURL, resolvingAgainstBaseURL: false) {
                        let cacheKey = (components.scheme == "http" || components.scheme == "https")
                            ? URL(fileURLWithPath: components.path).deletingPathExtension().absoluteString
                            : imageURL.deletingPathExtension().absoluteString

                        assetJSON["p"] = cacheKey

                        NSImage(contentsOf: imageURL)?.setName(cacheKey)
                    }
                }
            }
        }
    }

    static func assetNames(from animation: NSMutableDictionary) -> [String] {
        var names: [String] = []

        guard let assets = animation["assets"] as? NSMutableArray else { return names }

        for asset in assets {
            guard let assetJSON = asset as? NSMutableDictionary else { continue }

            if let imagePath = assetJSON["p"] as? String {
                names.append(imagePath)
            }
        }

        return names
    }

    static func assetMapValue(from animation: NSMutableDictionary) -> CSValue {
        let assetNames = AnimationUtils.assetNames(from: animation)

        let valueMap = assetNames.key {(name) -> (key: String, value: CSData) in
            return (key: name, value: CSData.Null)
        }

        let typeMap: CSType.Schema = assetNames.key {(name) -> (key: String, value: (CSType, CSAccess)) in
            return (key: name, value: (CSURLType, .write))
        }

        return CSValue(type: CSType.dictionary(typeMap), data: CSData.Object(valueMap))
    }

    static func decode(contentsOf url: URL) -> NSMutableDictionary? {
        guard let animationData = try? Data(contentsOf: url) else { return nil }
        guard let animationJSON = (try? JSONSerialization.jsonObject(with: animationData, options: .mutableContainers)) as? NSMutableDictionary else { return nil }
        return animationJSON
    }

    static func findAnimationView(in view: NSView) -> LOTAnimationView? {
        if view is LOTAnimationView { return view as? LOTAnimationView }

        for child in view.subviews {
            if let found = findAnimationView(in: child) {
                return found
            }
        }

        return nil
    }

    // TODO: Assumptions here:
    // - animation fills the canvas entirely
    // - animation is not scaled (we will create our overlay at the animation's natural size)
    // We should probably scale/adjust all transforms of the lottie hierarchy
    static func add(overlay image: Data, to animation: inout NSMutableDictionary) -> Bool {

        // Use the width and height of the animation for the overlay
        // This assumes that the animation fills the component canvas entirely as a background
        guard let width = animation["w"] as? NSNumber else { return false }
        guard let height = animation["h"] as? NSNumber else { return false }
        guard let assets = animation["assets"] as? NSMutableArray else { return false }
        guard let layers = animation["layers"] as? NSMutableArray else { return false }
        let overlay = image.base64EncodedString()

        let asset: NSMutableDictionary = [
            "id": "overlay",
            "w": width,
            "h": height,
            "u": "images/",
            "p": "",
            "url": "data:image/png;base64," + overlay
            ]

        assets.add(asset)

        assets.forEach({ asset in
            if let asset = asset as? NSMutableDictionary, let url = asset["url"] as? String {
                asset["p"] = url
                asset.removeObject(forKey: "url")
            }
        })

        // https://github.com/bodymovin/bodymovin/blob/4728ccb6821d1f228457c5eb9077eccd63ecd980/docs/json/layers/image.json
        let layer: NSMutableDictionary = [
            "ddd": 0, // Is 3d layer?
            "ind": 1000, // Layer index (not sure how/if used)
            "ty": 2, // Layer type (2 = image)
            "nm": "overlay", // Layer name (not used?)
            "cl": "jpg", // Layer class (applies a css class, if applicable)
            "refId": "overlay", // Layer id used to refer to this layer uniquely
            "sr": 1, // Layer time stretching
            "ks": [
                "o": [ "a": 0, "k": 100, "ix": 2011 ], // Opacity, k is between 0 and 100
                "r": [ "a": 0, "k": 0, "ix": 2010 ], // Rotation
                "p": [ "a": 0, "k": [ 0, 0, 0 ], "ix": 2002 ], // Position
                "a": [ "a": 0, "k": [ 0, 0, 0 ], "ix": 2001 ], // Anchor point
                "s": [ "a": 0, "k": [ 100, 100, 100 ], "ix": 2006 ] // Scale
            ],
            "ao": 0, // Auto orient (?)
            "ip": 0, // In point (starting frame)
            "op": 10000, // Out point (ending frame
            "st": 0, // Start time of layer (how does this play with ip?)
            "bm": 0 // Blending mode
        ]

        layers.insert(layer, at: 0)

        return true
    }

}

// TODO: Why does a subclass of LOTAnimationView with stored properties crash?
// This presumably leaks memory and is hacky anyway
private var key: UInt8 = 0
private let policy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC

extension LOTAnimationView {
    var data: NSMutableDictionary? {
        get {
            return objc_getAssociatedObject(self, &key) as? NSMutableDictionary
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, policy)
        }
    }
}
