import Danger
import Foundation

// TODO:
// find print in block comment

public final class DangerNoPrint {
    private let danger: DangerDSL
    public static let violationMessage = "Please replace print with proper log statement"
    public static let commentedPrintMessage = "Please remove the commented print statement"
    
    public init(dsl: DangerDSL = Danger()) {
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

    fileprivate func isOneLineComment(line: String) -> Bool {
        guard !line.isEmpty else { return true }
        let pattern = "^\\s*\\/\\/"
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
