//
//  StringExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/14/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

extension String: Error {}

extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    func capturedGroups(withRegex pattern: String) -> [(value: String, range: NSRange)] {
        var results = [(String, NSRange)]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.characters.count))
        
        guard let match = matches.first else { return results }
        
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append((matchedString, capturedGroupIndex))
        }
        
        return results
    }
    /**
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     
     - Parameter length: A `String`.
     - Parameter trailing: A `String` that will be appended after the truncation.
     
     - Returns: A `String` object.
     */
    func truncate(length: Int, trailing: String = "…") -> String {
        if self.characters.count > length {
            return String(self.characters.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
    func pathRelativeTo(basePath: String) -> String? {
        guard let absolutePathComponents = URL(string: self)?.pathComponents else { return nil }
        guard let basePathComponents = URL(string: basePath)?.pathComponents else { return nil }
        
        if absolutePathComponents.count < basePathComponents.count {
            return self
        }
        
        var levelIndex = 0 //number of basePath components in absolute path
        
        for (index, baseComponent) in basePathComponents.enumerated() {
            if (baseComponent != absolutePathComponents[index]) {
                break
            }
            levelIndex += 1
        }
        
        if levelIndex == 0 {
            return self
        }
        
        var relativePath: String = ""
        
        if levelIndex < basePathComponents.count {
            //outside of base path
            var index = levelIndex
            while index < basePathComponents.count {
                relativePath += "../"
                index += 1
            }
        }
        
        var index = levelIndex
        while index < absolutePathComponents.count {
            relativePath += (relativePath.characters.count > 0 ? "/" : "./") + absolutePathComponents[index]
            index += 1
        }
        
        return relativePath
    }
}
