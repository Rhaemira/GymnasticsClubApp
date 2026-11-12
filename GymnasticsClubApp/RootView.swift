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
            session.noticeMessage == nil ? "Connection problem" : "Sign-out notice",
            isPresented: Binding(
                get: {
                    session.noticeMessage != nil ||
                    (session.isAuthenticated && session.errorMessage != nil)
                },
                set: {
                    if !$0 {
                        session.clearError()
                        session.clearNotice()
                    }
                }
            )
        ) {
            if session.noticeMessage != nil {
                Button("OK", role: .cancel) { session.clearNotice() }
            } else {
                Button("Retry") { Task { await session.retryRestore() } }
                Button("Dismiss", role: .cancel) { session.clearError() }
            }
        } message: {
            Text(session.noticeMessage ?? session.errorMessage ?? "The server could not verify your session.")
        }
    }
}

/// Mirrors LexiDFA's native TabView implementation. On iOS 26 the system
/// supplies the floating Liquid Glass tab bar; each feature retains its own
/// NavigationStack and is loaded only while selected.
private struct TabShell: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environment(\.isTabActive, selectedTab == .dashboard)
                .tabItem { Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.icon) }
                .tag(AppTab.dashboard)

            AthletesView()
                .environment(\.isTabActive, selectedTab == .athletes)
                .tabItem { Label(AppTab.athletes.title, systemImage: AppTab.athletes.icon) }
                .tag(AppTab.athletes)

            CoachesView()
                .environment(\.isTabActive, selectedTab == .coaches)
                .tabItem { Label(AppTab.coaches.title, systemImage: AppTab.coaches.icon) }
                .tag(AppTab.coaches)

            ClassesView()
                .environment(\.isTabActive, selectedTab == .classes)
                .tabItem { Label(AppTab.classes.title, systemImage: AppTab.classes.icon) }
                .tag(AppTab.classes)

            AttendanceView()
                .environment(\.isTabActive, selectedTab == .attendance)
                .tabItem { Label(AppTab.attendance.title, systemImage: AppTab.attendance.icon) }
                .tag(AppTab.attendance)
        }
        .tint(selectedTab.color)
    }
}

#Preview {
    RootView()
}
