import SwiftUI

struct AttendanceRow: View {
    let attendance: Attendance

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(FeatureColors.attendance.gradient)
                .frame(width: 60, height: 60)
                .background(FeatureColors.attendance.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 7) {
                Text(attendance.athlete.fullName)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)

                Label(attendance.gymClass.name, systemImage: "figure.flexibility")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Label(attendance.attendedOn.attendanceLabel, systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(FeatureColors.attendance.opacity(0.14), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AttendanceRow(
        attendance: Attendance(
            id: UUID(),
            athlete: AttendanceAthlete(id: UUID(), fullName: "Arya Stark"),
            gymClass: AttendanceClass(id: UUID(), name: "Floor Training"),
            attendedOn: .now
        )
    )
}
