import XCTest
@testable import Heddle

final class ReviewLaunchTests: XCTestCase {
    func testReviewScreenParsesLaunchArguments() {
        XCTAssertNil(ReviewLaunch.screen(in: ["Heddle"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Heddle", "-ReviewScreen"]))
        XCTAssertEqual(ReviewLaunch.screen(in: ["Heddle", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Heddle", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Heddle", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Heddle", "-ReviewScreen", "settings"]), "settings")
    }
}
