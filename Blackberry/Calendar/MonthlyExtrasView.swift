import SwiftUI
import CoreData

struct MonthlyExtrasView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isProUser") private var isProUser: Bool = false
    @AppStorage("customMonthlyPrompts") private var customPrompts: String = ""

    private let defaultPrompts = [
        "What was my biggest win this month?",
        "What challenge did I overcome?",
        "What am I grateful for?",
        "What are my goals next month?"
    ]

    private var allPrompts: [String] {
        defaultPrompts + customPrompts.components(separatedBy: "|||").filter { !$0.isEmpty }
    }

    @State private var promptIndex = 0
    @State private var reflectionText: String = ""
    @State private var selectedMood: String = ""
    @State private var existingReflection: MonthlyReflection?
    @State private var saveStatus: String = ""
    @State private var showPromptEditor = false

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if isProUser {
                        // Reflection Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Monthly Reflection")
                                    .font(.headline)
                                Spacer()
                                Button(action: cyclePrompt) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .rotationEffect(.degrees(90))
                                }
                                Button(action: { showPromptEditor = true }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.accentColor)
                                }
                            }

                            if !allPrompts.isEmpty {
                                Text(allPrompts[promptIndex])
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            TextEditor(text: $reflectionText)
                                .frame(minHeight: 100)
                                .padding(6)
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                                .keyboardToolbar {
                                    UIApplication.shared.endEditing()
                                }
                        }

                        // Mood Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mood / Energy Level")
                                .font(.headline)
                            HStack(spacing: 16) {
                                ForEach(["😴", "🙂", "😃", "🚀"], id: \.self) { mood in
                                    Text(mood)
                                        .font(.largeTitle)
                                        .opacity(selectedMood == mood ? 1.0 : 0.5)
                                        .onTapGesture {
                                            selectedMood = mood
                                        }
                                }
                            }
                        }

                        // Save Button
                        Button(action: saveReflection) {
                            Text("Save Reflection")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        if !saveStatus.isEmpty {
                            Text(saveStatus)
                                .font(.caption)
                                .foregroundColor(.green)
                                .transition(.opacity)
                        }

                    } else {
                        // 🔒 Locked View for Non-Pro Users
                        VStack(alignment: .center, spacing: 16) {
                            Text("🔒 Monthly Reflections are a Pro Feature")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.secondary)

                            Text("Reflect on your month, track your mood, and build self-awareness with guided monthly prompts — available with Tempo Pro.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Button(action: {
                                // Trigger Pro upgrade (placeholder)
                            }) {
                                Text("Upgrade to Pro")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            if isProUser {
                loadReflection()
            }
        }
        .sheet(isPresented: $showPromptEditor) {
            CustomPromptEditorView(onSave: {
                showPromptEditor = false
            })
        }
    }

    private func cyclePrompt() {
        promptIndex = (promptIndex + 1) % allPrompts.count
        reflectionText = ""
    }

    private func loadReflection() {
        let request: NSFetchRequest<MonthlyReflection> = MonthlyReflection.fetchRequest()
        let start = Calendar.current.startOfMonth(for: Date())
        let end = Calendar.current.startOfNextMonth(for: Date())
        request.predicate = NSPredicate(format: "refDate >= %@ AND refDate < %@", start as NSDate, end as NSDate)
        request.fetchLimit = 1

        do {
            if let match = try viewContext.fetch(request).first {
                existingReflection = match
                reflectionText = match.refResponse ?? ""
                selectedMood = match.refMood ?? ""
                if let prompt = match.refPrompt, let index = allPrompts.firstIndex(of: prompt) {
                    promptIndex = index
                }
            }
        } catch {
            print("❌ Fetch failed: \(error)")
        }
    }

    private func saveReflection() {
        guard !allPrompts.isEmpty else { return }

        let reflection = existingReflection ?? MonthlyReflection(context: viewContext)
        reflection.refDate = Calendar.current.startOfMonth(for: Date())
        reflection.refPrompt = allPrompts[promptIndex]
        reflection.refResponse = reflectionText
        reflection.refMood = selectedMood
        if reflection.refID == nil {
            reflection.refID = UUID()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            viewContext.performAndWait {
                do {
                    try viewContext.save()
                    DispatchQueue.main.async {
                        existingReflection = reflection
                        showSavedStatus()
                    }
                } catch {
                    print("❌ Save failed: \(error)")
                }
            }
        }
    }

    private func showSavedStatus() {
        withAnimation {
            saveStatus = "Saved ✅"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                saveStatus = ""
            }
        }
    }
}

// MARK: - Custom Prompt Editor Sheet

struct CustomPromptEditorView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("customMonthlyPrompts") private var customPrompts: String = ""
    @State private var newPrompt: String = ""
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Create Your Prompt")
                    .font(.headline)

                TextField("Enter your prompt", text: $newPrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Save") {
                    savePrompt()
                    onSave()
                    dismiss()
                }
                .disabled(newPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("New Reflection Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func savePrompt() {
        var prompts = customPrompts.components(separatedBy: "|||").filter { !$0.isEmpty }
        prompts.append(newPrompt.trimmingCharacters(in: .whitespacesAndNewlines))
        customPrompts = prompts.joined(separator: "|||")
    }
}
