import SwiftUI
import CoreData

struct EntriesTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTab: Tab

    @FetchRequest(
        entity: EntryData.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \EntryData.date, ascending: false)],
        animation: .default
    ) private var allEntries: FetchedResults<EntryData>

    @State private var showNewEntryForm = false

    struct MonthGroup: Identifiable {
        let id: String
        let entries: [EntryData]
    }

    private var groupedEntries: [MonthGroup] {
        Dictionary(grouping: allEntries) { entry in
            let date = entry.date ?? Date()
            let fmt = DateFormatter()
            fmt.dateFormat = "LLLL yyyy"
            return fmt.string(from: date)
        }
        .map { MonthGroup(id: $0.key, entries: $0.value) }
        .sorted { $0.id > $1.id }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.current.backgroundView
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    headerView

                    if allEntries.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 32) {
                                ForEach(groupedEntries) { group in
                                    MonthGroupView(group: group)
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                }
                .padding(.horizontal, 10)

                // Floating Add Button
                Button(action: { showNewEntryForm = true }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(AppColors.primary)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 6)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
                .sheet(isPresented: $showNewEntryForm) {
                    NewEntryView(initialTasks: [], selectedTab: $selectedTab)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Entries")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(AppColors.secondary)
                Text("Your logged sessions")
                    .font(.footnote)
                    .foregroundColor(AppColors.secondary.opacity(0.6))
            }
            Spacer()
        }
        .padding(.top, 30)
        .padding(.horizontal, 20)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No entries yet!")
                .font(.title2.bold())
                .foregroundColor(AppColors.secondary)
            Text("Tap the + button to add your first entry.")
                .font(.body)
                .foregroundColor(AppColors.secondary.opacity(0.6))
            Image(systemName: "arrow.down.circle.fill")
                .font(.largeTitle)
                .foregroundColor(AppColors.primary)
                .opacity(0.8)
                .offset(y: 10)
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: UUID())
            Spacer()
        }
        .padding()
    }
}

// MARK: - Grouped Month View
private struct MonthGroupView: View {
    let group: EntriesTabView.MonthGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(group.id)
                .font(.title2.bold())
                .foregroundColor(AppColors.secondary)

            VStack(spacing: 16) {
                ForEach(group.entries, id: \.objectID) { entry in
                    EntryCardView(entry: entry)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 8)
            .background(AppColors.cardBackground) // Themed background
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 8)
        }
    }
}

