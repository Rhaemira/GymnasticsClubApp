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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var session = AuthSession.shared
    @StateObject private var undoToast = UndoToastCoordinator()
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        Group {
            if session.isRestoring {
                ProgressView("Restoring your session…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if session.isAuthenticated {
                TabShell(selectedTab: $selectedTab, undoToast: undoToast)
            } else {
                LoginView(session: session)
            }
        }
        .task { await session.restore() }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: session.isAuthenticated)
        .onChange(of: session.isAuthenticated) { _, isAuthenticated in
            if !isAuthenticated {
                undoToast.cancelAll()
            }
        }
        .undoToast(undoToast)
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
    let undoToast: UndoToastCoordinator

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environment(\.isTabActive, selectedTab == .dashboard)
                .tabItem { Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.icon) }
                .tag(AppTab.dashboard)

            AthletesView(undoToast: undoToast)
                .environment(\.isTabActive, selectedTab == .athletes)
                .tabItem { Label(AppTab.athletes.title, systemImage: AppTab.athletes.icon) }
                .tag(AppTab.athletes)

            CoachesView(undoToast: undoToast)
                .environment(\.isTabActive, selectedTab == .coaches)
                .tabItem { Label(AppTab.coaches.title, systemImage: AppTab.coaches.icon) }
                .tag(AppTab.coaches)

            ClassesView(undoToast: undoToast)
                .environment(\.isTabActive, selectedTab == .classes)
                .tabItem { Label(AppTab.classes.title, systemImage: AppTab.classes.icon) }
                .tag(AppTab.classes)

            AttendanceView(undoToast: undoToast)
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
