import SwiftUI

struct CoachesView: View {
    init(undoToast: UndoToastCoordinator) {
        self.undoToast = undoToast
    }

    @Environment(\.isTabActive) private var isTabActive
    @StateObject private var viewModel = CoachesViewModel()
    let undoToast: UndoToastCoordinator
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var selectedCoach: Coach?

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
                    AppBackground(color: FeatureColors.coaches)
                    content
                }
                .navigationBarTitleDisplayMode(.inline)
            }

            AddButton(color: FeatureColors.coaches) {
                showingAddSheet = true
            }
            .padding(26)
        }
        .task(id: isTabActive) {
            guard isTabActive else { return }
            await viewModel.loadCoaches()
        }
        .sheet(isPresented: $showingAddSheet) {
            CoachFormView(title: "New Coach", buttonTitle: "Add") { fullName, specialty in
                await viewModel.addCoach(fullName: fullName, specialty: specialty)
            }
        }
        .sheet(item: $selectedCoach) { coach in
            CoachFormView(title: "Edit Coach", buttonTitle: "Save", coach: coach) { fullName, specialty in
                await viewModel.updateCoach(coach: coach, fullName: fullName, specialty: specialty)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.coaches.isEmpty {
            LoadingView()
        } else if let error = viewModel.errorMessage, viewModel.coaches.isEmpty {
            ErrorView(message: error) {
                Task { await viewModel.loadCoaches() }
            }
        } else {
            List {
                Section {
                    VStack(spacing: 18) {
                        FeatureHeader(
                            title: "Coaches",
                            subtitle: "\(filteredCoaches.count) registered coaches",
                            icon: "person.3.fill",
                            color: FeatureColors.coaches
                        )
                        GlassSearchBar(text: $searchText, color: FeatureColors.coaches)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                }

                if let error = viewModel.errorMessage {
                    Section {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 4)
                            Button {
                                viewModel.errorMessage = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel("Dismiss error")
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }

                if filteredCoaches.isEmpty {
                    ContentUnavailableView(
                        "No Coaches",
                        systemImage: "person.2.fill",
                        description: Text(searchText.isEmpty ? "Add your first coach." : "Try a different search.")
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredCoaches) { coach in
                        NavigationLink {
                            CoachDetailView(coach: coach)
                        } label: {
                            CoachRow(coach: coach)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                selectedCoach = coach
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(FeatureColors.coaches)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                undoToast.schedule(label: "Delete \(coach.fullName)?") {
                                    await viewModel.deleteCoach(coach)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button {
                                selectedCoach = coach
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                undoToast.schedule(label: "Delete \(coach.fullName)?") {
                                    await viewModel.deleteCoach(coach)
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
            .refreshable { await viewModel.loadCoaches() }
        }
    }
}
