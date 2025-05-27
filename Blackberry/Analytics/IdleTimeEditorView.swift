import SwiftUI
import CoreData
import Foundation

struct IdleTimeEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NonWorkActivity.nonWorkDate, ascending: true)],
        predicate: NSPredicate(format: "nonWorkWeekStart == %@", Calendar.current.startOfWeek(for: Date()) as NSDate)
    ) private var existingActivities: FetchedResults<NonWorkActivity>

    @State private var label: String = ""
    @State private var hours: Double = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Log Recharge Activity")
                            .font(AppFonts.sectionTitle)
                            .foregroundColor(AppColors.secondary)
                        
                        Text("What did you do to recharge?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // Input Card
                    VStack(spacing: 16) {
                        TextField("e.g. Reading, Walking", text: $label)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Stepper(value: $hours, in: 0...12, step: 0.5) {
                            Text("Hours: \(String(format: "%.1f", hours))")
                        }

                        Button(action: saveEntry) {
                            HStack {
                                Spacer()
                                Text("Add")
                                    .font(.body)
                                    .padding(.vertical, 10)
                                Spacer()
                            }
                            .background(AppColors.accent.opacity(0.15))
                            .cornerRadius(10)
                        }
                        .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty || hours == 0)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Log List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recharge Log (This Week)")
                            .font(AppFonts.sectionTitle)
                            .foregroundColor(AppColors.secondary)

                        if existingActivities.isEmpty {
                            Text("No entries yet.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(existingActivities) { activity in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(activity.nonWorkLabel ?? "Unlabeled")
                                            .font(.body)
                                        if let date = activity.nonWorkDate {
                                            Text(date, style: .date)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Text("\(String(format: "%.1f", activity.nonWorkHours)) hrs")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewContext.delete(existingActivities[index])
                                }
                                try? viewContext.save()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(AppTheme.current.backgroundView.ignoresSafeArea())
            .navigationTitle("Recharge Editor")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveEntry() {
        let new = NonWorkActivity(context: viewContext)
        new.nonWorkId = UUID()
        new.nonWorkLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        new.nonWorkHours = hours
        new.nonWorkDate = Date()
        new.nonWorkWeekStart = Calendar.current.startOfWeek(for: Date())

        try? viewContext.save()
        label = ""
        hours = 0
    }
}
