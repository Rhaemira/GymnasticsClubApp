import SwiftUI
import UIKit

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var selectionAnimation
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    let change = { selectedTab = tab }
                    if reduceMotion {
                        change()
                    } else {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.78), change)
                    }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    VStack(spacing: 5) {
                        ZStack {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 17, style: .continuous)
                                    .fill(tab.color.opacity(0.15))
                                    .matchedGeometryEffect(id: "selected-tab", in: selectionAnimation)
                            }
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .symbolVariant(selectedTab == tab ? .fill : .none)
                        }
                        .frame(height: 32)
                        Text(tab.title)
                            .font(.system(.caption2, design: .rounded, weight: selectedTab == tab ? .semibold : .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(selectedTab == tab ? tab.color : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .padding(.vertical, 7)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule().strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: 7)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.dashboard))
        .padding()
}
