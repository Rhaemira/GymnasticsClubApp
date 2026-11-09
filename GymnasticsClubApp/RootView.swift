import SwiftUI

struct RootView: View {
    @StateObject private var session = AuthSession.shared
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        Group {
            if session.isAuthenticated {
                TabShell(selectedTab: $selectedTab)
            } else {
                LoginView(session: session)
            }
        }
        .task { await session.restore() }
        .animation(.easeInOut(duration: 0.22), value: session.isAuthenticated)
    }
}

private struct TabShell: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack {
            tab(DashboardView(), is: .dashboard)
            tab(AthletesView(), is: .athletes)
            tab(CoachesView(), is: .coaches)
            tab(ClassesView(), is: .classes)
            tab(AttendanceView(), is: .attendance)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 12)
                .padding(.top, 6)
                .padding(.bottom, 4)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private func tab<Content: View>(_ content: Content, is tab: AppTab) -> some View {
        content
            .opacity(selectedTab == tab ? 1 : 0)
            .allowsHitTesting(selectedTab == tab)
            .accessibilityHidden(selectedTab != tab)
            .zIndex(selectedTab == tab ? 1 : 0)
    }
}

#Preview {
    RootView()
}
