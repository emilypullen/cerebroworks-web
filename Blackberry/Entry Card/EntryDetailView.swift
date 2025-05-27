import SwiftUI

struct EntryDetailView: View {
    let entry: EntryData

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Job
                ColoredSection(title: "Job") {
                    Text(entry.job ?? "-")
                        .font(AppFonts.heading)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // MARK: - Tasks
                ColoredSection(title: "Tasks") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(entry.tasksArray, id: \.self) { task in
                            HStack {
                                Image(systemName: entry.completedTasksArray.contains(task) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(entry.completedTasksArray.contains(task) ? .gray : AppColors.accent)
                                Text(task)
                                    .strikethrough(entry.completedTasksArray.contains(task))
                                    .foregroundColor(entry.completedTasksArray.contains(task) ? .gray : .primary)
                                    .font(AppFonts.body)
                            }
                        }
                        if entry.tasksArray.isEmpty && entry.completedTasksArray.isEmpty {
                            Text("No tasks added.")
                                .font(AppFonts.body)
                                .foregroundColor(.gray)
                        }
                    }
                }

                // MARK: - Notes
                ColoredSection(title: "Notes") {
                    ZStack(alignment: .topLeading) {
                        if (entry.notes ?? "").isEmpty {
                            Text("No notes added.")
                                .foregroundColor(.gray)
                                .padding(8)
                        }
                        TextEditor(text: .constant(entry.notes ?? ""))
                            .font(AppFonts.body)
                            .frame(minHeight: 120)
                            .disabled(true) // make it readable but not editable
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }

                // MARK: - Date & Time
                ColoredSection(title: "Date & Time") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date: \(entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "-")")
                        Text("Start: \(entry.startTime?.formatted(date: .omitted, time: .shortened) ?? "-")")
                        Text("End: \(entry.endTime?.formatted(date: .omitted, time: .shortened) ?? "-")")
                    }
                    .font(AppFonts.body)
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.80, green: 0.90, blue: 1.0),  // Light Sky
                    Color(red: 0.92, green: 0.90, blue: 0.98), // Pale Lavender
                    Color(red: 1.0, green: 0.94, blue: 0.96)   // Very Soft Pink
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Entry Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Colored Section

struct ColoredSection<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFonts.sectionTitle)
                .foregroundColor(AppColors.secondary)

            content
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
}
