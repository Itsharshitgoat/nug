import SwiftUI

struct InputBarView: View {
    @Binding var text: String
    @State private var isHovered: Bool = false
    @State private var isButtonHovered: Bool = false
    @State private var isButtonPressed: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Input Field Area
            TextField("", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 15, weight: .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.4))
                        .background(VisualEffectView(material: .contentBackground, blendingMode: .withinWindow).clipShape(Capsule()))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        )
                )

            // Action Button
            Button(action: {
                // Action to send message
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 36, height: 36)
                        .shadow(color: Color.blue.opacity(0.4), radius: isButtonHovered ? 6 : 4, x: 0, y: isButtonHovered ? 3 : 2)
                        .scaleEffect(isButtonPressed ? 0.92 : (isButtonHovered ? 1.05 : 1.0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonHovered)
                        .animation(.interactiveSpring(), value: isButtonPressed)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                isButtonHovered = hovering
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isButtonPressed = true }
                    .onEnded { _ in isButtonPressed = false }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            VisualEffectView(material: .titlebar, blendingMode: .withinWindow)
                .mask(
                    VStack {
                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom)
                            .frame(height: 20)
                        Rectangle()
                    }
                )
        )
    }
}
