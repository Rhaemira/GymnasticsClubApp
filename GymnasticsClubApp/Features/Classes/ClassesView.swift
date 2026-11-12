import SwiftUI

struct ClassesView: View {
    @MainActor
    init(undoToast: UndoToastCoordinator = UndoToastCoordinator()) {
        self.undoToast = undoToast
    }

    @Environment(\.isTabActive) private var isTabActive
    @StateObject private var viewModel = ClassesViewModel()
    let undoToast: UndoToastCoordinator
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var selectedClass: GymClass?

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
                    AppBackground(color: FeatureColors.classes)
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

            AddButton(color: FeatureColors.classes) {
                showingAddSheet = true
            }
            .padding(26)
        }
        .task(id: isTabActive) {
            guard isTabActive else { return }
            await viewModel.loadClasses()
        }
        .sheet(isPresented: $showingAddSheet) {
            ClassFormView(title: "New Class", buttonTitle: "Add", coaches: viewModel.coaches) { name, coach, capacity in
                await viewModel.addClass(name: name, capacity: capacity, coachID: coach.id)
            }
        }
        .sheet(item: $selectedClass) { gymClass in
            ClassFormView(title: "Edit Class", buttonTitle: "Save", gymClass: gymClass, coaches: viewModel.coaches) { name, coach, capacity in
                await viewModel.updateClass(gymClass: gymClass, name: name, capacity: capacity, coachID: coach.id)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.classes.isEmpty {
            LoadingView()
        } else if let error = viewModel.errorMessage, viewModel.classes.isEmpty {
            ErrorView(message: error) {
                Task { await viewModel.loadClasses() }
            }
        } else {
            List {
                Section {
                    VStack(spacing: 18) {
                        FeatureHeader(
                            title: "Classes",
                            subtitle: "\(filteredClasses.count) active classes",
                            icon: "figure.flexibility",
                            color: FeatureColors.classes
                        )
                        GlassSearchBar(text: $searchText, color: FeatureColors.classes)
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

                if filteredClasses.isEmpty {
                    ContentUnavailableView(
                        "No Classes",
                        systemImage: "figure.flexibility",
                        description: Text(searchText.isEmpty ? "Create your first class." : "Try a different search.")
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredClasses) { gymClass in
                        NavigationLink {
                            ClassDetailView(gymClass: gymClass)
                        } label: {
                            ClassRow(gymClass: gymClass)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                selectedClass = gymClass
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(FeatureColors.classes)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                undoToast.schedule(label: "Delete \(gymClass.name)?") {
                                    await viewModel.deleteClass(gymClass)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button {
                                selectedClass = gymClass
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                undoToast.schedule(label: "Delete \(gymClass.name)?") {
                                    await viewModel.deleteClass(gymClass)
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
            .refreshable { await viewModel.loadClasses() }
        }
    }
}
