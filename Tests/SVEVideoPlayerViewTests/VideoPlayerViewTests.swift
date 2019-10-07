import XCTest
@testable import SVEVideoPlayerView

final class SVEVideoPlayerViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertNil(VideoPlayerView().videoURL)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
