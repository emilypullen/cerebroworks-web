import SwiftUI

struct OnboardingFlowView: View {
    @Binding var isLoggedIn: Bool

    @State private var step = 0
    @State private var wantsBilling = false
    @State private var jobType = ""
    @State private var jobCount = ""
    @State private var wantsToStartNow = false

    var body: some View {
        VStack(spacing: 24) {
            // Progress bar
            ProgressView(value: Double(step), total: 3)
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                .padding(.horizontal)

            Spacer()

            Group {
                switch step {
                case 0:
                    Text("What would you like to use this app for?")
                        .font(.title2.bold())
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Tracking work hours", isOn: .constant(true))
                        Toggle("Organizing tasks", isOn: .constant(true))
                        Toggle("Creating job-specific entries", isOn: .constant(true))
                        Toggle("Managing billing or invoicing", isOn: $wantsBilling)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))

                case 1:
                    Text("What kinds of jobs do you want to track?")
                        .font(.title2.bold())
                    TextField("e.g., Freelance, Research, Retail", text: $jobType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                case 2:
                    Text("How many jobs are you currently managing?")
                        .font(.title2.bold())
                    Picker("", selection: $jobCount) {
                        Text("Just one").tag("one")
                        Text("Two").tag("two")
                        Text("More than two").tag("many")
                    }
                    .pickerStyle(.segmented)

                case 3:
                    Text("Would you like to start by entering your first job now?")
                        .font(.title2.bold())
                    HStack(spacing: 20) {
                        Button("Skip") {
                            wantsToStartNow = false
                            finishOnboarding()
                        }
                        .buttonStyle(.bordered)

                        Button("Start Now") {
                            wantsToStartNow = true
                            finishOnboarding()
                        }
                        .buttonStyle(.borderedProminent)
                    }

                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 24)
            .transition(.opacity)

            Spacer()

            if step < 3 {
                Button("Continue") {
                    step += 1
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
        }
        .animation(.easeInOut, value: step)
    }

    func finishOnboarding() {
        UserDefaults.standard.set(wantsBilling, forKey: "wantsBilling")
        UserDefaults.standard.set(jobType, forKey: "jobType")
        UserDefaults.standard.set(jobCount, forKey: "jobCount")
        UserDefaults.standard.set(wantsToStartNow, forKey: "wantsToStartNow")
        
        isLoggedIn = true
    }
}

