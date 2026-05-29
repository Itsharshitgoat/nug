import SwiftUI

enum SettingsTab: String, CaseIterable {
    case general = "General"
    case about = "About"
}

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        VStack(spacing: 0) {
            // Title Bar Area (Custom)
            HStack {
                Text(selectedTab == .general ? "Settings - General" : "Settings - About")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Main Content Area
            ZStack {
                if selectedTab == .general {
                    GeneralSettingsView()
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                } else {
                    AboutView()
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)

            // Bottom Tab Switcher
            HStack(spacing: 0) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab == .general ? "gearshape.fill" : "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(selectedTab == tab ? .blue : .primary)

                            Text(tab.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        }
                        .frame(width: 80, height: 50)
                        .background(
                            ZStack {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.8))
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                        .matchedGeometryEffect(id: "TabBackground", in: animation)
                                }
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(6)
            .background(
                Capsule()
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.4))
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).clipShape(Capsule()))
                    .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
            )
            .padding(.bottom, 24)
        }
        .frame(width: 380, height: 600)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active)
                .edgesIgnoringSafeArea(.all)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .configureWindow { window in
            guard let window = window else { return }
            window.isOpaque = false
            window.backgroundColor = .clear
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
            // Make it draggable by background
            window.isMovableByWindowBackground = true

            // Adding standard window buttons
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = false
            window.standardWindowButton(.zoomButton)?.isHidden = false

            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces]
        }
    }

    @Namespace private var animation
}
