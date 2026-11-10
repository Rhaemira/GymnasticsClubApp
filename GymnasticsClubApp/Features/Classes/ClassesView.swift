//
//  ClassesView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/14/26.
//


import SwiftUI

struct ClassesView: View {

    @StateObject
    private var viewModel = ClassesViewModel()

    @State
    private var searchText = ""

    @State
    private var showingAddSheet = false

    @State
    private var selectedClass: GymClass?

    @State
    private var openCardID: UUID?

    @StateObject
    private var undoToast = UndoToastCoordinator()

    private var filteredClasses: [GymClass] {

        viewModel.classes.filter {

            searchText.isEmpty ||

            $0.name.localizedCaseInsensitiveContains(searchText) ||

            $0.coach.fullName.localizedCaseInsensitiveContains(searchText)

        }

    }

    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            NavigationStack {

                ZStack {

                    AppBackground(
                        color: FeatureColors.classes
                    )

                    content

                }

                .navigationBarTitleDisplayMode(.inline)

                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            EnrollmentManagementView()
                        } label: {
                            Label("Enrollments", systemImage: "person.2.badge.gearshape")
                                .labelStyle(.iconOnly)
                        }
                        .accessibilityLabel("Manage enrollments")
                    }
                }

            }

            AddButton(
                color: FeatureColors.classes
            ) {

                showingAddSheet = true

            }

            .padding(26)

        }

        .undoToast(undoToast)

        .task {

            await viewModel.loadClasses()

        }

        .sheet(isPresented: $showingAddSheet) {

            ClassFormView(

                title: "New Class",

                buttonTitle: "Add",

                coaches: viewModel.coaches

            ) { name, coach, capacity in

                await viewModel.addClass(

                    name: name,

                    capacity: capacity,

                    coachID: coach.id

                )

            }

        }

        .sheet(item: $selectedClass) { gymClass in

            ClassFormView(

                title: "Edit Class",

                buttonTitle: "Save",

                gymClass: gymClass,

                coaches: viewModel.coaches

            ) { name, coach, capacity in

                await viewModel.updateClass(

                    gymClass: gymClass,

                    name: name,

                    capacity: capacity,

                    coachID: coach.id

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

                    await viewModel.loadClasses()

                }

            }

        }

        else {

            ScrollView {

                VStack(spacing: 24) {

                    FeatureHeader(

                        title: "Classes",

                        subtitle: "\(filteredClasses.count) active classes",

                        icon: "figure.flexibility",

                        color: FeatureColors.classes

                    )

                    GlassSearchBar(

                        text: $searchText,

                        color: FeatureColors.classes

                    )

                    if filteredClasses.isEmpty {

                        ContentUnavailableView(

                            "No Classes",

                            systemImage: "figure.flexibility",

                            description: Text(

                                "Create your first class."

                            )

                        )

                        .padding(.top, 80)

                    }

                    else {

                        LazyVStack(spacing: 18) {

                            ForEach(filteredClasses) { gymClass in

                                NavigationLink {

                                    ClassDetailView(
                                        gymClass: gymClass
                                    )

                                } label: {

                                    SwipeCard(

                                        id: gymClass.id,

                                        openCardID: $openCardID,

                                        color: FeatureColors.classes,

                                        onEdit: {

                                            selectedClass = gymClass

                                        },

                                        onDelete: {

                                            undoToast.schedule(label: "Delete \(gymClass.name)?") {

                                                await viewModel.deleteClass(gymClass)

                                            }

                                        }

                                    ) {

                                        ClassRow(gymClass: gymClass)

                                    }

                                }

                                .buttonStyle(.plain)

                                .contextMenu {

                                    Button {

                                        selectedClass = gymClass

                                    } label: {

                                        Label(
                                            "Edit",
                                            systemImage: "pencil"
                                        )

                                    }

                                    Button(
                                        role: .destructive
                                    ) {

                                        undoToast.schedule(label: "\(gymClass.name) deleted") {

                                            await viewModel.deleteClass(gymClass)

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

                .padding(.bottom, 100)

            }

            .refreshable {
                await viewModel.loadClasses()
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
