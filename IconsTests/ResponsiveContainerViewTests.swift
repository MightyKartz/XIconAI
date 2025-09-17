//
//  ResponsiveContainerViewTests.swift
//  IconsTests
//
//  Created by Icons Team
//

import XCTest
import SwiftUI
@testable import Icons

final class ResponsiveContainerViewTests: XCTestCase {

    func testBreakpointsInitialization() {
        let breakpoints = Breakpoints()

        XCTAssertEqual(breakpoints.compact, 768)
        XCTAssertEqual(breakpoints.comfortable, 1024)
        XCTAssertEqual(breakpoints.spacious, 1440)
    }

    func testBreakpointsCustomInitialization() {
        let breakpoints = Breakpoints(compact: 600, comfortable: 900, spacious: 1200)

        XCTAssertEqual(breakpoints.compact, 600)
        XCTAssertEqual(breakpoints.comfortable, 900)
        XCTAssertEqual(breakpoints.spacious, 1200)
    }

    func testLayoutModeCalculation() {
        let breakpoints = Breakpoints(compact: 600, comfortable: 900, spacious: 1200)

        XCTAssertEqual(breakpoints.layoutMode(for: 500), .compact)
        XCTAssertEqual(breakpoints.layoutMode(for: 700), .comfortable)
        XCTAssertEqual(breakpoints.layoutMode(for: 1000), .spacious)
    }

    func testBreakpointName() {
        let breakpoints = Breakpoints(compact: 600, comfortable: 900, spacious: 1200)
        let expectedName = "紧凑: <600.0px, 舒适: 600.0px-900.0px, 宽松: >900.0px"

        XCTAssertEqual(breakpoints.breakpointName, expectedName)
    }

    func testSpacingInputViewInitialization() {
        let view = SpacingInputView(title: "Test", value: .constant(10))

        XCTAssertNotNil(view)
    }
}