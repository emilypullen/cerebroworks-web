import SwiftUI
import CoreData

public struct JobCategoriesSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: – Bindings from parent
    @Binding public var savedJobs: [JobData]
    @Binding public var jobColors: [String: String]
    @Binding public var newJobName: String
    @Binding public var billingEnabled: Bool

    // MARK: – Local UI state
    @State private var rateInputVisible: [NSManagedObjectID: Bool] = [:]
    @State private var newRates: [NSManagedObjectID: Double] = [:]

    private let presetColors = [
        "CamelCoat", "CeramicMug", "Cranberry",
        "KnitSweater", "Midnight", "SteelBlue"
    ]

    // MARK: – Public initializer
    public init(
        savedJobs: Binding<[JobData]>,
        jobColors: Binding<[String: String]>,
        newJobName: Binding<String>,
        billingEnabled: Binding<Bool>
    ) {
        self._savedJobs = savedJobs
        self._jobColors = jobColors
        self._newJobName = newJobName
        self._billingEnabled = billingEnabled
    }

    private var currencyFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        return fmt
    }()

    public var body: some View {
        Section(header: HStack {
            Text("Job Categories")
                .font(AppFonts.heading)
            Spacer()
            Toggle(isOn: $billingEnabled) { }
                .labelsHidden()
        }) {
            ForEach(savedJobs, id: \.objectID) { job in
                HStack {
                    let jobName = job.nameJob ?? "Untitled"

                    // Color picker
                    Menu {
                        ForEach(presetColors, id: \.self) { colorName in
                            Button {
                                jobColors[jobName] = colorName
                                JobColors.shared.saveColorNames(jobColors)
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(Color(colorName))
                                        .frame(width: 16, height: 16)
                                    Text(colorName)
                                }
                            }
                        }
                    } label: {
                        Circle()
                            .fill(Color(jobColors[jobName] ?? "Cranberry"))
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            .accessibilityLabel(Text("Color for \(jobName)"))
                    }

                    // Job title
                    Text(jobName)
                        .foregroundColor(.primary)
                        .font(AppFonts.body)

                    Spacer()

                    // Delete button
                    Button {
                        removeJob(job)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(Text("Remove \(jobName)"))

                    // Billing UI
                    if billingEnabled {
                        if job.rate1 != 0 {
                            Text("$\(formattedRate(job.rate1))")
                                .font(AppFonts.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.secondary.opacity(0.2)))
                        }

                        if rateInputVisible[job.objectID] == true {
                            TextField(
                                "Rate",
                                value: Binding(
                                    get: { newRates[job.objectID] ?? job.rate1 },
                                    set: { newRates[job.objectID] = $0 }
                                ),
                                formatter: currencyFormatter
                            )
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button {
                                saveRate(for: job)
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        } else {
                            Button {
                                rateInputVisible[job.objectID] = true
                                newRates[job.objectID] = job.rate1
                            } label: {
                                Image(systemName: "dollarsign.circle")
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Add new job
            HStack {
                TextField("Add New Job", text: $newJobName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    addJob()
                }
            }
        }
    }

    private func formattedRate(_ rate: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: rate)) ?? String(format: "%.2f", rate)
    }

    private func removeJob(_ job: JobData) {
        viewContext.delete(job)
        do {
            try viewContext.save()
            savedJobs.removeAll { $0.objectID == job.objectID }
            jobColors.removeValue(forKey: job.nameJob ?? "")
            JobListManager.shared.refresh()
        } catch {
            print("❌ Failed to delete job: \(error)")
        }
    }

    private func saveRate(for job: JobData) {
        guard let entered = newRates[job.objectID] else { return }
        job.rate1 = entered
        do {
            try viewContext.save()
            rateInputVisible[job.objectID] = false
        } catch {
            print("❌ Failed to save rate: \(error)")
        }
    }

    private func addJob() {
        let trimmed = newJobName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let jd = JobData(context: viewContext)
        jd.nameJob = trimmed

        do {
            try viewContext.save()
            savedJobs.append(jd)
            jobColors[trimmed] = presetColors.first ?? "Cranberry"
            newJobName = ""
            JobListManager.shared.refresh()
        } catch {
            print("❌ Failed to add job: \(error)")
        }
    }
}
