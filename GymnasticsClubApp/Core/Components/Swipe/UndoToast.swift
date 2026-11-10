//
//  UndoToast.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/19/26.
//

import SwiftUI
import Combine

// MARK: - Coordinator

@MainActor
final class UndoToastCoordinator: ObservableObject {
    @Published private(set) var label: String = ""
    @Published private(set) var isVisible = false
    @Published private(set) var progress: Double = 1.0
    @Published private(set) var secondsLeft = 4

    private struct PendingDeletion {
        let id: UUID
        let label: String
        let action: () async -> Void
    }

    private let duration: Double = 4.0
    private var queue: [PendingDeletion] = []
    private var active: PendingDeletion?
    private var commitTask: Task<Void, Never>?

    /// Queues deletions instead of flushing the previous one. Every item gets
    /// its own complete undo window before its server operation is committed.
    func schedule(label: String, action: @escaping () async -> Void) {
        queue.append(PendingDeletion(id: UUID(), label: label, action: action))
        guard active == nil else { return }
        presentNext()
    }

    func undo() {
        guard active != nil else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        commitTask?.cancel()
        commitTask = nil
        active = nil
        dismiss()
        presentNext()
    }

    private func presentNext() {
        guard active == nil, !queue.isEmpty else { return }
        let pending = queue.removeFirst()
        active = pending
        label = pending.label
        secondsLeft = Int(duration)
        progress = 1
        isVisible = true

        withAnimation(.linear(duration: duration)) {
            progress = 0
        }

        commitTask = Task { [weak self] in
            for remaining in stride(from: Int(self.duration) - 1, through: 0, by: -1) {
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    return
                }

                guard let self, self.active?.id == pending.id else { return }
                self.secondsLeft = remaining
            }

            guard let self, self.active?.id == pending.id else { return }
            self.commitTask = nil
            self.active = nil
            self.dismiss()

            await pending.action()
            self.presentNext()
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isVisible = false
        }
    }
}

// MARK: - View

struct UndoToastView: View {
    @ObservedObject var coordinator: UndoToastCoordinator

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(.primary.opacity(0.1), lineWidth: 2.5)
                Circle()
                    .trim(from: 0, to: coordinator.progress)
                    .stroke(
                        .primary.opacity(0.55),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(coordinator.secondsLeft)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary.opacity(0.6))
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: coordinator.secondsLeft)
            }
            .frame(width: 28, height: 28)

            Text(coordinator.label)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer()

            Rectangle()
                .fill(.primary.opacity(0.12))
                .frame(width: 1, height: 20)
                .padding(.horizontal, 2)

            Button {
                coordinator.undo()
            } label: {
                Text("Undo")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Cancels the pending deletion")
        }
        .padding(.leading, 14)
        .padding(.trailing, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(.primary.opacity(0.07), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.12), radius: 20, y: 6)
        .padding(.horizontal, 24)
        .padding(.bottom, 104)
    }
}

// MARK: - Modifier

extension View {
    func undoToast(_ coordinator: UndoToastCoordinator) -> some View {
        ZStack(alignment: .bottom) {
            self
            if coordinator.isVisible {
                UndoToastView(coordinator: coordinator)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9, anchor: .bottom)),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                    .zIndex(99)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: coordinator.isVisible)
    }
}
