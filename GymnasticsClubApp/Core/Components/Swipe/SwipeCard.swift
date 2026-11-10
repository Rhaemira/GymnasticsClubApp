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

    @Environment(\.isTabActive) private var isTabActive

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
    @State private var actionInProgress = false
    @State private var actionTask: Task<Void, Never>?

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
        .onDisappear {
            actionTask?.cancel()
            actionTask = nil
            offset = 0
            actionInProgress = false
            if openCardID == id { openCardID = nil }
        }
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
        .simultaneousGesture(dragGesture)
        .onChange(of: openCardID) { _, newValue in
            if newValue != id, offset != 0 {
                withAnimation(.snappy(duration: 0.28)) { offset = 0 }
            }
        }
        .onChange(of: isTabActive) { _, active in
            guard !active else { return }
            actionTask?.cancel()
            actionTask = nil
            withAnimation(.snappy(duration: 0.24)) { offset = 0 }
            actionInProgress = false
            if openCardID == id { openCardID = nil }
        }
    }

}

// MARK: - Gesture

private extension SwipeCard {

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($dragTranslation) { value, state, _ in
                // Vertical movement belongs to the containing ScrollView.
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    state = 0
                    return
                }
                state = rubberBand(value.translation.width)

                let crossed = abs(value.predictedEndTranslation.width) > fullSwipeThreshold
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
                // Avoid stealing vertical scrolling and navigation taps.
                guard abs(value.translation.width) > abs(value.translation.height) * 1.2 else {
                    return
                }
                finishDrag(value)
            }
    }

}

// MARK: - Action Buttons

private extension SwipeCard {

    var editButton: some View {
        Button {
            guard !actionInProgress else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            snapClosed()
            runDelayedAction(onEdit)
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
            guard !actionInProgress else { return }
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            snapClosed()
            runDelayedAction(onDelete)
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
        guard !actionInProgress else { return }
        let drag      = value.translation.width
        let predicted = value.predictedEndTranslation.width

        // ── Full swipe right → commit Edit ──────────────────────────────
        if predicted > fullSwipeThreshold {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            runFullSwipe(direction: 1, action: onEdit)
            return
        }

        // ── Full swipe left → commit Delete ─────────────────────────────
        if predicted < -fullSwipeThreshold {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            runFullSwipe(direction: -1, action: onDelete)
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

    func runDelayedAction(_ action: @escaping () -> Void) {
        guard !actionInProgress else { return }
        actionInProgress = true
        actionTask?.cancel()
        actionTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(220))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            action()
            actionInProgress = false
            actionTask = nil
        }
    }

    func runFullSwipe(direction: CGFloat, action: @escaping () -> Void) {
        guard !actionInProgress else { return }
        actionInProgress = true
        actionTask?.cancel()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
            offset = direction * 500
        }
        actionTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(220))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.30, dampingFraction: 0.85)) {
                offset = 0
                openCardID = nil
            }
            action()
            actionInProgress = false
            actionTask = nil
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
