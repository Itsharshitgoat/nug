import XCTest
import SwiftUI
@testable import Nuggs

final class VisualEffectViewTests: XCTestCase {

    func testViewCreationAndUpdates() {
        let view = VisualEffectView(
            material: .hudWindow,
            blendingMode: .withinWindow,
            state: .inactive,
            isEmphasized: true
        )

        let hostingView = NSHostingView(rootView: view)
        hostingView.layout() // Triggers SwiftUI to create and update the NSView

        guard let effectView = hostingView.subviews.first as? NSVisualEffectView else {
            XCTFail("Could not find NSVisualEffectView")
            return
        }

        XCTAssertEqual(effectView.material, .hudWindow)
        XCTAssertEqual(effectView.blendingMode, .withinWindow)
        XCTAssertEqual(effectView.state, .inactive)
        XCTAssertEqual(effectView.isEmphasized, true)
        XCTAssertEqual(effectView.autoresizingMask, [.width, .height])
    }
}
