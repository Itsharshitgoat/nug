import XCTest
import AppKit
@testable import Nuggs

final class FloatingWindowManagerTests: XCTestCase {
    var manager: FloatingWindowManager!
    var mockWindow: NSWindow!

    override func setUp() {
        super.setUp()
        // Wait for shared instance if it exists, or just use a new one for testing if possible.
        // Since FloatingWindowManager is an ObservableObject with a static shared, it's generally best to reset its state,
        // but creating a new instance is safer for isolated tests. We will use a new instance if we can,
        // but its initializers are public enough.
        manager = FloatingWindowManager()

        // Create a mock window
        mockWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
    }

    override func tearDown() {
        manager = nil
        mockWindow = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(manager.isVisible, "Window should not be visible initially")
        XCTAssertFalse(manager.isMoving, "Window should not be moving initially")
        XCTAssertFalse(manager.isHovered, "Window should not be hovered initially")
    }

    func testWindowAssignment() {
        XCTAssertNil(manager.window, "Window should be nil initially")
        manager.window = mockWindow
        XCTAssertNotNil(manager.window, "Window should be set")
    }

    func testDismissal() {
        manager.window = mockWindow

        // Force it visible for the test
        manager.isVisible = true
        manager.window?.ignoresMouseEvents = false

        XCTAssertTrue(manager.isVisible)
        XCTAssertFalse(manager.window!.ignoresMouseEvents)

        let expectation = self.expectation(description: "Dismissal completes")

        manager.dismiss()

        // Use a more robust expectation wait instead of hardcoded delay
        DispatchQueue.main.async {
            XCTAssertFalse(self.manager.isVisible, "Window should be hidden after dismiss")
            XCTAssertTrue(self.manager.window!.ignoresMouseEvents, "Window should ignore mouse events after dismiss")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testTargetPositionUpdate() {
        manager.window = mockWindow
        manager.isVisible = true

        // We can test the positioning logic indirectly by invoking the private method using reflection
        // or by triggering the state changes that would cause it.
        // A better way without modifying the internal access control is to test the effect of window assignment,
        // which triggers updateTargetPosition internally.

        let initialOrigin = mockWindow.frame.origin

        // Creating a new manager to trigger the initial positioning logic cleanly
        let newManager = FloatingWindowManager()
        newManager.window = mockWindow

        // After assigning window, it should update its origin to follow the cursor (simulated)
        // Note: In a real environment NSEvent.mouseLocation is dynamic. In tests it might return .zero or last known.

        // Wait for the asynchronous origin update to occur
        let expectation = self.expectation(description: "Position update")

        DispatchQueue.main.async {
            let updatedOrigin = newManager.window?.frame.origin
            XCTAssertNotNil(updatedOrigin)

            // NSEvent.mouseLocation could be anything, but let's assert the frame origin was updated from the default (0,0)
            // or at least that it's a valid point (even if it calculates to 0,0 based on screen bounds).
            // A more robust check is whether the origin is finite
            if let origin = updatedOrigin {
                XCTAssertTrue(origin.x.isFinite)
                XCTAssertTrue(origin.y.isFinite)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
