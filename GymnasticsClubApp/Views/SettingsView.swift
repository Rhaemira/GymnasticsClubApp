import SwiftUI

struct SettingsView: View {
    @StateObject private var session = AuthSession.shared
    @State private var confirmingSignOut = false

    var body: some View {
        Form {
            Section("Account") {
                LabeledContent("Signed in as", value: session.user?.email ?? "Administrator")
                Button("Sign Out", role: .destructive) { confirmingSignOut = true }
            }
            Section("Connection") {
                LabeledContent("API endpoint", value: Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "Not configured")
                Text("Production builds must use HTTPS. For a physical iPhone during development, configure the API URL to the Mac's reachable LAN address and use a trusted HTTPS certificate.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("About") {
                LabeledContent("Application", value: "Gymnastics Club")
                LabeledContent("Authentication", value: "Administrator session")
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Sign out of Gymnastics Club?", isPresented: $confirmingSignOut, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) { Task { await session.signOut() } }
            Button("Cancel", role: .cancel) {}
        }
    }
}
