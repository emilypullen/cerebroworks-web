import SwiftUI

struct SettingsTutorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var expandedSection: String? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Settings Guide")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.secondary)

                    tutorialSection(
                        id: "profile",
                        title: "Profile",
                        bullets: [
                            "Set your display name",
                            "Tap image to upload a photo",
                            "Changes are saved automatically"
                        ],
                        detail: "The Profile section allows you to personalise your experience. You can change your username and profile picture. Your username is stored locally and used across your entries."
                    )

                    tutorialSection(
                        id: "account",
                        title: "Account Tier",
                        bullets: [
                            "Free access includes core features",
                            "Upgrade to Pro for billing and export",
                            "Tap 'Upgrade' to simulate Pro status"
                        ],
                        detail: "Pro users unlock additional functionality like exporting work logs, billing toggles, and advanced analytics. This status is saved using AppStorage."
                    )

                    tutorialSection(
                        id: "billing",
                        title: "Billing View",
                        bullets: [
                            "Track income per job",
                            "Enable via toggle",
                            "Rates managed per job"
                        ],
                        detail: "When Billing View is enabled, each job entry allows you to assign hourly rates and calculate estimated earnings. This is especially helpful for freelancers or hourly workers."
                    )

                    tutorialSection(
                        id: "jobs",
                        title: "Job Categories",
                        bullets: [
                            "Add and name jobs",
                            "Assign colours",
                            "Jobs appear across all tabs"
                        ],
                        detail: "This section lets you define the types of work you want to track. You can add jobs with distinct colours and optional billing information. These jobs populate across the Home, Entry, and Analytics views."
                    )

                    tutorialSection(
                        id: "appearance",
                        title: "Appearance",
                        bullets: [
                            "Choose light, dark, or system",
                            "Applies across the whole app"
                        ],
                        detail: "You can select your preferred interface theme to match your device settings or personal comfort. The change is applied immediately."
                    )

                    tutorialSection(
                        id: "data",
                        title: "Data Management",
                        bullets: [
                            "Export entries to PDF",
                            "Clear all stored jobs & tasks"
                        ],
                        detail: "Pro users can export their entry logs to a PDF. The Clear Data option removes all Core Data entries and resets the app's local state. Use this with caution."
                    )

                    tutorialSection(
                        id: "logout",
                        title: "Logout",
                        bullets: [
                            "Sign out securely",
                            "Return to login screen"
                        ],
                        detail: "The logout button signs you out of your Firebase account and resets the login status. You will be redirected to the login page."
                    )

                    Spacer(minLength: 32)
                }
                .padding()
            }
            .navigationTitle("Help & Tutorial")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func tutorialSection(id: String, title: String, bullets: [String], detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.heading)

            ForEach(bullets, id: \.self) { bullet in
                Text("• \(bullet)")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.secondary)
                    .padding(.leading)
            }

            Button(action: {
                withAnimation {
                    expandedSection = (expandedSection == id ? nil : id)
                }
            }) {
                Text(expandedSection == id ? "Hide details" : "Read more")
                    .font(AppFonts.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }

            if expandedSection == id {
                Text(detail)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
