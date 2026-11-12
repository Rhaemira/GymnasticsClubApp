import SwiftUI

struct AthletesView: View {
    @MainActor
    init(undoToast: UndoToastCoordinator = UndoToastCoordinator()) {
        self.undoToast = undoToast
    }

    @Environment(\.isTabActive) private var isTabActive
    @StateObject private var viewModel = AthletesViewModel()
    let undoToast: UndoToastCoordinator
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var selectedAthlete: Athlete?

    private var filteredAthletes: [Athlete] {
        viewModel.athletes.filter {
            searchText.isEmpty || $0.fullName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                ZStack {
                    AppBackground(color: FeatureColors.athletes)
                    content
                }
                .navigationBarTitleDisplayMode(.inline)
            }

            AddButton(color: FeatureColors.athletes) {
                showingAddSheet = true
            }
            .padding(26)
        }
        .task(id: isTabActive) {
            guard isTabActive else { return }
            await viewModel.loadAthletes()
        }
        .sheet(isPresented: $showingAddSheet) {
            AthleteFormView(title: "New Athlete", buttonTitle: "Add") { name, age, level in
                await viewModel.addAthlete(fullName: name, age: age, level: level)
            }
        }
        .sheet(item: $selectedAthlete) { athlete in
            AthleteFormView(title: "Edit Athlete", buttonTitle: "Save", athlete: athlete) { name, age, level in
                await viewModel.updateAthlete(athlete: athlete, fullName: name, age: age, level: level)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.athletes.isEmpty {
            LoadingView()
        } else if let error = viewModel.errorMessage, viewModel.athletes.isEmpty {
            ErrorView(message: error) {
                Task { await viewModel.loadAthletes() }
            }
        } else {
            List {
                Section {
                    VStack(spacing: 18) {
                        FeatureHeader(
                            title: "Athletes",
                            subtitle: "\(filteredAthletes.count) registered athletes",
                            icon: "figure.gymnastics",
                            color: FeatureColors.athletes
                        )
                        GlassSearchBar(text: $searchText, color: FeatureColors.athletes)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                }

                if let error = viewModel.errorMessage {
                    Section {
                        errorBanner(error) { viewModel.errorMessage = nil }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }

                if filteredAthletes.isEmpty {
                    ContentUnavailableView(
                        "No Athletes",
                        systemImage: "figure.gymnastics",
                        description: Text(searchText.isEmpty ? "Add your first athlete." : "Try a different search.")
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredAthletes) { athlete in
                        NavigationLink {
                            AthleteDetailView(athlete: athlete)
                        } label: {
                            AthleteRow(athlete: athlete)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                selectedAthlete = athlete
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(FeatureColors.athletes)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                undoToast.schedule(label: "Delete \(athlete.fullName)?") {
                                    await viewModel.deleteAthlete(athlete)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button {
                                selectedAthlete = athlete
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                undoToast.schedule(label: "Delete \(athlete.fullName)?") {
                                    await viewModel.deleteAthlete(athlete)
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
            .refreshable { await viewModel.loadAthletes() }
        }
    }
}

@ViewBuilder
private func errorBanner(_ message: String, dismiss: @escaping () -> Void) -> some View {
    HStack(alignment: .top, spacing: 10) {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundStyle(.red)
        Text(message)
            .font(.footnote)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
        Spacer(minLength: 4)
        Button(action: dismiss) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Dismiss error")
    }
    .padding(.vertical, 4)
}
