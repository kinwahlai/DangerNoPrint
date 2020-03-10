import XCTest
@testable import DangerNoPrint
@testable import Danger
@testable import DangerFixtures

extension XCTestCase {
    var activePrintStatement: String {
        """
        func setAmenity(_ amenity: String) {
            print(amenity123)
            amenityLabel.text = amenity
        }
        """.replacingOccurrences(of: "\n", with: "\\n")
    }
    var commentedPrintStatement: String {
        """
        func setAmenity(_ amenity: String) {
            print(amenity321)
            // print(amenity321)
            amenityLabel.text = amenity
        }
        """.replacingOccurrences(of: "\n", with: "\\n")
    }
    
    var commentedPrintStatementWithEmptyLine: String {
        """
        func setAmenity(_ amenity: String) {
            print(amenity1234)
            // print(amenity1234)
        
        
            amenityLabel.text = amenity
        }
        """.replacingOccurrences(of: "\n", with: "\\n")
    }
}

final class DangerNoPrintTests: XCTestCase {
    override func tearDown() {
        resetDangerResults()
    }
    func testNoPrintFound() {
        let notFoundPredicate: Predicate<String> = Predicate<String>(matcher: { line in return line.contains("nothing") })
        let danger = githubWithFilesDSL(created: [], modified: ["file.swift"], fileMap: ["file.swift": activePrintStatement])
        DangerNoPrint(dsl: danger).check(files: ["file.swift"], predicate: notFoundPredicate)
        XCTAssertEqual(danger.warnings.count, 0)
    }

    func testEmptyLineValueInput() {
        let dsl = DangerNoPrint(dsl: gitlabFixtureDSL)
        XCTAssertTrue(dsl.checkViolations(lineValues: []).isEmpty)
    }
    
    func testPrintViolationsFound() {
        let dsl = DangerNoPrint(dsl: gitlabFixtureDSL)
        let violations = dsl.checkViolations(lineValues: [LineValue("file.swift", 1,"    print(amenity)"),
        LineValue("file.swift", 2,"    // print(amenity)")])
        XCTAssertEqual(violations.count, 2)
        XCTAssertEqual(violations[0].message, DangerNoPrint.violationMessage)
        XCTAssertEqual(violations[0].file, "file.swift")
        XCTAssertEqual(violations[0].line, 1)
        XCTAssertEqual(violations[1].message, DangerNoPrint.commentedPrintMessage)
        XCTAssertEqual(violations[1].file, "file.swift")
        XCTAssertEqual(violations[1].line, 2)
    }
    
    func testHandleInLinePrintViolations() {
        let danger = gitlabFixtureDSL
        DangerNoPrint(dsl: danger).handle(inLine: true, violations: [PluginViolation(message: DangerNoPrint.violationMessage, file: "file.swift", line: 1), PluginViolation(message: DangerNoPrint.violationMessage, file: "file2.swift", line: 3)])
        XCTAssertEqual(danger.warnings.count, 2)
    }
    
    func testHandleMarkdownPrintViolations() {
        let danger = gitlabFixtureDSL
        DangerNoPrint(dsl: danger).handle(inLine: false, violations: [PluginViolation(message: DangerNoPrint.violationMessage, file: "file.swift", line: 1), PluginViolation(message: DangerNoPrint.commentedPrintMessage, file: "file2.swift", line: 3)])
        XCTAssertEqual(danger.warnings.count, 0)
        XCTAssertEqual(danger.markdowns.count, 1)
        print(danger.markdowns[0].message)
    }
    
    func testPrintStatementFound() {
        let danger = githubWithFilesDSL(created: ["file.swift"], modified: ["file.swift"], fileMap: ["file.swift": activePrintStatement, "file2.swift": commentedPrintStatement])
        DangerNoPrint(dsl: danger).check(files: ["file.swift", "file2.swift"], inLine: true, predicate: Predicate.CheckPrint)
        XCTAssertEqual(danger.warnings.count, 3)
    }
    
    func testHandleEmptyNewLine() {
        let danger = githubWithFilesDSL(created: ["file.swift"], modified: ["file.swift"], fileMap: ["file.swift": activePrintStatement, "file2.swift": commentedPrintStatementWithEmptyLine])
        DangerNoPrint(dsl: danger).check(files: ["file.swift", "file2.swift"], inLine: true, predicate: Predicate.CheckPrint)
        XCTAssertEqual(danger.warnings.count, 3)
    }

    static var allTests = [
        ("testNoPrintFound", testNoPrintFound),
        ("testEmptyLineValueInput", testEmptyLineValueInput),
        ("testPrintViolationsFound", testPrintViolationsFound),
        ("testHandleInLinePrintViolations", testHandleInLinePrintViolations),
        ("testHandleMarkdownPrintViolations", testHandleMarkdownPrintViolations),
        ("testPrintStatementFound", testPrintStatementFound),
    ]
}
