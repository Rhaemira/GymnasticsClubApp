//
//  AttendanceByClassChart.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/18/26.
//

import SwiftUI
import Charts

struct AttendanceByClassChart: View {

    let attendance: [Attendance]

    private struct ClassCount: Identifiable {
        let id = UUID()
        let className: String
        let count: Int
    }

    private var classCounts: [ClassCount] {
        var tally: [String: Int] = [:]
        for record in attendance {
            tally[record.gymClass.name, default: 0] += 1
        }
        return tally
            .map { ClassCount(className: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private let palette: [Color] = [
        FeatureColors.athletes,
        FeatureColors.classes,
        FeatureColors.coaches,
        FeatureColors.attendance,
        FeatureColors.dashboard
    ]

    private func color(for index: Int) -> Color {
        palette[index % palette.count]
    }

    @State private var animate = false

    // Raw angle value from chartAngleSelection — nil when nothing is selected
    @State private var selectedAngle: Double?

    // Derive which class name the selected angle falls into
    private var selectedClass: String? {
        guard let angle = selectedAngle else { return nil }
        let total = Double(classCounts.reduce(0) { $0 + $1.count })
        guard total > 0 else { return nil }
        var cumulative = 0.0
        for item in classCounts {
            cumulative += Double(item.count) / total * 360
            if angle <= cumulative { return item.className }
        }
        return nil
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack {

                VStack(alignment: .leading) {

                    Text("Attendance by Class")
                        .font(.title2.bold())

                    Text(selectedClass ?? "Tap a slice")
                        .foregroundStyle(.secondary)
                        .animation(.default, value: selectedClass)

                }

                Spacer()

                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.secondary)

            }

            if classCounts.isEmpty {

                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 280)

            } else {

                Chart(Array(classCounts.enumerated()), id: \.element.id) { index, item in

                    SectorMark(
                        angle: .value("Sessions", animate ? Double(item.count) : 0),
                        innerRadius: .ratio(0.58),
                        angularInset: 3
                    )
                    .foregroundStyle(color(for: index).gradient)
                    .opacity(
                        selectedClass == nil || selectedClass == item.className
                        ? 1 : 0.3
                    )
                    .cornerRadius(6)

                }
                .frame(height: 260)
                // This is the correct API for tapping pie slices —
                // binds to the cumulative angle value under the finger
                .chartAngleSelection(value: $selectedAngle)
                .chartBackground { _ in
                    // Count label in the donut hole
                    if let name = selectedClass,
                       let item = classCounts.first(where: { $0.className == name }) {
                        VStack(spacing: 2) {
                            Text("\(item.count)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            Text("sessions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3), value: selectedClass)
                    }
                }

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {

                    ForEach(Array(classCounts.enumerated()), id: \.element.id) { index, item in

                        Button {
                            withAnimation(.spring()) {
                                // Tapping a legend row toggles selection
                                if selectedClass == item.className {
                                    selectedAngle = nil
                                } else {
                                    // Compute the midpoint angle of this slice
                                    let total = Double(classCounts.reduce(0) { $0 + $1.count })
                                    var cumulative = 0.0
                                    for c in classCounts {
                                        let slice = Double(c.count) / total * 360
                                        if c.className == item.className {
                                            selectedAngle = cumulative + slice / 2
                                            break
                                        }
                                        cumulative += slice
                                    }
                                }
                            }
                        } label: {

                            HStack {
                                Circle()
                                    .fill(color(for: index))
                                    .frame(width: 10, height: 10)
                                Text(item.className)
                                    .lineLimit(1)
                                Spacer()
                                Text("\(item.count)")
                                    .bold()
                                    .foregroundStyle(
                                        selectedClass == item.className
                                        ? color(for: index) : .primary
                                    )
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(
                                        selectedClass == item.className
                                        ? color(for: index).opacity(0.12) : .clear
                                    )
                            )

                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.3), value: selectedClass)

                    }

                }

            }

        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
        .padding(.horizontal)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animate = true
            }
        }

    }

}

#Preview {
    AttendanceByClassChart(attendance: [])
}
