import SwiftUI

struct ClassRow: View {
    let gymClass: GymClass

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "figure.flexibility")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(FeatureColors.classes.gradient)
                .frame(width: 60, height: 60)
                .background(FeatureColors.classes.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 8) {
                Text(gymClass.name)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)

                HStack(spacing: 14) {
                    Label("Capacity \(gymClass.capacity)", systemImage: "person.2.fill")
                    Label(gymClass.coach.fullName, systemImage: "person.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
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
                .stroke(FeatureColors.classes.opacity(0.14), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ClassRow(
        gymClass: GymClass(
            id: UUID(),
            name: "Artistic Gymnastics",
            capacity: 20,
            coach: CoachReference(id: UUID(), fullName: "Coach Name")
        )
    )
}
