//
//  DangerNoPrint+Extension.swift
//  DangerNoPrint
//
//  Created by Darren Lai on 3/7/20.
//

import Danger
import Foundation

public struct Predicate<Target> {
    var matches: (Target) -> Bool

    init(matcher: @escaping (Target) -> Bool) {
        matches = matcher
    }
}

extension Predicate where Target == String {
    public static var CheckPrint: Predicate<String> {
        Predicate<String> { (line) -> Bool in line.contains("print(") }
    }
}

struct LineValue: Equatable {
    let file: File
    let line: Int
    let value: String
    init(_ file: File, _ line: Int, _ value: String) {
        self.file = file
        self.line = line
        self.value = value
    }
}

func ==(lhs: LineValue, rhs: LineValue) -> Bool {
    return (lhs.file == rhs.file) && (lhs.line == rhs.line) && (lhs.value == rhs.value)
}


extension DangerUtils {
    func lines(for predicate: Predicate<String>, inFile file: File) -> [LineValue] {
        let lines = readFile(file).components(separatedBy: .newlines)
        return lines.enumerated()
            .filter { predicate.matches($0.element) }
            .map { LineValue(file, $0.offset, $0.element) }
    }
}

extension String {
    var range: NSRange {
        return NSRange(location: 0, length: self.utf8.count)
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        return firstMatch(in: string, options: [], range: string.range) != nil
    }
}
