import SwiftUI

enum AIModel: String, CaseIterable, Identifiable {
    case chatGPT = "Chat GPT"
    case claude = "Claude"
    case gemini = "Gemini"

    var id: String { self.rawValue }
}

struct ModelSelectorView: View {
    @Binding var selectedModel: AIModel
    @State private var isExpanded: Bool = false
    @State private var isHovered: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Text(selectedModel.rawValue)
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(.blue) // Soft macOS blue

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .opacity(isHovered || isExpanded ? 0.9 : 0.7)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }

            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(AIModel.allCases) { model in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedModel = model
                                isExpanded = false
                            }
                        }) {
                            Text(model.rawValue)
                                .font(.system(size: 14, weight: model == selectedModel ? .semibold : .medium))
                                .foregroundColor(model == selectedModel ? .blue : .primary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)

                        if model != AIModel.allCases.last {
                            Divider()
                                .opacity(0.5)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(
                    VisualEffectView(material: .popover, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                )
                .frame(width: 140)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
    }
}
