import SwiftUI

struct AddButton: View {
    let color: Color
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    var body: some View {
        Button {
            guard !reduceMotion else {
                action()
                return
            }
            withAnimation(.spring(response: 0.24, dampingFraction: 0.68)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                isPressed = false
            }
            action()
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(isPressed ? 90 : 0))
                .frame(width: 58, height: 58)
                .background {
                    Circle().fill(color.gradient)
                }
                .overlay {
                    Circle().strokeBorder(.white.opacity(0.28), lineWidth: 1)
                }
                .shadow(color: color.opacity(0.28), radius: 12, y: 5)
                .scaleEffect(isPressed ? 0.92 : 1)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.72), value: isPressed)
        .accessibilityLabel("Add")
    }
}
