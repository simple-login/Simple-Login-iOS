//
//  RegexHelpers.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 12/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class RegexHelpers {
    static func firstMatch(for pattern: String, inString string: String, caseInsensitive: Bool = true) -> String? {
        let options = caseInsensitive ? NSRegularExpression.Options.caseInsensitive : []
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return nil
        }
        
        let range = NSRange(string.startIndex..., in: string)
        
        guard let firstMatch = regex.firstMatch(in: string, options: [], range: range) else {
            return nil
        }
        
        let firstMatchRange = Range(firstMatch.range, in: string)!
        
        return String(string[firstMatchRange])
    }
    
    static func listMatches(for pattern: String, inString string: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, options: [], range: range)
        
        return matches.map {
            let range = Range($0.range, in: string)!
            return String(string[range])
        }
    }
    
    static func listGroups(for pattern: String, inString string: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, options: [], range: range)
        
        var groupMatches: [String] = []
        for match in matches {
            let numberOfRangesInMatch = match.numberOfRanges
            
            for rangeIndex in 1..<numberOfRangesInMatch {
                let range = match.range(at: rangeIndex);
                if range.location != NSNotFound {
                    if let rangeInString = Range(range, in: string) {
                        groupMatches.append(String(string[rangeInString]))
                    }
                }
            }
        }
        
        return groupMatches
    }
    
    static func matchRanges(of pattern: String, inString string: String) -> [NSRange] {
        var listMatches: [NSRange] = []
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        
        if let matches = regex?.matches(in: string, options: [], range: NSRange(string.startIndex..., in: string)) {
            matches.forEach { (eachMatch) in
                listMatches.append(eachMatch.range)
            }
        }
        
        return listMatches
    }
    
    static func containsMatch(of pattern: String, inString string: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let range = NSRange(string.startIndex..., in: string)
        return regex.firstMatch(in: string, options: [], range: range) != nil
    }
    
    static func replaceMatches(for pattern: String, inString string: String, withString replacementString: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return string
        }
        
        let range = NSRange(string.startIndex..., in: string)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replacementString)
    }
}
