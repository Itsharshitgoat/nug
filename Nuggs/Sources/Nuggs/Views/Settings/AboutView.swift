import SwiftUI

struct AboutView: View {
    @State private var isAnimating: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            // App Icon & Info Section
            VStack(spacing: 16) {
                // Application Icon Integration
                if let appIcon = NSApplication.shared.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        // Soft, spatial ambient shadow
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                        // Subtle elevation highlight
                        .shadow(color: Color.white.opacity(0.1), radius: 1, x: 0, y: 1)
                        .padding(.top, 20)
                        // Native scale animation on appear
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isAnimating)
                        .onAppear {
                            isAnimating = true
                        }
                } else {
                    // Fallback if icon is missing
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .padding(.top, 20)
                }

                VStack(spacing: 8) {
                    Text("AI at the shaking of your mouse")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("Nuggs 1.0v")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.4))
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )

            Spacer()

            // Creator Banner
            Text("Created with ❤️ By Harshit")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.blue)
                        .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                )
        }
        .padding(24)
    }
}
