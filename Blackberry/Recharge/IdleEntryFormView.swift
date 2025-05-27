import SwiftUI
import CoreData

struct IdleEntryFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var label: String = ""
    @State private var hours: Double = 0
    @State private var entryDate: Date = Date()
    @State private var selectedTag: String = "Rest"
    @State private var isCustomTag = false
    @State private var customTag: String = ""

    private let presetTags = ["Rest", "Social", "Creative", "Outdoors", "Other"]
    private var allTags: [String] { presetTags + ["Custom..."] }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("New Recharge Entry")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)
                    .padding(.top, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("Activity (e.g. Reading, Walking)", text: $label)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Stepper(value: $hours, in: 0...12, step: 0.5) {
                            Text("Hours: \(String(format: "%.1f", hours))")
                        }

                        DatePicker("Date", selection: $entryDate, displayedComponents: [.date])

                        Picker("Tag", selection: $selectedTag) {
                            ForEach(allTags, id: \.self) { tag in
                                HStack {
                                    Circle()
                                        .fill(TagColors.color(for: tag))
                                        .frame(width: 10, height: 10)
                                    Text(tag)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedTag) { newTag in
                            isCustomTag = (newTag == "Custom...")
                            if !isCustomTag { customTag = "" }
                        }

                        if isCustomTag {
                            TextField("Enter custom tag", text: $customTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        Button(action: saveEntry) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Save Entry")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accent.opacity(0.15))
                            .cornerRadius(12)
                        }
                        .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty || hours == 0)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                }

                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                .padding(.bottom, 24)
            }
            .background(AppTheme.current.backgroundView.ignoresSafeArea())
        }
    }

    private func saveEntry() {
        let new = NonWorkActivity(context: viewContext)
        new.nonWorkId = UUID()
        new.nonWorkLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        new.nonWorkHours = hours
        new.nonWorkDate = entryDate
        new.nonWorkTag = isCustomTag ? customTag.trimmingCharacters(in: .whitespaces) : selectedTag
        new.nonWorkWeekStart = Calendar.current.startOfWeek(for: entryDate)

        try? viewContext.save()
        dismiss()
    }
}
