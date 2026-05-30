import SwiftUI

struct ContentView: View {
    @State private var selectedModel: AIModel = .claude
    @State private var inputText: String = ""
    @StateObject private var floatingManager = FloatingWindowManager.shared

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack(alignment: .top) {
            // Main Content Canvas
            VStack {
                Spacer()

                // Conversational canvas (empty for now)

                Spacer()

                // Input Bar at the bottom
                InputBarView(text: $inputText)
            }

            // Top Model Selector
            ModelSelectorView(selectedModel: $selectedModel)
                .padding(.top, 16)
        }
        .frame(width: 600, height: 400) // Default sizing
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active)
                .edgesIgnoringSafeArea(.all)
                // Adjust blur subtly when moving
                .opacity(floatingManager.isMoving ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: floatingManager.isMoving)
        )
        .clipShape(AsymmetricalWindowShape(radius: 28))
        // Dynamic depth & shadow behavior applied to custom shape
        .shadow(
            color: Color.black.opacity(floatingManager.isMoving ? 0.3 : 0.2),
            radius: floatingManager.isMoving ? 25 : 20,
            x: -2, // Slight left bias to emphasize the sharp architectural corner
            y: floatingManager.isMoving ? 15 : 10
        )
        // Summon animation states (Opacity, Scale, Vertical Offset) respecting Reduce Motion
        .opacity(floatingManager.isVisible ? 1.0 : 0.0)
        .scaleEffect(floatingManager.isVisible ? (floatingManager.isMoving && !floatingManager.isHovered && !reduceMotion ? 1.02 : 1.0) : (reduceMotion ? 1.0 : 0.85))
        .offset(y: floatingManager.isVisible ? 0 : (reduceMotion ? 0 : 20)) // Disable upward materialization if reduced motion

        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: floatingManager.isVisible)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: floatingManager.isMoving)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: floatingManager.isHovered)
        .overlay(
            AsymmetricalWindowShape(radius: 28)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        // Extract window and link to FloatingWindowManager
        .configureWindow { window in
            guard let window = window else { return }
            window.hasShadow = false
            window.isOpaque = false
            window.backgroundColor = .clear
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.remove(.titled)
            window.styleMask.insert(.fullSizeContentView)

            // Hide standard buttons for Main Window
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true

            // It floats via the manager, so we typically do not want it easily movable by dragging
            // but we leave it enabled inside the interaction area if the user explicitly drags it.
            window.isMovableByWindowBackground = true

            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            // Initially ignore mouse events until summoned
            // window.ignoresMouseEvents = true
            window.ignoresMouseEvents = !FloatingWindowManager.shared.isVisible

            // Connect to manager
            FloatingWindowManager.shared.window = window
        }
    }
}
