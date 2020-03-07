import Danger
import Foundation

public struct PluginViolation {
    let message: String
    let file: String
    let line: Int
    
    public init(message: String, file: String, line: Int) {
        self.message = message
        self.file = file
        self.line = line
    }
    
    public func toMarkdown() -> String {
        let formattedFile = file.split(separator: "/").last! + ":\(line)"
        return "| \(formattedFile) | \(message) |"
    }
}
// TODO:
// find print in block comment

public final class DangerNoPrint {
    let danger: DangerDSL
    public static let violationMessage = "Please replace print with proper log statement"
    public static let commentedPrintMessage = "Please remove the commented print statement"
    
    init(dsl: DangerDSL = Danger()) {
        self.danger = dsl
    }
    
    public func check(files: [File], inLine: Bool = false, predicate: Predicate<String>) {
        let filesWithPrint = files.reduce([LineValue]()) { (acc, file) -> [LineValue] in
            var temp = acc
            temp.append(contentsOf: danger.utils.lines(for: predicate, inFile: file))
            return temp
        }
        handle(inLine: inLine, violations: checkViolations(lineValues: filesWithPrint))
    }

    func isOneLineComment(line: String) -> Bool {
        let pattern = #"^\s*\/\/"#
        return NSRegularExpression(pattern).matches(line)
    }
    
    func checkViolations(lineValues: [LineValue]) -> [PluginViolation] {
        return lineValues.map { (linevalue) -> PluginViolation in
            var message = DangerNoPrint.violationMessage
            if isOneLineComment(line: linevalue.value) {
                message = DangerNoPrint.commentedPrintMessage
            }
            return PluginViolation(message: message, file: linevalue.file, line: linevalue.line)
        }
    }
    
    func handle(inLine: Bool, violations: [PluginViolation]) {
        if inLine {
            violations.forEach { (violation) in
                danger.warn(message: violation.message, file: violation.file, line: violation.line)
            }
        } else {
            var markdownMessage = """
            ### Print statement found in following files

            | File | Message |
            | ---- | ------- |\n
            """
            markdownMessage += violations.map { $0.toMarkdown() }.joined(separator: "\n")
            danger.markdown(markdownMessage)
        }
    }
}
