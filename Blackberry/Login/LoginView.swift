import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var isLoggedIn: Bool
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSignUp: Bool = false

    var body: some View {
        ZStack {
            Color("Light Blue")
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .font(AppFonts.sectionTitle)
                        .foregroundColor(.gray)

                    Text("Tempo")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primary)
                }
                .padding(.bottom, 30)

                // Login Fields
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
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .font(AppFonts.body)
                }
                .padding(.horizontal)

                // Log In Button
                Button(action: login) {
                    Text("Log In")
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

                // Sign Up Button
                Button(action: { showSignUp = true }) {
                    Text("Don't have an account? Sign Up")
                        .font(AppFonts.sectionLabel)
                        .foregroundColor(AppColors.primary)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(isLoggedIn: $isLoggedIn)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func login() {
        AuthManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                isLoggedIn = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

