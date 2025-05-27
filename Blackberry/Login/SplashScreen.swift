import SwiftUI

struct SplashScreen: View {
    @State private var isLoggedIn: Bool? = nil

    var body: some View {
        Group {
            if let isLoggedIn = isLoggedIn {
                if isLoggedIn {
                    MainTabView()
                } else {
                    LoginView(isLoggedIn: Binding(
                        get: { self.isLoggedIn ?? false },
                        set: { self.isLoggedIn = $0 }
                    ))
                }
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.4)

                    Text("Checking account...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.1).ignoresSafeArea())
            }
        }
        .onAppear {
            checkLoginStatus()
        }
    }

    private func checkLoginStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isLoggedIn = AuthManager.shared.isLoggedIn
        }
    }
}

