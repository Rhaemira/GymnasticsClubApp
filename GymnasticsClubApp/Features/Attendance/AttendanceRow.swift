//
//  AttendanceRow.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/15/26.
//


import SwiftUI

struct AttendanceRow: View {

    let attendance: Attendance

    @State
    private var appeared = false

    var body: some View {

        HStack(spacing: 18) {

            ZStack {

                Circle()

                    .fill(
                        FeatureColors.attendance.opacity(0.18)
                    )

                    .frame(width: 64, height: 64)

                Image(systemName: "checkmark.circle.fill")

                    .font(.system(size: 28))

                    .foregroundStyle(
                        FeatureColors.attendance.gradient
                    )

            }

            VStack(alignment: .leading, spacing: 10) {

                Text(attendance.athlete.fullName)

                    .font(
                        .system(
                            size: 21,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                Label(
                    attendance.gymClass.name,
                    systemImage: "figure.flexibility"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Label(
                    attendance.attendedOn.attendanceLabel,
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

            }

            Spacer()

            Image(systemName: "chevron.right")

                .font(.headline)

                .foregroundStyle(.tertiary)

        }

        .padding(22)

        .background(.ultraThinMaterial)

        .overlay {

            RoundedRectangle(
                cornerRadius: 24
            )

            .stroke(
                FeatureColors.attendance.opacity(0.15),
                lineWidth: 1
            )

        }

        .clipShape(

            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )

        )

        .shadow(
            color: .black.opacity(0.06),
            radius: 12,
            y: 6
        )

        .scaleEffect(
            appeared ? 1 : 0.94
        )

        .opacity(
            appeared ? 1 : 0
        )

        .animation(
            .spring(
                response: 0.55,
                dampingFraction: 0.82
            ),
            value: appeared
        )

        .onAppear {

            appeared = true

        }

    }

}

#Preview {

    AttendanceRow(

        attendance: Attendance(

            id: UUID(),

            athlete: AttendanceAthlete(

                id: UUID(),

                fullName: "Arya Stark"

            ),

            gymClass: AttendanceClass(

                id: UUID(),

                name: "Sword Training"

            ),

            attendedOn: .now

        )

    )

}
