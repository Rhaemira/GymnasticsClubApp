//
//  SwipeCard.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/19/26.
//

import SwiftUI

struct SwipeCard<Content: View>: View {

    let id: UUID

    @Binding
    var openCardID: UUID?

    var color: Color = .blue

    let onEdit: () -> Void
    let onDelete: () -> Void
    let content: Content

    // Width each action button occupies when the card is snapped open
    private let revealWidth: CGFloat = 86

    // Predicted-velocity threshold that commits a full-swipe action
    private let fullSwipeThreshold: CGFloat = 180

    // Committed offset (snapped position)
    @State private var offset: CGFloat = 0

    // Whether we've crossed the full-swipe threshold mid-drag
    @State private var didCrossFullSwipe = false

    // Live finger translation while the gesture is active
    @GestureState private var dragTranslation: CGFloat = 0

    // Icon bounce triggers
    @State private var editIconBounce   = false
    @State private var deleteIconBounce = false

    init(
        id: UUID,
        openCardID: Binding<UUID?>,
        color: Color = .blue,
        onEdit: @escaping () -> Void = {},
        onDelete: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.id          = id
        self._openCardID = openCardID
        self.color       = color
        self.onEdit      = onEdit
        self.onDelete    = onDelete
        self.content     = content()
    }

    // Total visible displacement right now
    private var currentOffset: CGFloat { offset + dragTranslation }

    // Progress [0…1] into the edit reveal (positive swipe)
    private var editProgress: CGFloat {
        guard currentOffset > 0 else { return 0 }
        return min(currentOffset / revealWidth, 1)
    }

    // Progress [0…1] into the delete reveal (negative swipe)
    private var deleteProgress: CGFloat {
        guard currentOffset < 0 else { return 0 }
        return min(-currentOffset / revealWidth, 1)
    }

    var body: some View {
        ZStack {
            // Action buttons — rendered first so the moving card sits on top
            HStack(spacing: 0) {
                editButton
                Spacer(minLength: 0)
                deleteButton
            }

            // The card itself — offset so it slides and exposes the buttons
            movingCard
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

}

// MARK: - Moving Card

private extension SwipeCard {

    var movingCard: some View {
        ZStack {
            // The actual row content
            content

            // Tap-to-close dimmer — only present when open.
            // Lives *inside* the card's own ZStack so it moves with the card
            // offset and never sits over the revealed action buttons.
            if offset != 0 {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { snapClosed() }
            }
        }
        .contentShape(Rectangle())
        .offset(x: currentOffset)
        .highPriorityGesture(dragGesture)
        .onChange(of: openCardID) { _, newValue in
            // Another card opened — snap this one shut
            if newValue != id, offset != 0 {
                withAnimation(.snappy(duration: 0.28)) { offset = 0 }
            }
        }
    }

}

// MARK: - Gesture

private extension SwipeCard {

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($dragTranslation) { value, state, _ in
                state = rubberBand(value.translation.width)

                // Fire a "click" haptic the moment the finger crosses the
                // full-swipe threshold — exactly once per stroke
                let predicted = value.predictedEndTranslation.width
                let crossed   = abs(predicted) > fullSwipeThreshold
                if crossed && !didCrossFullSwipe {
                    DispatchQueue.main.async {
                        UIImpactFeedbackGenerator(style: .rigid)
                            .impactOccurred(intensity: 0.9)
                        didCrossFullSwipe = true
                    }
                } else if !crossed && didCrossFullSwipe {
                    DispatchQueue.main.async { didCrossFullSwipe = false }
                }
            }
            .onEnded { value in
                didCrossFullSwipe = false
                finishDrag(value)
            }
    }

}

// MARK: - Action Buttons

private extension SwipeCard {

    var editButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            snapClosed()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onEdit() }
        } label: {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(color.opacity(0.22))

                VStack(spacing: 5) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 22, weight: .semibold))
                        .symbolEffect(.bounce, value: editIconBounce)
                        .scaleEffect(0.7 + 0.3 * editProgress)

                    Text("Edit")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .opacity(editProgress)
                }
                .foregroundStyle(color)
            }
            .frame(width: revealWidth)
            .frame(maxHeight: .infinity)
        }
        .opacity(editProgress)
        .onChange(of: editProgress) { _, new in
            if new >= 1 && !editIconBounce  { editIconBounce = true  }
            if new < 0.5                    { editIconBounce = false }
        }
    }

    var deleteButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            snapClosed()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onDelete() }
        } label: {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(Color.red.opacity(0.22))

                VStack(spacing: 5) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .symbolEffect(.bounce, value: deleteIconBounce)
                        .scaleEffect(0.7 + 0.3 * deleteProgress)
                        .rotationEffect(.degrees(deleteProgress * -12))

                    Text("Delete")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .opacity(deleteProgress)
                }
                .foregroundStyle(.red)
            }
            .frame(width: revealWidth)
            .frame(maxHeight: .infinity)
        }
        .opacity(deleteProgress)
        .onChange(of: deleteProgress) { _, new in
            if new >= 1 && !deleteIconBounce { deleteIconBounce = true  }
            if new < 0.5                     { deleteIconBounce = false }
        }
    }

}

// MARK: - Physics

private extension SwipeCard {

    func finishDrag(_ value: DragGesture.Value) {
        let drag      = value.translation.width
        let predicted = value.predictedEndTranslation.width

        // ── Full swipe right → commit Edit ──────────────────────────────
        if predicted > fullSwipeThreshold {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                offset = 500
            }
            Task {
                try? await Task.sleep(for: .milliseconds(220))
                withAnimation(.spring(response: 0.30, dampingFraction: 0.85)) {
                    offset     = 0
                    openCardID = nil
                }
                onEdit()
            }
            return
        }

        // ── Full swipe left → commit Delete ─────────────────────────────
        if predicted < -fullSwipeThreshold {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                offset = -500
            }
            Task {
                try? await Task.sleep(for: .milliseconds(220))
                withAnimation(.spring(response: 0.30, dampingFraction: 0.85)) {
                    offset     = 0
                    openCardID = nil
                }
                onDelete()
            }
            return
        }

        withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
            if drag > 40 {
                if offset == 0 { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                openCardID = id
                offset     = revealWidth
            } else if drag < -40 {
                if offset == 0 { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                openCardID = id
                offset     = -revealWidth
            } else {
                snapClosed()
            }
        }
    }

    func snapClosed() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            offset     = 0
            openCardID = nil
        }
    }

    /// Apple-style rubber band: 1:1 tracking inside the reveal zone,
    /// logarithmic resistance beyond it.
    func rubberBand(_ delta: CGFloat) -> CGFloat {
        let base  = offset + delta
        let sign  = base < 0 ? -1.0 : 1.0
        let limit = revealWidth * 1.6

        if abs(base) <= revealWidth {
            return delta
        } else {
            let overflow = abs(base) - revealWidth
            let dampened = revealWidth + log1p(overflow) * 18
            let clamped  = min(dampened, limit)
            return (clamped * sign) - offset
        }
    }

}
