import SwiftUI
import CoreData

struct DayCalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedTab: Tab

    @StateObject private var entryManager = EntryManager.shared
    @State private var showNewEntry = false
    @State private var selectedBlock: TimeBlock? = nil

    @State private var now: Date = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private let hours = Array(0..<24)
    private let calendar = Calendar.current

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ZStack(alignment: .topLeading) {
                            timeGrid

                            let blocksToday = entryManager.timeBlocks.filter {
                                calendar.isDate($0.start, inSameDayAs: currentDate)
                            }

                            ForEach(blocksToday) { block in
                                let offset = offsetY(for: block.start)
                                let height = blockHeight(for: block)

                                EntryBlockView(block: block)
                                    .offset(x: 50, y: offset)
                                    .frame(width: UIScreen.main.bounds.width - 100, height: height)
                                    .onTapGesture {
                                        selectedBlock = block
                                    }
                            }

                            NowIndicator(offsetY: offsetY(for: now))
                                .offset(x: 50)

                            Color.clear
                                .frame(height: 1)
                                .offset(y: offsetY(for: now))
                                .id("now")
                        }
                        .padding()
                        .background(AppColors.background.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .onReceive(timer) { now = $0 }
                        .onAppear {
                            proxy.scrollTo("now", anchor: .top)
                        }
                        .sheet(isPresented: $showNewEntry) {
                            NewEntryView(selectedTab: $selectedTab)
                        }
                        .sheet(item: $selectedBlock) { block in
                            if let idx = entryManager.timeBlocks.firstIndex(where: { $0.id == block.id }) {
                                let bindingBlock = Binding(
                                    get: { entryManager.timeBlocks[idx] },
                                    set: { entryManager.timeBlocks[idx] = $0 }
                                )
                                EditBlockSheet(block: bindingBlock) { _ in selectedBlock = nil }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .background(AppTheme.current.backgroundView)
            .navigationTitle(dayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewEntry.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.current.primary)
                    }
                }
            }
        }
    }

    // MARK: - Hour Grid
    private var timeGrid: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                HStack(alignment: .top) {
                    Text(hourLabel(for: hour))
                        .font(.caption2)
                        .foregroundColor(AppColors.secondary.opacity(0.6))
                        .frame(width: 50, alignment: .trailing)

                    Rectangle()
                        .fill(AppColors.border)
                        .frame(height: 1)
                }
                .id(hour)
                .frame(height: 60)
            }
        }
    }

    // MARK: - Now Indicator
    private struct NowIndicator: View {
        let offsetY: CGFloat
        var body: some View {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(AppTheme.current.primary)
                    .frame(height: 2)
                Circle()
                    .fill(AppTheme.current.primary)
                    .frame(width: 8, height: 8)
                    .offset(x: -4)
            }
            .offset(y: offsetY)
            .animation(.easeInOut(duration: 0.5), value: offsetY)
        }
    }

    // MARK: - Helpers
    private var dayTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMM d, yyyy"
        return fmt.string(from: currentDate)
    }

    private func offsetY(for date: Date) -> CGFloat {
        let start = calendar.startOfDay(for: date)
        return CGFloat(date.timeIntervalSince(start) / 60)
    }

    private func blockHeight(for block: TimeBlock) -> CGFloat {
        max(CGFloat(block.end.timeIntervalSince(block.start) / 60), 24)
    }

    private func hourLabel(for hour: Int) -> String {
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: currentDate) ?? currentDate
        let fmt = DateFormatter()
        fmt.dateFormat = "h a"
        return fmt.string(from: date)
    }
}

// MARK: - Entry Block View
struct EntryBlockView: View {
    let block: TimeBlock
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(AppTheme.current.primary.opacity(0.3))
    }
}

