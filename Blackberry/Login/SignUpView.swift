import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Binding var isLoggedIn: Bool

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @State private var showSuccess: Bool = false
    @State private var showOnboarding: Bool = false

    var body: some View {
        ZStack {
            Color("Light Blue")
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primary)
                }
                .padding(.bottom, 30)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .font(AppFonts.body)

                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .font(AppFonts.body)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .font(AppFonts.body)
                }
                .padding(.horizontal)

                Button(action: signUp) {
                    Text("Sign Up")
                        .font(AppFonts.heading)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Button(action: {
                    dismiss()
                }) {
                    Text("Already have an account? Log In")
                        .font(AppFonts.sectionLabel)
                        .foregroundColor(AppColors.primary)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showOnboarding) {
            // ✅ Use external OnboardingFlowView here
            OnboardingFlowView(isLoggedIn: $isLoggedIn)
        }
    }

    private func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showError = true
            return
        }

        AuthManager.shared.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                showOnboarding = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

