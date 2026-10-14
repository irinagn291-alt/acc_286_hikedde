import XCTest
@testable import Heddle

/// Placeholder. Replace with the cases required by SPEC.md section 17.
final class HeddleTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: HeddleApp.self), "HeddleApp")
    }
}
