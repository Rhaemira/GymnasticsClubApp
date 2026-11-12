import SwiftUI

struct AttendanceView: View {
    @Environment(\.isTabActive) private var isTabActive
    @StateObject private var viewModel = AttendanceViewModel()
    @StateObject private var undoToast = UndoToastCoordinator()
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var selectedAttendance: Attendance?

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
                content
                    .navigationTitle("Attendance")
                    .navigationBarTitleDisplayMode(.inline)
            }

            AddButton(color: FeatureColors.attendance) {
                showingAddSheet = true
            }
            .padding(26)
        }
        .undoToast(undoToast)
        .task(id: isTabActive) {
            guard isTabActive else { return }
            await viewModel.loadData()
        }
        .sheet(isPresented: $showingAddSheet) {
            AttendanceEditorView(viewModel: viewModel)
        }
        .sheet(item: $selectedAttendance) { attendance in
            AttendanceEditorView(viewModel: viewModel, attendance: attendance)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView()
        } else if let error = viewModel.errorMessage {
            ErrorView(message: error) {
                Task { await viewModel.loadData() }
            }
        } else {
            List {
                Section {
                    VStack(spacing: 18) {
                        FeatureHeader(
                            title: "Attendance",
                            subtitle: "\(filteredAttendance.count) attendance records",
                            icon: "checkmark.circle.fill",
                            color: FeatureColors.attendance
                        )
                        GlassSearchBar(text: $searchText, color: FeatureColors.attendance)
                        AttendanceStatsCard(attendance: filteredAttendance)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                }

                if filteredAttendance.isEmpty {
                    ContentUnavailableView(
                        "No Attendance Yet",
                        systemImage: "checkmark.circle.badge.plus",
                        description: Text(searchText.isEmpty ? "Record your first training session." : "Try a different search.")
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredAttendance) { attendance in
                        NavigationLink {
                            AttendanceDetailView(attendance: attendance)
                        } label: {
                            AttendanceRow(attendance: attendance)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                selectedAttendance = attendance
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(FeatureColors.attendance)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                undoToast.schedule(label: "Delete \(attendance.athlete.fullName)'s attendance?") {
                                    await viewModel.deleteAttendance(attendance)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button {
                                selectedAttendance = attendance
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                undoToast.schedule(label: "Delete \(attendance.athlete.fullName)'s attendance?") {
                                    await viewModel.deleteAttendance(attendance)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background {
                AppBackground(color: FeatureColors.attendance)
            }
            .refreshable { await viewModel.loadData() }
        }
    }
}
