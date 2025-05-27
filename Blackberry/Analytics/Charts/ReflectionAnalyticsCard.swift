import SwiftUI
import CoreData

struct ReflectionAnalyticsCard: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MonthlyReflection.refDate, ascending: false)],
        predicate: NSPredicate(format: "refDate >= %@", Calendar.current.date(byAdding: .month, value: -6, to: Date())! as NSDate),
        animation: .default
    ) private var reflections: FetchedResults<MonthlyReflection>

    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and subtitle
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Monthly Reflection")
                        .font(AppFonts.sectionTitle)
                        .foregroundColor(AppColors.secondary)

                    Spacer()

                    if reflections.count > 1 {
                        Button(action: showNextReflection) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(AppColors.accent)
                        }
                    }
                }

                Text("A look at your thoughts and feelings this month.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Main reflection content
            if reflections.indices.contains(currentIndex) {
                let reflection = reflections[currentIndex]
                VStack(alignment: .leading, spacing: 6) {
                    if let date = reflection.refDate {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let prompt = reflection.refPrompt {
                        Text(prompt)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let response = reflection.refResponse {
                        Text(response)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.top, 2)
                    }

                    if let mood = reflection.refMood {
                        HStack(spacing: 6) {
                            Text(mood)
                                .font(.title3)
                            Text("Mood")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 4)
                    }
                }
                .transition(.opacity)
            } else {
                Text("No reflections yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Slide hint if multiple reflections
            if reflections.count > 1 {
                Text("Swipe or tap the arrow to view more")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.06), radius: AppSpacing.shadowRadius, x: 0, y: 4)
        .padding(.horizontal, 20)
        .gesture(
            DragGesture(minimumDistance: 30)
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    if value.translation.width < -50 {
                        showNextReflection()
                    }
                }
        )
        .onAppear {
            currentIndex = 0
        }
        .onChange(of: reflections.count) { _ in
            currentIndex = 0
        }
    }

    private func showNextReflection() {
        guard !reflections.isEmpty else { return }
        withAnimation {
            currentIndex = (currentIndex + 1) % reflections.count
        }
    }
}

