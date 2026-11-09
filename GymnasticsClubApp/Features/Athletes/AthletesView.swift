//
//  AthletesView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/10/26.
//


import SwiftUI

struct AthletesView: View {

    @StateObject
    private var viewModel = AthletesViewModel()

    @State
    private var searchText = ""

    @State
    private var showingAddSheet = false

    @State
    private var selectedAthlete: Athlete?

    @StateObject private var undoToast = UndoToastCoordinator()
    
    @State
    private var openCardID: UUID?

    private var filteredAthletes: [Athlete] {

        viewModel.athletes.filter {

            searchText.isEmpty ||

            $0.fullName.localizedCaseInsensitiveContains(searchText)

        }

    }

    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            

            NavigationStack {

                ZStack {

                    AppBackground(
                        color: FeatureColors.athletes
                    )

                    content

                }

            }

            AddButton(
                color: FeatureColors.athletes
            ) {

                showingAddSheet = true

            }

            .padding(26)

        }
        .undoToast(undoToast)

        .task {

            await viewModel.loadAthletes()

        }

        .sheet(isPresented: $showingAddSheet) {

            AthleteFormView(

                title: "New Athlete",

                buttonTitle: "Add"

            ) { name, age, level in

                await viewModel.addAthlete(

                    fullName: name,

                    age: age,

                    level: level

                )

            }

        }

        .sheet(item: $selectedAthlete) { athlete in

            AthleteFormView(

                title: "Edit Athlete",

                buttonTitle: "Save",

                athlete: athlete

            ) { name, age, level in

                await viewModel.updateAthlete(

                    athlete: athlete,

                    fullName: name,

                    age: age,

                    level: level

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

                    await viewModel.loadAthletes()

                }

            }

        }

        else {

            ScrollView {

                VStack(spacing: 24) {

                    FeatureHeader(

                        title: "Athletes",

                        subtitle: "\(filteredAthletes.count) registered athletes",

                        icon: "figure.gymnastics",

                        color: FeatureColors.athletes

                    )

                    GlassSearchBar(

                        text: $searchText,

                        color: FeatureColors.athletes

                    )

                    if filteredAthletes.isEmpty {

                        ContentUnavailableView(

                            "No Athletes",

                            systemImage: "figure.gymnastics",

                            description: Text(

                                "Add your first athlete."

                            )

                        )

                        .padding(.top,80)

                    }

                    else {

                        LazyVStack(spacing: 18) {

                            ForEach(filteredAthletes) { athlete in

                                NavigationLink {

                                    AthleteDetailView(
                                        athlete: athlete
                                    )

                                } label: {

                                    SwipeCard(

                                        id: athlete.id,

                                        openCardID: $openCardID,
                                        
                                        color: FeatureColors.athletes,

                                        onEdit: {

                                            selectedAthlete = athlete

                                        },

                                        onDelete: {

                                            undoToast.schedule(label: "\(athlete.fullName) deleted") {
                                                await viewModel.deleteAthlete(athlete)
                                            }

                                        }

                                    ) {

                                        AthleteRow(
                                            athlete: athlete
                                        )

                                    }

                                }


                                .buttonStyle(.plain)

                                .contextMenu {

                                    Button {

                                        selectedAthlete = athlete

                                    } label: {

                                        Label(

                                            "Edit",

                                            systemImage: "pencil"

                                        )

                                    }

                                    Button(

                                        role: .destructive

                                    ) {

                                        undoToast.schedule(label: "\(athlete.fullName) deleted") {
                                            await viewModel.deleteAthlete(athlete)
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

                await viewModel.loadAthletes()

            }

        }

    }

}
