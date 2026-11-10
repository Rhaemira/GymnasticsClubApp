import SwiftUI
import Combine

@MainActor
final class EnrollmentManagementViewModel: ObservableObject {
    private let client: any APIClientProtocol

    init(client: (any APIClientProtocol)? = nil) {
        self.client = client ?? APIClient.shared
    }

    @Published private(set) var enrollments: [Enrollment] = []
    @Published private(set) var athletes: [Athlete] = []
    @Published private(set) var classes: [GymClass] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let e = client.get(.enrollments, as: [Enrollment].self)
            async let a = client.get(.athletes, as: [Athlete].self)
            async let c = client.get(.classes, as: [GymClass].self)
            enrollments = try await e
            athletes = try await a
            classes = try await c
        } catch { errorMessage = error.localizedDescription }
    }

    func enroll(athleteID: UUID, classID: UUID) async {
        do {
            try await client.post(.enrollments, body: CreateEnrollmentRequest(athleteID: athleteID, classID: classID))
            await load()
        } catch { errorMessage = error.localizedDescription }
    }

    func remove(_ enrollment: Enrollment) async {
        do {
            try await client.delete(.enrollments, id: enrollment.id)
            await load()
        } catch { errorMessage = error.localizedDescription }
    }

    func count(for classID: UUID) -> Int {
        enrollments.filter { $0.gymClass.id == classID }.count
    }
}

struct EnrollmentManagementView: View {
    @StateObject private var viewModel = EnrollmentManagementViewModel()
    @State private var selectedAthleteID: UUID?
    @State private var selectedClassID: UUID?
    @State private var isSubmitting = false

    private var selectedClassIsFull: Bool {
        guard let selectedClassID,
              let gymClass = viewModel.classes.first(where: { $0.id == selectedClassID }) else {
            return false
        }
        return viewModel.count(for: gymClass.id) >= gymClass.capacity
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.classes.isEmpty {
                ProgressView("Loading enrollments…")
            } else if let error = viewModel.errorMessage, viewModel.classes.isEmpty {
                ContentUnavailableView("Could not load enrollments", systemImage: "person.2.badge.gearshape", description: Text(error))
            } else {
                List {
                    Section("New enrollment") {
                        Picker("Athlete", selection: $selectedAthleteID) {
                            Text("Choose an athlete").tag(UUID?.none)
                            ForEach(viewModel.athletes) { athlete in
                                Text(athlete.fullName).tag(Optional(athlete.id))
                            }
                        }
                        Picker("Class", selection: $selectedClassID) {
                            Text("Choose a class").tag(UUID?.none)
                            ForEach(viewModel.classes) { gymClass in
                                let count = viewModel.count(for: gymClass.id)
                                Text("\(gymClass.name) · \(max(gymClass.capacity - count, 0)) places left")
                                    .tag(Optional(gymClass.id))
                            }
                        }
                        Button {
                            guard let athleteID = selectedAthleteID, let classID = selectedClassID else { return }
                            Task {
                                isSubmitting = true
                                await viewModel.enroll(athleteID: athleteID, classID: classID)
                                isSubmitting = false
                            }
                        } label: {
                            if isSubmitting { ProgressView() } else { Label("Enroll athlete", systemImage: "plus.circle.fill") }
                        }
                        .disabled(isSubmitting || selectedAthleteID == nil || selectedClassID == nil || selectedClassIsFull)
                        if selectedClassIsFull {
                            Text("This class is full. Choose another class or remove an existing enrollment.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section("Class capacity") {
                        ForEach(viewModel.classes) { gymClass in
                            let enrolled = viewModel.count(for: gymClass.id)
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(gymClass.name).fontWeight(.medium)
                                    Spacer()
                                    Text("\(enrolled) / \(gymClass.capacity)")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                ProgressView(value: gymClass.capacity > 0 ? min(Double(enrolled) / Double(gymClass.capacity), 1) : 0)
                                    .tint(enrolled >= gymClass.capacity ? .orange : FeatureColors.classes)
                            }
                        }
                    }

                    Section("Current enrollments") {
                        if viewModel.enrollments.isEmpty {
                            ContentUnavailableView("No enrollments", systemImage: "person.2")
                        } else {
                            ForEach(viewModel.enrollments) { enrollment in
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(enrollment.athlete.fullName).fontWeight(.medium)
                                        Text(enrollment.gymClass.name).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button(role: .destructive) {
                                        guard !isSubmitting else { return }
                                        Task {
                                            isSubmitting = true
                                            await viewModel.remove(enrollment)
                                            isSubmitting = false
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle")
                                    }
                                    .accessibilityLabel("Remove enrollment")
                                    .disabled(isSubmitting)
                                }
                            }
                        }
                    }
                }
                .refreshable { await viewModel.load() }
            }
        }
        .navigationTitle("Enrollments")
        .task { await viewModel.load() }
        .alert("Enrollment error", isPresented: Binding(
            get: { viewModel.errorMessage != nil && !viewModel.classes.isEmpty },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
