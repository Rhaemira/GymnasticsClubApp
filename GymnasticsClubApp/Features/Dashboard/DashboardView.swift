//
//  DashboardView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//

import SwiftUI

struct DashboardView: View {

    @StateObject
    private var viewModel = DashboardViewModel()

    var body: some View {

        ZStack {

            AnimatedGradientBackground()

            if viewModel.isLoading {

                LoadingView()

            } else if let error = viewModel.errorMessage {

                ErrorView(message: error) {
                    Task { await viewModel.loadDashboard() }
                }

            } else if let stats = viewModel.stats {

                ScrollView {

                    VStack(spacing: 28) {

                        DashboardHeader()
                            .dashboardAppear(delay: 0)

                        DashboardContent(
                            stats: stats,
                            attendance: viewModel.attendance
                        )

                    }
                    .padding(.top)

                }
                .refreshable {
                    await viewModel.loadDashboard()
                }

            } else {

                Text("stats == nil")

            }

        }
        .task {
            await viewModel.loadDashboard()
        }

    }

}

#Preview {
    DashboardView()
}
