//
//  AttendanceView.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct AttendanceView: View {

    @StateObject
    private var viewModel = AttendanceViewModel()

    @State
    private var searchText = ""

    @State
    private var showingAddSheet = false

    @State
    private var selectedAttendance: Attendance?

    @State
    private var openCardID: UUID?

    @StateObject
    private var undoToast = UndoToastCoordinator()

    private var filteredAttendance: [Attendance] {

        viewModel.attendance.filter {

            searchText.isEmpty ||

            $0.athlete.fullName.localizedCaseInsensitiveContains(searchText) ||

            $0.gymClass.name.localizedCaseInsensitiveContains(searchText)

        }

    }

    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            NavigationStack {

                ZStack {

                    AppBackground(
                        color: FeatureColors.attendance
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
                color: FeatureColors.attendance
            ) {

                showingAddSheet = true

            }

            .padding(26)

        }

        .undoToast(undoToast)

        .task {

            await viewModel.loadData()

        }

        .sheet(isPresented: $showingAddSheet) {

            AttendanceEditorView(
                viewModel: viewModel
            )

        }

        .sheet(item: $selectedAttendance) { attendance in

            AttendanceEditorView(

                viewModel: viewModel,

                attendance: attendance

            )

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

                    await viewModel.loadData()

                }

            }

        }

        else {

            ScrollView {

                VStack(spacing: 24) {

                    FeatureHeader(

                        title: "Attendance",

                        subtitle: "\(filteredAttendance.count) attendance records",

                        icon: "checkmark.circle.fill",

                        color: FeatureColors.attendance

                    )

                    GlassSearchBar(

                        text: $searchText,

                        color: FeatureColors.attendance

                    )

                    AttendanceStatsCard(
                        attendance: filteredAttendance
                    )

                    if filteredAttendance.isEmpty {

                        VStack(spacing: 24) {

                            Image(systemName: "checkmark.circle.badge.plus")

                                .font(.system(size: 72))

                                .foregroundStyle(
                                    FeatureColors.attendance.gradient
                                )

                                .symbolEffect(.bounce)

                            Text("No Attendance Yet")

                                .font(.largeTitle.bold())

                            Text("Record your first training session.")

                                .foregroundStyle(.secondary)

                        }

                        .padding(.top, 100)

                    }

                    else {

                        LazyVStack(spacing: 18) {

                            ForEach(filteredAttendance) { attendance in

                                NavigationLink {

                                    AttendanceDetailView(
                                        attendance: attendance
                                    )

                                } label: {

                                    SwipeCard(

                                        id: attendance.id,

                                        openCardID: $openCardID,

                                        color: FeatureColors.attendance,

                                        onEdit: {

                                            selectedAttendance = attendance

                                        },

                                        onDelete: {

                                            undoToast.schedule(label: "Delete \(attendance.athlete.fullName)'s attendance?") {

                                                await viewModel.deleteAttendance(attendance)

                                            }

                                        }

                                    ) {

                                        AttendanceRow(attendance: attendance)

                                    }

                                }

                                .buttonStyle(.plain)

                                .contextMenu {

                                    Button {

                                        selectedAttendance = attendance

                                    } label: {

                                        Label(
                                            "Edit",
                                            systemImage: "pencil"
                                        )

                                    }

                                    Button(
                                        role: .destructive
                                    ) {

                                        undoToast.schedule(label: "\(attendance.athlete.fullName) deleted") {

                                            await viewModel.deleteAttendance(attendance)

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
                await viewModel.loadData()
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
