import SwiftUI

enum StatisticsItem {
    case goal(Goal)
    case habit(Habit)
    
    var title: String {
        switch self {
        case .goal(let goal): return goal.title
        case .habit(let habit): return habit.title
        }
    }
}

struct StatisticsDetailView: View {
    let item: StatisticsItem
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var isAllTimeStats = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                titleSection
                yearGridSection
                statisticsSection
                histogramSection
                pieChartsSection
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var titleSection: some View {
        NavigationLink(destination: destinationView) {
            Text(item.title)
                .font(.title2)
                .bold()
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 5)
    }

    private var yearGridSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button(action: { calendarViewModel.moveYear(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Text("\(String(calendarViewModel.selectedYear)) Year Overview")
                    .font(.headline)
                Button(action: { calendarViewModel.moveYear(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
                Spacer()
            }
            YearGridView(
                entries: getEntriesForSelectedYear(),
                calendarViewModel: calendarViewModel
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Statistics")
                    .font(.headline)
                Spacer()
                Toggle("All Time", isOn: $isAllTimeStats)
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
            }
            .padding(.bottom, 5)
            statisticsRows
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var statisticsRows: some View {
        Group {
            if isAllTimeStats {
                StatRow(label: "Days Active (All Time)", value: "\(getAllTimeDaysWorked())")
                StatRow(label: "Overall Consistency", value: "\(getAllTimeConsistencyRate())%")
            } else {
                StatRow(label: "Days Active This Year", value: "\(getDaysWorkedInYear())")
                StatRow(label: "Year Consistency Rate", value: "\(getYearConsistencyRate())%")
            }
            StatRow(label: "Current Streak", value: "\(getCurrentStreak()) days")
            StatRow(label: "Longest Streak", value: "\(getLongestStreak()) days")
            StatRow(label: "Total Entries", value: isAllTimeStats ? "\(getTotalEntries())" : "\(getEntriesForSelectedYear().count)")
            if case .goal(let goal) = item {
                StatRow(label: "Days Remaining", value: "\(goal.daysRemaining)")
            }
        }
    }

    private var histogramSection: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 20) {
                Text("Monthly Activity Distribution")
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()
            }
            HistogramView(
                monthSections: isAllTimeStats ?
                    calendarViewModel.getWeeklyHistogramData(entries: getEntries()) :
                    calendarViewModel.getWeeklyHistogramData(entries: getEntriesForSelectedYear()),
                maxCount: 50
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var pieChartsSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 20) {
                    Text("Activity by Day of Week")
                        .font(.headline)
                        .padding(.horizontal)
                    Spacer()
                }
                PieChartView(
                    slices: isAllTimeStats ? getDayOfWeekBreakdown(entries: getEntries()) : getDayOfWeekBreakdown(entries: getEntriesForSelectedYear()),
                    title: ""
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private var destinationView: some View {
        switch item {
        case .goal(let goal): GoalDetailView(goal: goal)
        case .habit(let habit): HabitDetailView(habit: habit)
        }
    }

    private func getEntries() -> [Date] {
        switch item {
        case .goal(let goal):
            let goalEntries = goal.journalEntries.map { $0.timestamp }
            let habitEntries = goal.relatedHabits.flatMap { $0.journalEntries.map { $0.timestamp } }
            return goalEntries + habitEntries
        case .habit(let habit):
            return habit.journalEntries.map { $0.timestamp }
        }
    }

    private func getDaysWorked() -> Int {
        switch item {
        case .goal(let goal): return goal.daysWorked
        case .habit(let habit): return habit.daysWorked
        }
    }

    private func getTotalEntries() -> Int {
        switch item {
        case .goal(let goal):
            return goal.journalEntries.count + goal.relatedHabits.flatMap { $0.journalEntries }.count
        case .habit(let habit):
            return habit.journalEntries.count
        }
    }

    private func getEntriesForSelectedYear() -> [Date] {
        let entries = getEntries()
        return entries.filter { entry in
            Calendar.current.component(.year, from: entry) == calendarViewModel.selectedYear
        }
    }

    private func getDaysWorkedInYear() -> Int {
        let entries = getEntriesForSelectedYear()
        return Set(entries.map { Calendar.current.startOfDay(for: $0) }).count
    }

    private func getYearConsistencyRate() -> Int {
        let daysInYear = Calendar.current.isDate(calendarViewModel.selectedYearStartDate, equalTo: Date(), toGranularity: .year) ?
            Calendar.current.ordinality(of: .day, in: .year, for: Date())! :
            Calendar.current.range(of: .day, in: .year, for: calendarViewModel.selectedYearStartDate)?.count ?? 365
        return Int((Double(getDaysWorkedInYear()) / Double(daysInYear)) * 100)
    }

    private func getAllTimeDaysWorked() -> Int {
        let entries = getEntries()
        return Set(entries.map { Calendar.current.startOfDay(for: $0) }).count
    }

    private func getAllTimeConsistencyRate() -> Int {
        let entries = getEntries()
        guard let firstEntry = entries.min(by: { $0 < $1 }) else { return 0 }
        let totalDays = Calendar.current.dateComponents([.day], from: firstEntry, to: Date()).day ?? 0
        guard totalDays > 0 else { return 0 }
        return Int((Double(getAllTimeDaysWorked()) / Double(totalDays + 1)) * 100)
    }

    private func getCurrentStreak() -> Int {
        let entries = getEntries()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let uniqueDates = Set(entries.map { calendar.startOfDay(for: $0) }).sorted(by: >)
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

    private func getLongestStreak() -> Int {
        let entries = getEntries()
        guard !entries.isEmpty else { return 0 }
        let uniqueDates = Set(entries.map { Calendar.current.startOfDay(for: $0) }).sorted()
        var longestStreak = 0
        var currentStreak = 1
        for i in 1..<uniqueDates.count {
            let previousDate = uniqueDates[i - 1]
            let currentDate = uniqueDates[i]
            let daysBetween = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0
            if daysBetween == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        return max(longestStreak, currentStreak)
    }

    private func getDayOfWeekBreakdown(entries: [Date]) -> [PieSlice] {
        var dayCount: [Int: Int] = [:]
        let days = Calendar.current.shortWeekdaySymbols
        entries.forEach { date in
            let weekday = Calendar.current.component(.weekday, from: date)
            dayCount[weekday, default: 0] += 1
        }
        return dayCount.sorted { $0.key < $1.key }.map { weekday, count in
            PieSlice(
                value: Double(count),
                color: Color.blue.opacity(Double(weekday) / 7.0),
                label: days[weekday - 1]
            )
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
        }
        .padding(.vertical, 2)
    }
}