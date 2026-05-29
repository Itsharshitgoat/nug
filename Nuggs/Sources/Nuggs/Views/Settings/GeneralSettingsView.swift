import SwiftUI

struct ProviderConnectionView: View {
    let name: String
    @Binding var isConnected: Bool
    @State private var isHovered: Bool = false

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 15, weight: .medium))

            Spacer()

            Button(action: {
                withAnimation(.spring()) {
                    isConnected.toggle()
                }
            }) {
                Text(isConnected ? "Disconnect" : "Connect")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isConnected ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                            .shadow(color: (isConnected ? Color.green : Color.red).opacity(isHovered ? 0.4 : 0.2), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .padding(.vertical, 8)
    }
}

struct GeneralSettingsView: View {
    @State private var launchAtLogin: Bool = true
    @State private var isChatGPTConnected: Bool = false
    @State private var isClaudeConnected: Bool = true
    @State private var isGeminiConnected: Bool = false
    @State private var mouseAcceleration: Double = 0.5

    var body: some View {
        VStack(spacing: 24) {
            // Top Section: Launch at Login & Providers
            VStack(spacing: 16) {
                Toggle(isOn: $launchAtLogin) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.dashed")
                            .font(.system(size: 16))
                        Text("Launch at login")
                            .font(.system(size: 15, weight: .medium))
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(.bottom, 8)

                VStack(spacing: 4) {
                    ProviderConnectionView(name: "Chat GPT", isConnected: $isChatGPTConnected)
                    ProviderConnectionView(name: "Claude", isConnected: $isClaudeConnected)
                    ProviderConnectionView(name: "Gemini", isConnected: $isGeminiConnected)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.4))
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )

            // Middle Section: Mouse Acceleration & Keyboard Shortcut
            VStack(spacing: 24) {
                // Mouse Acceleration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mouse Acceleration")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack(spacing: 12) {
                        Image(systemName: "tortoise.fill")
                            .foregroundColor(.secondary)

                        Slider(value: $mouseAcceleration, in: 0...1)
                            .accentColor(.blue)

                        Image(systemName: "hare.fill")
                            .foregroundColor(.secondary)
                    }
                }

                Divider()
                    .opacity(0.5)

                // Keyboard Shortcut
                HStack {
                    Text("Keyboard shortcut")
                        .font(.system(size: 15, weight: .medium))

                    Spacer()

                    Text("⌥ G")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                                .background(VisualEffectView(material: .titlebar, blendingMode: .withinWindow).clipShape(Capsule()))
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
                        )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.4))
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .padding(24)
    }
}
