//
//  CoachesView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/13/26.
//

import SwiftUI

struct CoachesView: View {

    @StateObject
    private var viewModel = CoachesViewModel()

    @State
    private var searchText = ""

    @State
    private var showingAddSheet = false

    @State
    private var selectedCoach: Coach?

    @State
    private var openCardID: UUID?

    @StateObject
    private var undoToast = UndoToastCoordinator()

    private var filteredCoaches: [Coach] {

        viewModel.coaches.filter {

            searchText.isEmpty ||

            $0.fullName.localizedCaseInsensitiveContains(searchText) ||

            $0.specialty.localizedCaseInsensitiveContains(searchText)

        }

    }

    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            NavigationStack {

                ZStack {

                    AppBackground(
                        color: FeatureColors.coaches
                    )

                    content

                }

                .navigationBarTitleDisplayMode(.inline)

                .toolbar {

                    ToolbarItem(placement: .principal) {

                        EmptyView()

                    }

                }

            }

            AddButton(
                color: FeatureColors.coaches
            ) {

                showingAddSheet = true

            }

            .padding(26)

        }

        .undoToast(undoToast)

        .task {

            await viewModel.loadCoaches()

        }

        .sheet(isPresented: $showingAddSheet) {

            CoachFormView(

                title: "New Coach",

                buttonTitle: "Add"

            ) { fullName, specialty in

                await viewModel.addCoach(

                    fullName: fullName,

                    specialty: specialty

                )

            }

        }

        .sheet(item: $selectedCoach) { coach in

            CoachFormView(

                title: "Edit Coach",

                buttonTitle: "Save",

                coach: coach

            ) { fullName, specialty in

                await viewModel.updateCoach(

                    coach: coach,

                    fullName: fullName,

                    specialty: specialty

                )

            }

        }

    }

    @ViewBuilder

    private var content: some View {

        if viewModel.isLoading {

            LoadingView()

        }

        else if let error = viewModel.errorMessage {

            ErrorView(message: error) {

                Task {

                    await viewModel.loadCoaches()

                }

            }

        }

        else {

            ScrollView {

                VStack(spacing: 24) {

                    FeatureHeader(

                        title: "Coaches",

                        subtitle: "\(filteredCoaches.count) registered coaches",

                        icon: "person.3.fill",

                        color: FeatureColors.coaches

                    )

                    GlassSearchBar(

                        text: $searchText,

                        color: FeatureColors.coaches

                    )

                    if filteredCoaches.isEmpty {

                        ContentUnavailableView(

                            "No Coaches",

                            systemImage: "person.2.fill",

                            description: Text(

                                "Add your first coach."

                            )

                        )

                        .padding(.top,80)

                    }

                    else {

                        LazyVStack(spacing: 18) {

                            ForEach(filteredCoaches) { coach in

                                NavigationLink {

                                    CoachDetailView(
                                        coach: coach
                                    )

                                } label: {

                                    SwipeCard(

                                        id: coach.id,

                                        openCardID: $openCardID,

                                        color: FeatureColors.coaches,

                                        onEdit: {

                                            selectedCoach = coach

                                        },

                                        onDelete: {

                                            undoToast.schedule(label: "Delete \(coach.fullName)?") {

                                                await viewModel.deleteCoach(coach)

                                            }

                                        }

                                    ) {

                                        CoachRow(coach: coach)

                                    }

                                }

                                .buttonStyle(.plain)

                                .contextMenu {

                                    Button {

                                        selectedCoach = coach

                                    } label: {

                                        Label(
                                            "Edit",
                                            systemImage: "pencil"
                                        )

                                    }

                                    Button(
                                        role: .destructive
                                    ) {

                                        undoToast.schedule(label: "\(coach.fullName) deleted") {

                                            await viewModel.deleteCoach(coach)

                                        }

                                    } label: {

                                        Label(
                                            "Delete",
                                            systemImage: "trash"
                                        )

                                    }

                                }

                            }

                        }

                        .padding(.horizontal)

                    }

                }

                .padding(.top)

                .padding(.bottom,100)

            }

            .refreshable {
                await viewModel.loadCoaches()
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    guard openCardID != nil else { return }
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        openCardID = nil
                    }
                }
            )

        }

    }

}
