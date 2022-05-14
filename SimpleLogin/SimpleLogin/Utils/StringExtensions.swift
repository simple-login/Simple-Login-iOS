//
//  StringExtensions.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
            .evaluate(with: self)
    }

    var isValidPrefix: Bool {
        guard 1...100 ~= self.count else { return false }
        return NSPredicate(format: "SELF MATCHES %@", "[0-9a-z-_.]+")
            .evaluate(with: self)
    }

    subscript (idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }

    // https://www.hackingwithswift.com/example-code/strings/how-to-detect-a-url-in-a-string-using-nsdatadetector
    func firstUrl() -> URL? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }

        let matches = detector.matches(in: self, range: .init(location: 0, length: self.utf16.count))
        for match in matches {
            guard let range = Range(match.range, in: self),
                  let url = URL(string: String(self[range]).lowercased()) else { continue }
            return url
        }
        return nil
    }
}
