import XCTest
@testable import GymnasticsClubApp

@MainActor
final class UndoToastCoordinatorTests: XCTestCase {
    func testSchedulingAnotherDeletionDoesNotCommitTheFirstEarly() async throws {
        let coordinator = UndoToastCoordinator(duration: 0.6)
        var committed: [String] = []

        coordinator.schedule(label: "first") {
            committed.append("first")
        }
        coordinator.schedule(label: "second") {
            committed.append("second")
        }

        try await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(committed.isEmpty, "A second deletion must not flush the first one's undo window.")

        try await Task.sleep(for: .milliseconds(600))
        XCTAssertEqual(committed, ["first"])

        try await Task.sleep(for: .milliseconds(700))
        XCTAssertEqual(committed, ["first", "second"])
    }

    func testUndoCancelsCurrentDeletionAndPreservesNextUndoWindow() async throws {
        let coordinator = UndoToastCoordinator(duration: 0.4)
        var committed: [String] = []

        coordinator.schedule(label: "first") {
            committed.append("first")
        }
        coordinator.schedule(label: "second") {
            committed.append("second")
        }

        coordinator.undo()
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(committed.isEmpty, "Undo must cancel the active pending server operation.")

        try await Task.sleep(for: .milliseconds(450))
        XCTAssertEqual(committed, ["second"], "The next deletion must receive its own full undo interval.")
    }
}


extension UndoToastCoordinatorTests {
    func testNextUndoWindowWaitsForPreviousDeleteRequestToFinish() async throws {
        let coordinator = UndoToastCoordinator(duration: 0.1)
        var firstDeleteStarted = false
        var secondDeleteCommitted = false

        coordinator.schedule(label: "first") {
            firstDeleteStarted = true
            try? await Task.sleep(for: .milliseconds(400))
        }

        try await Task.sleep(for: .milliseconds(150))
        XCTAssertTrue(firstDeleteStarted)

        coordinator.schedule(label: "second") {
            secondDeleteCommitted = true
        }

        try await Task.sleep(for: .milliseconds(150))
        XCTAssertFalse(secondDeleteCommitted)
        XCTAssertEqual(coordinator.label, "first", "A queued deletion must not replace the in-flight operation.")

        try await Task.sleep(for: .milliseconds(300))
        XCTAssertEqual(coordinator.label, "second")
        XCTAssertTrue(coordinator.isVisible)

        try await Task.sleep(for: .milliseconds(150))
        XCTAssertTrue(secondDeleteCommitted)
    }
}
