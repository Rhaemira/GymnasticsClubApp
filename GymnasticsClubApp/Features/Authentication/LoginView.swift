import SwiftUI

struct LoginView: View {
    @ObservedObject var session: AuthSession
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "figure.gymnastics")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(FeatureColors.dashboard)
                VStack(spacing: 8) {
                    Text("Gymnastics Club").font(.largeTitle.bold())
                    Text("Sign in to manage your club").foregroundStyle(.secondary)
                }
                VStack(spacing: 14) {
                    TextField("Administrator email", text: $email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                }
                if let message = session.errorMessage {
                    Text(message).font(.footnote).foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button {
                    Task {
                        isSubmitting = true
                        _ = await session.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
                        isSubmitting = false
                    }
                } label: {
                    HStack {
                        if isSubmitting { ProgressView().tint(.white) }
                        Text("Sign In").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(FeatureColors.dashboard, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.white)
                }
                .disabled(isSubmitting || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)
            }
            .padding(28)
            .frame(maxWidth: 440)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppBackground(color: FeatureColors.dashboard))
        }
    }
}
