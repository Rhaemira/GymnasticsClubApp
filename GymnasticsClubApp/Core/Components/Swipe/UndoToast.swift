//
//  UndoToast.swift
//  GymnasticsClubApp
//
//  Created by Amirali Yazdani on 7/19/26.
//

import SwiftUI
import Combine

// MARK: - Coordinator

final class UndoToastCoordinator: ObservableObject {

    @Published var label: String = ""
    @Published var isVisible: Bool = false
    @Published var progress: Double = 1.0
    @Published var secondsLeft: Int = 4

    private let duration: Double = 4.0
    private var action: (() async -> Void)?
    private var commitTask: Task<Void, Never>?

    func schedule(label: String, action: @escaping () async -> Void) {
        flush()

        self.label       = label
        self.action      = action
        self.progress    = 1.0
        self.secondsLeft = Int(duration)

        withAnimation(.linear(duration: duration)) {
            self.progress = 0.0
        }

        isVisible = true

        commitTask = Task { [weak self] in
            guard let self else { return }
            for remaining in stride(from: Int(duration) - 1, through: 0, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run { self.secondsLeft = remaining }
            }
            guard !Task.isCancelled else { return }
            await MainActor.run { self.flush() }
        }
    }

    func undo() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        commitTask?.cancel()
        commitTask = nil
        action     = nil
        dismiss()
    }

    private func flush() {
        commitTask?.cancel()
        commitTask = nil
        let pending = action
        action = nil
        dismiss()
        guard let pending else { return }
        Task { await pending() }
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

            // Countdown ring with digit inside
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

            // Hairline separator
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

        }
        .padding(.leading, 14)
        .padding(.trailing, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(.primary.opacity(0.07), lineWidth: 1)
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
                            removal:   .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                    .zIndex(99)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: coordinator.isVisible)
    }

}
