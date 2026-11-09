//
//  RecentActivityCard.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/19/26.
//


//
//  RecentActivityCard.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/19/26.
//

import SwiftUI

struct RecentActivityCard: View {

    let attendance: [Attendance]

    // Five most recent records, newest first
    private var recent: [Attendance] {
        attendance
            .sorted { $0.attendedOn > $1.attendedOn }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack {

                Text("Recent Activity")
                    .font(.title2.bold())

                Spacer()

                Image(systemName: "clock.fill")
                    .foregroundStyle(.secondary)

            }

            if recent.isEmpty {

                HStack {
                    Spacer()
                    Text("No activity yet")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 20)
                    Spacer()
                }

            } else {

                VStack(spacing: 0) {

                    ForEach(Array(recent.enumerated()), id: \.element.id) { index, record in

                        HStack(spacing: 14) {

                            // Coloured dot on a vertical timeline
                            VStack(spacing: 0) {

                                Circle()
                                    .fill(FeatureColors.attendance.gradient)
                                    .frame(width: 10, height: 10)

                                if index < recent.count - 1 {
                                    Rectangle()
                                        .fill(.primary.opacity(0.08))
                                        .frame(width: 1.5)
                                }

                            }
                            .frame(width: 10)

                            VStack(alignment: .leading, spacing: 3) {

                                Text(record.athlete.fullName)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                                Text(record.gymClass.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                            }

                            Spacer()

                            Text(record.attendedOn.attendanceLabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                        }
                        .padding(.vertical, 10)

                    }

                }

            }

        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
        .padding(.horizontal)

    }

}

#Preview {
    RecentActivityCard(attendance: [])
}