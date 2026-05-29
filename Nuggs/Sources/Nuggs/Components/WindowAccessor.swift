import SwiftUI
import AppKit

// Extension to allow custom window styling like removing title bar while keeping it draggable
struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = WindowObserverView()
        view.onWindowChange = { window in
            self.callback(window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

/// Custom NSView subclass that reliably detects when it is added to a window.
/// This fixes the race condition where DispatchQueue.main.async fires before
/// the view is actually attached to an NSWindow, resulting in a nil window reference.
private class WindowObserverView: NSView {
    var onWindowChange: ((NSWindow?) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let window = self.window {
            onWindowChange?(window)
        }
    }
}

extension View {
    func configureWindow(callback: @escaping (NSWindow?) -> Void) -> some View {
        self.background(WindowAccessor(callback: callback))
    }
}
