import SwiftUI
import CoreData
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @AppStorage("preferredColorScheme") private var preferredColorScheme: Int = 0
    @AppStorage("isProUser") private var isProUser: Bool = false
    @AppStorage("selectedTheme") private var selectedTheme: String = AppTheme.glow.rawValue
    @AppStorage("billingEnabled") private var isBillingEnabled: Bool = false

    @FetchRequest(
        entity: JobData.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \JobData.nameJob, ascending: true)],
        animation: .default
    ) private var jobsFetch: FetchedResults<JobData>

    @State private var savedJobs: [JobData] = []
    @State private var jobColors: [String: String] = [:]
    @State private var newJobName: String = ""
    @State private var showLogoutConfirmation = false
    @State private var username: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showTutorial = false

    var currentTheme: AppTheme {
        AppTheme(rawValue: selectedTheme) ?? .glow
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    profileSection
                    proStatusSection
                    billingToggleSection
                    themePickerSection
                    jobCategorySection
                    utilitiesSection
                }
                .padding(.vertical, 0)
            }
            .background(currentTheme.backgroundView)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadData)
            .confirmationDialog("Are you sure?", isPresented: $showLogoutConfirmation) {
                Button("Log Out", role: .destructive) { logout() }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
                    .onDisappear(perform: saveProfileImage)
            }
            .sheet(isPresented: $showTutorial) {
                SettingsTutorialView()
            }
        }
    }

    private var profileSection: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                profileImageView
                Spacer()
            }
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: username) {
                    UserDefaults.standard.set($0, forKey: "savedUsername")
                }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .padding(.horizontal)
    }

    private var proStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Tier")
                .font(AppFonts.heading)
            if isProUser {
                Text("✅ You are using Pro features.")
                    .font(AppFonts.body)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🔐 Pro features are locked.")
                        .font(AppFonts.body)
                    Button("Upgrade to Pro (for testing)") {
                        isProUser = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .padding(.horizontal)
    }

    private var billingToggleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isProUser {
                Toggle(isOn: $isBillingEnabled) {
                    Text("Enable Billing View")
                        .font(AppFonts.body)
                }
            } else {
                Text("🔒 Billing is a Pro feature")
                    .font(AppFonts.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .padding(.horizontal)
    }

    private var themePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Theme")
                .font(AppFonts.heading)

            if isProUser {
                Picker("App Theme", selection: $selectedTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme.rawValue)
                    }
                }
                .pickerStyle(.inline)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Custom themes")
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                    Text("Upgrade to Pro to unlock theme customization")
                        .font(AppFonts.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .padding(.horizontal)
    }

    private var jobCategorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Job Categories")
                .font(AppFonts.heading)
            JobCategoriesSectionView(
                savedJobs: $savedJobs,
                jobColors: $jobColors,
                newJobName: $newJobName,
                billingEnabled: $isBillingEnabled
            )
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .padding(.horizontal)
    }

    private var utilitiesSection: some View {
        VStack(spacing: 12) {
            if isProUser {
                ExportEntriesButton()
            } else {
                Text("🔒 Export is a Pro feature")
                    .foregroundColor(.secondary)
            }

            Button(action: { showTutorial = true }) {
                Label("Help & Tutorial", systemImage: "questionmark.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accent.opacity(0.2))
                    .foregroundColor(AppColors.primary)
                    .cornerRadius(10)
            }

            Button("Log Out", role: .destructive) {
                showLogoutConfirmation = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primary)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text("Version 1.0.0")
                .font(AppFonts.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .padding(.horizontal)
    }

    private var profileImageView: some View {
        Button { showImagePicker = true } label: {
            Group {
                if let img = profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "camera.fill")
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
        }
    }

    private func loadData() {
        username = UserDefaults.standard.string(forKey: "savedUsername") ?? ""
        savedJobs = Array(jobsFetch)
        jobColors = JobColors.shared.loadColorNames()

        let fileURL = getDocumentsDirectory().appendingPathComponent("profile.jpg")
        if let data = try? Data(contentsOf: fileURL),
           let img = UIImage(data: data) {
            profileImage = img
        }
    }

    private func logout() {
        try? Auth.auth().signOut()
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }

    private func saveProfileImage() {
        if let img = profileImage,
           let data = img.jpegData(compressionQuality: 0.8) {
            let fileURL = getDocumentsDirectory().appendingPathComponent("profile.jpg")
            try? data.write(to: fileURL)
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
