import SwiftUI
import AppKit

@main
struct NuggsApp: App {
    // Hide standard menu bar for main window (to make it a floating app)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Main AI Window
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())

        // Settings Window
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep the app as a regular app so the Dock icon shows up as requested
        NSApp.setActivationPolicy(.regular)
    }
}
