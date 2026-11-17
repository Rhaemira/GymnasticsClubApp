import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading analytics…")
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Analytics unavailable", systemImage: "chart.xyaxis.line")
                } description: {
                    Text(error)
                } actions: {
                    Button("Retry") { Task { await viewModel.load() } }
                }
            } else if let data = viewModel.analytics {
                analyticsContent(data)
            } else {
                ContentUnavailableView("No analytics", systemImage: "chart.bar")
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func analyticsContent(_ data: AnalyticsResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    metric("Athletes", data.overview.athletes, .blue)
                    metric("Coaches", data.overview.coaches, .green)
                    metric("Classes", data.overview.classes, .orange)
                    metric("Enrollments", data.overview.enrollments, .indigo)
                    metric("Attendance", data.overview.attendance, .purple)
                }

                if !data.athleteLevels.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Athlete levels").font(.headline)
                        Chart(data.athleteLevels) { item in
                            BarMark(x: .value("Athletes", item.count), y: .value("Level", item.level))
                                .foregroundStyle(.blue.gradient)
                                .annotation(position: .trailing) { Text("\(item.count)").font(.caption).foregroundStyle(.secondary) }
                        }
                        .frame(height: max(150, CGFloat(data.athleteLevels.count) * 42))
                    }
                    .padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                }

                if !data.coachWorkload.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Coach workload").font(.headline)
                        Chart(data.coachWorkload) { item in
                            BarMark(x: .value("Classes", item.classes), y: .value("Coach", item.coach))
                                .foregroundStyle(.green.gradient)
                        }
                        .frame(height: max(150, CGFloat(data.coachWorkload.count) * 42))
                    }
                    .padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                }

                if !data.classUtilization.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Class capacity").font(.headline)
                        ForEach(data.classUtilization) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(item.className).font(.subheadline.weight(.medium))
                                    Spacer()
                                    Text("\(item.enrolled) / \(item.capacity)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                                }
                                ProgressView(value: item.capacity > 0 ? min(Double(item.enrolled) / Double(item.capacity), 1) : 0)
                                    .tint(item.enrolled >= item.capacity ? .orange : .indigo)
                            }
                        }
                    }
                    .padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding()
        }
    }

    private func metric(_ title: String, _ value: Int, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value.formatted()).font(.title2.bold().monospacedDigit()).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}
