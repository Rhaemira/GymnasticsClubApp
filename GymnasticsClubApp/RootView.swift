import SwiftUI

private struct TabIsActiveKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var isTabActive: Bool {
        get { self[TabIsActiveKey.self] }
        set { self[TabIsActiveKey.self] = newValue }
    }
}

struct RootView: View {
    @StateObject private var session = AuthSession.shared
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        Group {
            if session.isRestoring {
                ProgressView("Restoring your session…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if session.isAuthenticated {
                TabShell(selectedTab: $selectedTab)
            } else {
                LoginView(session: session)
            }
        }
        .task { await session.restore() }
        .animation(.easeInOut(duration: 0.22), value: session.isAuthenticated)
        .alert(
            "Connection problem",
            isPresented: Binding(
                get: { session.isAuthenticated && session.errorMessage != nil },
                set: { if !$0 { session.clearError() } }
            )
        ) {
            Button("Retry") { Task { await session.retryRestore() } }
            Button("Dismiss", role: .cancel) { session.clearError() }
        } message: {
            Text(session.errorMessage ?? "The server could not verify your session.")
        }
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
            .environment(\.isTabActive, selectedTab == tab)
            .opacity(selectedTab == tab ? 1 : 0)
            .allowsHitTesting(selectedTab == tab)
            .accessibilityHidden(selectedTab != tab)
            .zIndex(selectedTab == tab ? 1 : 0)
    }
}

#Preview {
    RootView()
}
