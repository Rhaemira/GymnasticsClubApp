import SwiftUI

struct CoachRow: View {
    let coach: Coach

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(FeatureColors.coaches.gradient)
                .frame(width: 60, height: 60)
                .background(FeatureColors.coaches.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 7) {
                Text(coach.fullName)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)

                Label(coach.specialty, systemImage: "star.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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
                .stroke(FeatureColors.coaches.opacity(0.14), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CoachRow(
        coach: Coach(
            id: UUID(),
            fullName: "Daenerys Targaryen",
            specialty: "Floor Exercise"
        )
    )
}
