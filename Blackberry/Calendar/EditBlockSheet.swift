import SwiftUI

/// A refined sheet for editing a TimeBlock with validation and clearer UI.
struct EditBlockSheet: View {
    @Binding var block: TimeBlock
    @ObservedObject private var jobManager = JobListManager.shared
    var onSave: (TimeBlock) -> Void

    @Environment(\.dismiss) private var dismiss

    // Validation state
    @State private var showValidationError = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Job Picker with label
                Text("Job")
                    .font(.headline)
                    .padding(.horizontal)
                Picker(selection: $block.job, label: Text(block.job.isEmpty ? "Select a job" : block.job)) {
                    ForEach(jobManager.jobList, id: \.self) { job in
                        Text(job).tag(job)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)

                Divider().padding(.vertical, 4)

                // Time pickers
                VStack(spacing: 12) {
                    HStack {
                        Text("Start Time")
                            .font(.subheadline)
                        Spacer()
                        DatePicker("", selection: $block.start, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .padding(.horizontal)

                    HStack {
                        Text("End Time")
                            .font(.subheadline)
                        Spacer()
                        DatePicker("", selection: $block.end, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .padding(.horizontal)
                }

                if showValidationError {
                    Text("End time must be after start time.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Edit Block")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if block.end <= block.start {
                            showValidationError = true
                        } else {
                            onSave(block)
                            dismiss()
                        }
                    }
                    .disabled(block.job.isEmpty)
                }
            }
            .interactiveDismissDisabled(showValidationError)
        }
    }
}
