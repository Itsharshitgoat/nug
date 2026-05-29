import AppKit
import SwiftUI
import Combine

class FloatingWindowManager: ObservableObject {
    static let shared = FloatingWindowManager()

    weak var window: NSWindow? {
        didSet {
            setupTracking()
            if let w = window {
                // Initialize to current mouse location immediately
                let mouseLoc = NSEvent.mouseLocation
                updateTargetPosition(mouseLoc: mouseLoc)
                self.currentPosition = self.targetPosition
                w.setFrameOrigin(self.currentPosition)
                self.isFirstDisplay = false
            }
        }
    }

    @Published var isMoving: Bool = false
    @Published var isHovered: Bool = false
    @Published var isVisible: Bool = false

    private var eventMonitors: [Any] = []
    private var displayLink: CVDisplayLink?

    // Shake Detection State
    private var lastMouseLoc: CGPoint = .zero
    private var shakeReversals: Int = 0
    private var lastDirection: Int = 0 // 1 for right, -1 for left
    private var lastReversalTime: TimeInterval = 0
    private var lastShakeTime: TimeInterval = 0
    private let shakeCooldown: TimeInterval = 1.0 // Cooldown after a summon

    private var targetPosition: CGPoint = .zero
    private var currentPosition: CGPoint = .zero
    private var velocity: CGPoint = .zero

    // Physics properties for soft, spatial, Apple-quality spring motion
    private let stiffness: CGFloat = 180.0
    private let damping: CGFloat = 18.0

    // Spacing
    private let cursorOffsetRight: CGFloat = 24.0
    private let cursorOffsetLeft: CGFloat = -24.0
    private let cursorOffsetBelow: CGFloat = 24.0

    internal var preferredSideIsRight: Bool = true
    private var isFirstDisplay: Bool = true

    private var lastUpdateTime: TimeInterval = 0

    init() {
        setupDisplayLink()
    }

    deinit {
        for monitor in eventMonitors {
            NSEvent.removeMonitor(monitor)
        }
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
    }

    private func setupTracking() {
        for monitor in eventMonitors {
            NSEvent.removeMonitor(monitor)
        }
        eventMonitors.removeAll()

        let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]) { [weak self] event in
            self?.handleMouseMoved()
        }
        if let globalMonitor = globalMonitor {
            eventMonitors.append(globalMonitor)
        }

        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged, .mouseEntered, .mouseExited]) { [weak self] event in
            self?.handleMouseMoved()
            return event
        }
        if let localMonitor = localMonitor {
            eventMonitors.append(localMonitor)
        }

        // Monitor global clicks to dismiss the window
        let clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
            self?.handleGlobalClick()
        }
        if let clickMonitor = clickMonitor {
            eventMonitors.append(clickMonitor)
        }

        // Also local click monitor to catch clicks inside the app and keep it focused
        let localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { event in
            return event
        }
        if let localClickMonitor = localClickMonitor {
            eventMonitors.append(localClickMonitor)
        }
    }

    private func handleGlobalClick() {
        // If we click outside the window, dismiss it naturally
        if self.isVisible && !self.isHovered {
            dismiss()
        }
    }

    func dismiss() {
        DispatchQueue.main.async {
            self.isVisible = false
            self.window?.ignoresMouseEvents = true // Disable interactions while invisible
        }
    }

    private func triggerSummon(mouseLoc: CGPoint) {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastShakeTime > shakeCooldown else { return }
        guard !isVisible else { return }

        lastShakeTime = currentTime

        DispatchQueue.main.async {
            self.isVisible = true
            self.window?.ignoresMouseEvents = false // Re-enable interaction

            // Instantly snap the current position to the mouse so it grows from there natively
            self.isFirstDisplay = true
            self.updateTargetPosition(mouseLoc: mouseLoc)
        }
    }

    private func handleMouseMoved() {
        guard let window = window else { return }

        let mouseLoc = NSEvent.mouseLocation

        // --- Shake Detection Logic ---
        let currentTime = CACurrentMediaTime()

        if lastMouseLoc != .zero {
            let dx = mouseLoc.x - lastMouseLoc.x
            let dy = mouseLoc.y - lastMouseLoc.y

            // Only care about significant horizontal movement (filter out slow or vertical moves)
            if abs(dx) > 5 && abs(dx) > abs(dy) * 1.5 {
                let direction = dx > 0 ? 1 : -1

                if lastDirection != 0 && direction != lastDirection {
                    // Reversal detected!
                    let timeSinceLastReversal = currentTime - lastReversalTime

                    if timeSinceLastReversal < 0.3 {
                        shakeReversals += 1
                    } else {
                        // Reset if took too long
                        shakeReversals = 1
                    }

                    lastReversalTime = currentTime

                    if shakeReversals >= 4 { // 4 rapid reversals = valid shake
                        shakeReversals = 0
                        triggerSummon(mouseLoc: mouseLoc)
                    }
                }

                lastDirection = direction
            }
        }

        // Reset shake count if idle for too long
        if currentTime - lastReversalTime > 0.4 {
            shakeReversals = 0
            lastDirection = 0
        }

        lastMouseLoc = mouseLoc
        // --- End Shake Detection Logic ---
        let windowFrame = window.frame

        // Only do spatial bounds checking and following if the window is currently visible
        if isVisible {
            // Add a slight padding to the bounds check to ensure stable locking
            let boundsRect = windowFrame.insetBy(dx: -10, dy: -10)
            let isInside = boundsRect.contains(mouseLoc)

            if self.isHovered != isInside {
                DispatchQueue.main.async {
                    self.isHovered = isInside
                }
            }

            if isInside {
                // Stop following the cursor so the user can interact with all corners
                return
            }

            updateTargetPosition(mouseLoc: mouseLoc)
        }
    }

    private func updateTargetPosition(mouseLoc: CGPoint) {
        guard let window = window else { return }

        // Find the screen containing the cursor to properly support multi-monitor setups
        let activeScreen = NSScreen.screens.first { NSMouseInRect(mouseLoc, $0.frame, false) } ?? window.screen ?? NSScreen.main
        guard let screen = activeScreen else { return }

        self.targetPosition = calculateTargetPosition(
            mouseLoc: mouseLoc,
            windowSize: window.frame.size,
            screenFrame: screen.visibleFrame
        )

        if isFirstDisplay {
            self.currentPosition = self.targetPosition
            window.setFrameOrigin(self.currentPosition)
            isFirstDisplay = false
        }
    }

    internal func calculateTargetPosition(mouseLoc: CGPoint, windowSize: CGSize, screenFrame: CGRect) -> CGPoint {
        // Determine available space
        let neededSpaceRight = mouseLoc.x + cursorOffsetRight + windowSize.width

        // Hysteresis buffer to prevent flickering side switching
        let buffer: CGFloat = 60.0

        if preferredSideIsRight {
            if neededSpaceRight > screenFrame.maxX {
                preferredSideIsRight = false // Switch to Left
            }
        } else {
            if neededSpaceRight + buffer < screenFrame.maxX {
                preferredSideIsRight = true // Switch back to Right
            }
        }

        var targetX: CGFloat = 0
        var targetY: CGFloat = 0

        if preferredSideIsRight {
            targetX = mouseLoc.x + cursorOffsetRight
        } else {
            targetX = mouseLoc.x + cursorOffsetLeft - windowSize.width
        }

        targetY = mouseLoc.y - cursorOffsetBelow - windowSize.height

        // Edge detection & clamping to screen safe bounds
        targetX = max(screenFrame.minX + 16, min(targetX, screenFrame.maxX - windowSize.width - 16))
        targetY = max(screenFrame.minY + 16, min(targetY, screenFrame.maxY - windowSize.height - 16))

        return CGPoint(x: targetX, y: targetY)
    }

    private func setupDisplayLink() {
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        self.displayLink = link

        let displayLinkOutputCallback: CVDisplayLinkOutputCallback = { (_, _, _, _, _, displayLinkContext) -> CVReturn in
            let manager = Unmanaged<FloatingWindowManager>.fromOpaque(displayLinkContext!).takeUnretainedValue()
            manager.updateFrame()
            return kCVReturnSuccess
        }

        if let link = self.displayLink {
            CVDisplayLinkSetOutputCallback(link, displayLinkOutputCallback, Unmanaged.passUnretained(self).toOpaque())
            CVDisplayLinkStart(link)
        }

        lastUpdateTime = CACurrentMediaTime()
    }

    private func updateFrame() {
        let currentTime = CACurrentMediaTime()
        let dt = min(currentTime - lastUpdateTime, 0.05) // cap dt at 50ms to prevent huge jumps
        lastUpdateTime = currentTime

        DispatchQueue.main.async {
            guard let window = self.window else { return }

            if self.isHovered {
                if self.isMoving {
                    self.isMoving = false
                    self.velocity = .zero // Instantly halt when hovered
                }
                return
            }

            let current = self.currentPosition
            let target = self.targetPosition

            let dx = target.x - current.x
            let dy = target.y - current.y
            let distanceSq = dx*dx + dy*dy

            // Sleep threshold
            if distanceSq < 0.5 && self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y < 0.5 {
                if current != target {
                    self.currentPosition = target
                    window.setFrameOrigin(self.currentPosition)
                }
                self.velocity = .zero
                if self.isMoving {
                    self.isMoving = false
                }
                return
            }

            if !self.isMoving {
                self.isMoving = true
            }

            // Apply damped spring motion
            let forceX = (target.x - current.x) * self.stiffness - self.velocity.x * self.damping
            let forceY = (target.y - current.y) * self.stiffness - self.velocity.y * self.damping

            self.velocity.x += forceX * CGFloat(dt)
            self.velocity.y += forceY * CGFloat(dt)

            self.currentPosition.x += self.velocity.x * CGFloat(dt)
            self.currentPosition.y += self.velocity.y * CGFloat(dt)

            window.setFrameOrigin(self.currentPosition)
        }
    }
}
