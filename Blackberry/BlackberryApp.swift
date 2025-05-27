import SwiftUI
import FirebaseCore

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Main App Entry
@main
struct BlackberryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            } else {
                SplashScreen()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .onAppear {
                        // Optional: Check persisted auth state here
                        // e.g. isLoggedIn = Auth.auth().currentUser != nil
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserDidLogIn"))) { _ in
                        isLoggedIn = true
                    }
            }
        }
    }
}
