//
//  DangerNoPrintExtensionTests.swift
//  DangerNoPrintTests
//
//  Created by Darren Lai on 3/7/20.
//

import XCTest
@testable import DangerNoPrint
@testable import Danger
@testable import DangerFixtures

final class DangerNoPrintExtensionTests: XCTestCase {
    func testNoResult() {
        let allFalsePredicate: Predicate<String> = Predicate<String>(matcher: { (line) -> Bool in
            return false
        })
        let danger = githubWithFilesDSL(created: ["file.swift"], fileMap: ["file.swift": activePrintStatement])
        XCTAssertTrue(danger.utils.lines(for: allFalsePredicate, inFile: "file.swift").isEmpty)
    }
    
    func testPrintFoundInCode() {
        let danger = githubWithFilesDSL(created: ["file.swift"], fileMap: ["file.swift": activePrintStatement])
        let found = danger.utils.lines(for: Predicate.CheckPrint, inFile: "file.swift")
        XCTAssertEqual(found.count, 1)
        XCTAssertEqual(found, [LineValue("file.swift", 1,"    print(amenity)")])
    }
    
    func testCommentedPrintFoundInCode() {
        let danger = githubWithFilesDSL(created: ["file.swift"], fileMap: ["file.swift": commentedPrintStatement])
        let found = danger.utils.lines(for: Predicate.CheckPrint, inFile: "file.swift")
        XCTAssertEqual(found.count, 2)
        XCTAssertEqual(found, [LineValue("file.swift", 1, "    print(amenity)"), LineValue("file.swift", 2, "    // print(amenity)")])
    }
    
    static var allTests = [
        ("testNoResult", testNoResult),
        ("testPrintFoundInCode", testPrintFoundInCode),
        ("testCommentedPrintFoundInCode", testCommentedPrintFoundInCode),
    ]
}
