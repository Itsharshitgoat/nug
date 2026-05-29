import XCTest
@testable import Nuggs

final class FloatingWindowManagerTests: XCTestCase {

    var manager: FloatingWindowManager!

    override func setUp() {
        super.setUp()
        manager = FloatingWindowManager()
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testCalculateTargetPosition_NormalPlacementRight() {
        let mouseLoc = CGPoint(x: 500, y: 500)
        let windowSize = CGSize(width: 200, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        // Ensure we start with preferred side right
        manager.preferredSideIsRight = true

        let targetPosition = manager.calculateTargetPosition(mouseLoc: mouseLoc, windowSize: windowSize, screenFrame: screenFrame)

        // Expected X: mouseLoc.x (500) + cursorOffsetRight (24) = 524
        // Expected Y: mouseLoc.y (500) - cursorOffsetBelow (24) - windowSize.height (200) = 276
        XCTAssertEqual(targetPosition.x, 524)
        XCTAssertEqual(targetPosition.y, 276)
        XCTAssertTrue(manager.preferredSideIsRight, "Should still prefer right side")
    }

    func testCalculateTargetPosition_EdgeConstraintRight_SwitchesToLeft() {
        let mouseLoc = CGPoint(x: 900, y: 500)
        let windowSize = CGSize(width: 200, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        manager.preferredSideIsRight = true

        let targetPosition = manager.calculateTargetPosition(mouseLoc: mouseLoc, windowSize: windowSize, screenFrame: screenFrame)

        // neededSpaceRight = 900 + 24 + 200 = 1124 > screenFrame.maxX (1000). So switches to left.
        // Expected X: mouseLoc.x (900) + cursorOffsetLeft (-24) - windowSize.width (200) = 676
        // Expected Y: mouseLoc.y (500) - cursorOffsetBelow (24) - windowSize.height (200) = 276
        XCTAssertEqual(targetPosition.x, 676)
        XCTAssertEqual(targetPosition.y, 276)
        XCTAssertFalse(manager.preferredSideIsRight, "Should switch to preferring left side")
    }

    func testCalculateTargetPosition_Hysteresis_StaysLeft() {
        // Assume it's already on the left
        manager.preferredSideIsRight = false

        // Move cursor slightly to the left, but not enough to clear the buffer (buffer = 60)
        // max width = 1000. neededSpaceRight = mouseLoc.x + 24 + 200
        // Switch to right requires: neededSpaceRight + 60 < 1000 -> mouseLoc.x + 284 < 1000 -> mouseLoc.x < 716
        // Let's test at 750
        let mouseLoc = CGPoint(x: 750, y: 500)
        let windowSize = CGSize(width: 200, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        let targetPosition = manager.calculateTargetPosition(mouseLoc: mouseLoc, windowSize: windowSize, screenFrame: screenFrame)

        XCTAssertFalse(manager.preferredSideIsRight, "Should stay on left side due to hysteresis buffer")
        // Expected X: mouseLoc.x (750) + cursorOffsetLeft (-24) - windowSize.width (200) = 526
        XCTAssertEqual(targetPosition.x, 526)
    }

    func testCalculateTargetPosition_Hysteresis_SwitchesBackToRight() {
        // Assume it's already on the left
        manager.preferredSideIsRight = false

        // Switch to right requires: mouseLoc.x < 716
        let mouseLoc = CGPoint(x: 700, y: 500)
        let windowSize = CGSize(width: 200, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        let targetPosition = manager.calculateTargetPosition(mouseLoc: mouseLoc, windowSize: windowSize, screenFrame: screenFrame)

        XCTAssertTrue(manager.preferredSideIsRight, "Should switch back to right side as buffer is cleared")
        // Expected X: mouseLoc.x (700) + cursorOffsetRight (24) = 724
        XCTAssertEqual(targetPosition.x, 724)
    }

    func testCalculateTargetPosition_ClampsToScreenSafeBounds_Bottom() {
        let mouseLoc = CGPoint(x: 500, y: 100) // Near bottom of screen
        let windowSize = CGSize(width: 200, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        manager.preferredSideIsRight = true

        let targetPosition = manager.calculateTargetPosition(mouseLoc: mouseLoc, windowSize: windowSize, screenFrame: screenFrame)

        // Raw Y: mouseLoc.y (100) - cursorOffsetBelow (24) - windowSize.height (200) = -124
        // Clamp Min Y: screenFrame.minY (0) + 16 = 16
        XCTAssertEqual(targetPosition.y, 16)
    }

    func testCalculateTargetPosition_ClampsToScreenSafeBounds_Top() {
        let mouseLoc = CGPoint(x: 500, y: 1200) // Cursor off top of screen, let's say
        let windowSize = CGSize(width: 200, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        manager.preferredSideIsRight = true

        let targetPosition = manager.calculateTargetPosition(mouseLoc: mouseLoc, windowSize: windowSize, screenFrame: screenFrame)

        // Raw Y: mouseLoc.y (1200) - cursorOffsetBelow (24) - windowSize.height (200) = 976
        // Clamp Max Y: screenFrame.maxY (1000) - windowSize.height (200) - 16 = 784
        XCTAssertEqual(targetPosition.y, 784)
    }

    func testCalculateTargetPosition_ClampsToScreenSafeBounds_Left() {
        let mouseLoc = CGPoint(x: 10, y: 500) // Near left edge
        let windowSize = CGSize(width: 200, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        // Force to left side manually, even though it wouldn't normally trigger here
        manager.preferredSideIsRight = false

        let targetPosition = manager.calculateTargetPosition(mouseLoc: mouseLoc, windowSize: windowSize, screenFrame: screenFrame)

        // Raw X (Left Side): mouseLoc.x (10) + cursorOffsetLeft (-24) - windowSize.width (200) = -214
        // Clamp Min X: screenFrame.minX (0) + 16 = 16
        XCTAssertEqual(targetPosition.x, 16)
    }

    func testCalculateTargetPosition_ClampsToScreenSafeBounds_Right() {
        let mouseLoc = CGPoint(x: 990, y: 500) // Near right edge
        let windowSize = CGSize(width: 200, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        // Force to right side
        manager.preferredSideIsRight = true

        let targetPosition = manager.calculateTargetPosition(mouseLoc: mouseLoc, windowSize: windowSize, screenFrame: screenFrame)

        // Raw X (Right Side): mouseLoc.x (990) + cursorOffsetRight (24) = 1014
        // Clamp Max X: screenFrame.maxX (1000) - windowSize.width (200) - 16 = 784
        // Oh actually the needed space check might switch it to false if we don't bypass it. Let's trace it:
        // neededSpaceRight = 990 + 24 + 200 = 1214 > 1000. It will switch to left side!
        // Raw X (Left Side): mouseLoc.x (990) + cursorOffsetLeft (-24) - windowSize.width (200) = 766
        // Clamp Max X is 784, minX is 16.
        // It should be 766.
        XCTAssertEqual(targetPosition.x, 766)
    }
}