import SwiftUI

struct DashboardView: View {
    @Environment(\.isTabActive) private var isTabActive
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) { Task { await viewModel.loadDashboard() } }
                } else if let stats = viewModel.stats {
                    ScrollView {
                        VStack(spacing: 24) {
                            DashboardHeader()
                            DashboardContent(stats: stats, attendance: viewModel.attendance)
                        }
                        .padding(.top)
                    }
                    .refreshable { await viewModel.loadDashboard() }
                } else {
                    ContentUnavailableView("No dashboard data", systemImage: "chart.bar", description: Text("Pull to refresh or try again."))
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink { AnalyticsView() } label: {
                        Image(systemName: "chart.xyaxis.line").accessibilityLabel("Analytics")
                    }
                    NavigationLink { SettingsView() } label: {
                        Image(systemName: "gearshape").accessibilityLabel("Settings")
                    }
                }
            }
            .task(id: isTabActive) {
                guard isTabActive else { return }
                await viewModel.loadDashboard()
            }
        }
    }
}
