//
//  AttendanceStatsCard.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//

import SwiftUI

struct AttendanceStatsCard: View {

    let attendance: [Attendance]

    @State private var displayedTotal = 0
    @State private var appeared = false

    // Use dateInterval(of:for:) — returns the exact start/end of the
    // period in the device's current calendar and timezone, so comparisons
    // are always correct regardless of how the server stores dates.

    private var todayCount: Int {
        guard let interval = Calendar.current.dateInterval(of: .day, for: .now) else { return 0 }
        return attendance.filter { interval.contains($0.attendedOn) }.count
    }

    private var weekCount: Int {
        guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: .now) else { return 0 }
        return attendance.filter { interval.contains($0.attendedOn) }.count
    }

    private var monthCount: Int {
        guard let interval = Calendar.current.dateInterval(of: .month, for: .now) else { return 0 }
        return attendance.filter { interval.contains($0.attendedOn) }.count
    }

    var body: some View {

        VStack(spacing: 26) {

            ZStack {

                Circle()
                    .fill(FeatureColors.attendance.opacity(0.18))
                    .frame(width: 82, height: 82)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(FeatureColors.attendance.gradient)
                    .symbolEffect(.bounce.byLayer, value: displayedTotal)

            }

            VStack(spacing: 6) {

                Text("\(displayedTotal)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Text("Attendance Records")
                    .font(.headline)
                    .foregroundStyle(.secondary)

            }

            Divider()

            VStack(spacing: 18) {

                statRow(title: "Today",      value: todayCount)
                statRow(title: "This Week",  value: weekCount)
                statRow(title: "This Month", value: monthCount)

            }

        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            LinearGradient(
                colors: [.white.opacity(0.20), .white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
        .padding(.horizontal)
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.82), value: appeared)
        .onAppear {
            appeared = true
            animateCounter()
        }
        .onChange(of: attendance.count) {
            animateCounter()
        }

    }

    @ViewBuilder
    private func statRow(title: String, value: Int) -> some View {

        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(value)")
                .fontWeight(.bold)
        }

    }

    private func animateCounter() {

        displayedTotal = 0
        let target = attendance.count

        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in

            if displayedTotal >= target {
                timer.invalidate()
            } else {
                displayedTotal += max(1, target / 25)
                if displayedTotal > target {
                    displayedTotal = target
                }
            }

        }

    }

}

#Preview {
    AttendanceStatsCard(attendance: [])
}
