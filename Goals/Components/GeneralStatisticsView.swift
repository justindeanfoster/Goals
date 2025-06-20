import SwiftUI
import SwiftData

struct GeneralStatisticsView: View {
    let goals: [Goal]
    let habits: [Habit]
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var selectedTimeRange: TimeRange = .lastMonth
    
    private var allEntries: [Date] {
        let goalEntries = goals.flatMap { goal in 
            goal.journalEntries.map { $0.timestamp } + 
            goal.relatedHabits.flatMap { $0.journalEntries.map { $0.timestamp } }
        }
        let habitEntries = habits.flatMap { $0.journalEntries.map { $0.timestamp } }
        return Array(Set(goalEntries + habitEntries))
    }
    
    private var totalDaysWorked: Int {
        Set(allEntries.map { Calendar.current.startOfDay(for: $0) }).count
    }
    
    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let uniqueDates = Set(allEntries.map { calendar.startOfDay(for: $0) }).sorted(by: >)
        guard let mostRecentEntry = uniqueDates.first else { return 0 }
        if mostRecentEntry < yesterday { return 0 }
        
        var streak = 0
        var currentDate = mostRecentEntry
        while uniqueDates.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        return streak
    }
    
    var body: some View {
        NavigationLink(destination: StatisticsDetailView(item: .all(goals: goals, habits: habits))) {
            VStack(spacing: 24) {
                // Statistics Cards
                HStack(spacing: 20) {
                    statisticCard(
                        title: "Total Active Days",
                        value: "\(totalDaysWorked)",
                        subtitle: "Days with entries"
                    )
                    statisticCard(
                        title: "Current Streak",
                        value: "\(currentStreak)",
                        subtitle: "Days in a row"
                    )
                }
                
                // Histogram and Time Range Picker Section
                VStack(alignment: .leading, spacing: 20) {
                    // Histogram Section
                    VStack(alignment: .leading, spacing: 12) {
                        Spacer().padding(.bottom,8)
                        HistogramView(
                            monthSections: calendarViewModel.getWeeklyHistogramData(
                                entries: allEntries,
                                timeRange: selectedTimeRange
                            ),
                            maxCount: 50,
                            timeRange: selectedTimeRange
                        )
                        .frame(height: 120)
                    }
                    Spacer()
                    // Time Range Picker
                    HStack {
                        Spacer()

                        Menu {
                            Picker("Time Range", selection: $selectedTimeRange) {
                                Text("All Time").tag(TimeRange.allTime)
                                Text("Last Month").tag(TimeRange.lastMonth)
                                Text("Last 3 Months").tag(TimeRange.last3Months)
                                Text("Last 6 Months").tag(TimeRange.last6Months)
                                Text("Selected Year").tag(TimeRange.year)
                            }
                        } label: {
                            HStack {
                                Text(selectedTimeRange.description)
                                    .frame(width: 120, alignment: .leading)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .shadow(radius: 2, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statisticCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .bold()
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
