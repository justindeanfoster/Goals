import SwiftUI

enum StatisticsItem {
    case goal(Goal)
    case habit(Habit)
    case all(goals: [Goal], habits: [Habit])
    
    var title: String {
        switch self {
        case .goal(let goal): return goal.title
        case .habit(let habit): return habit.title
        case .all: return "Overall Statistics"
        }
    }
}

enum TimeRange {
    case allTime
    case lastWeek
    case lastMonth
    case last3Months
    case last6Months
    case year  // Moved to end
    
    var description: String {
        switch self {
        case .allTime: return "All Time"
        case .lastWeek: return "Last Week"
        case .lastMonth: return "Last Month"
        case .last3Months: return "Last 3 Months"
        case .last6Months: return "Last 6 Months"
        case .year: return "Selected Year"
        }
    }
}

struct StatisticsDetailView: View {
    let item: StatisticsItem
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var selectedTimeRange: TimeRange = .allTime  // Changed from .year to .allTime
    
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
        Group {
            switch item {
            case .goal(let goal):
                NavigationLink(destination: GoalDetailView(goal: goal)) {
                    titleContent
                }
            case .habit(let habit):
                NavigationLink(destination: HabitDetailView(habit: habit)) {
                    titleContent
                }
            case .all:
                titleContent
            }
        }
        .padding(.vertical, 5)
    }
    
    private var titleContent: some View {
        Text(item.title)
            .font(.title2)
            .bold()
            .foregroundColor(item.isNavigable ? .blue : .primary)
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .shadow(radius: 2, x: 0, y: 2)
    }

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Statistics")
                    .font(.headline)
                Spacer()
                Menu {
                    Picker("Time Range", selection: $selectedTimeRange) {
                        Text("All Time").tag(TimeRange.allTime)
                        Text("Last Week").tag(TimeRange.lastWeek)
                        Text("Last Month").tag(TimeRange.lastMonth)
                        Text("Last 3 Months").tag(TimeRange.last3Months)
                        Text("Last 6 Months").tag(TimeRange.last6Months)
                        Text("Selected Year").tag(TimeRange.year)
                    }
                } label: {
                    HStack {
                        Text(selectedTimeRange.description)
                            .frame(width: 120, alignment: .leading) // Changed from .trailing to .leading
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.bottom, 5)
            statisticsRows
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2, x: 0, y: 2)
    }

    private var statisticsRows: some View {
        Group {
            switch selectedTimeRange {
            case .year:
                StatRow(label: "Days Active This Year", value: "\(getDaysWorkedInYear())")
                StatRow(label: "Year Consistency Rate", value: "\(getYearConsistencyRate())%")
            case .allTime:
                StatRow(label: "Days Active (All Time)", value: "\(getAllTimeDaysWorked())")
                StatRow(label: "Overall Consistency", value: "\(getAllTimeConsistencyRate())%")
            default:
                StatRow(label: "Days Active", value: "\(getDaysWorked(for: selectedTimeRange))")
                StatRow(label: "Consistency Rate", value: "\(getConsistencyRate(for: selectedTimeRange))%")
            }
            StatRow(label: "Current Streak", value: "\(getCurrentStreak()) days")
            StatRow(label: "Longest Streak", value: "\(getLongestStreak()) days")
            StatRow(label: "Total Entries", value: "\(getEntriesCount(for: selectedTimeRange))")
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
                monthSections: calendarViewModel.getWeeklyHistogramData(
                    entries: getFilteredEntries(for: selectedTimeRange),
                    timeRange: selectedTimeRange),  // Pass timeRange to CalendarViewModel
                maxCount: 50,
                timeRange: selectedTimeRange
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2, x: 0, y: 2)
    }

    private var pieChartsSection: some View {
        VStack(spacing: 20) {
            if case .goal(let goal) = item {
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 20) {
                        Text("Journal Entry Sources")
                            .font(.headline)
                            .padding(.horizontal)
                        Spacer()
                    }
                    PieChartView(
                        slices: getJournalEntrySourceBreakdown(goal: goal),
                        title: "",
                        alignment: .left
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2, x: 0, y: 2)
            }
            
            if case .all(let goals, let habits) = item {
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 20) {
                        Text("Journal Entry Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        Spacer()
                    }
                    PieChartView(
                        slices: getOverallJournalEntryBreakdown(
                            goals: goals,
                            habits: habits,
                            timeRange: selectedTimeRange
                        ),
                        title: "",
                        alignment: .left
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2, x: 0, y: 2)
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 20) {
                    Text("Activity by Day of Week")
                        .font(.headline)
                        .padding(.horizontal)
                    Spacer()
                }
                PieChartView(
                    slices: getDayOfWeekBreakdown(entries: getFilteredEntries(for: selectedTimeRange)),
                    title: "",
                    alignment: .right
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .shadow(radius: 2, x: 0, y: 2)
        }
    }

    // MARK: - Helpers

    private func getEntries() -> [Date] {
        switch item {
        case .goal(let goal):
            let goalEntries = goal.journalEntries.map { $0.timestamp }
            let habitEntries = goal.relatedHabits.flatMap { $0.journalEntries.map { $0.timestamp } }
            return goalEntries + habitEntries
        case .habit(let habit):
            return habit.journalEntries.map { $0.timestamp }
        case .all(let goals, let habits):
            let goalEntries = goals.flatMap { goal in
                goal.journalEntries.map { $0.timestamp } +
                goal.relatedHabits.flatMap { $0.journalEntries.map { $0.timestamp } }
            }
            let habitEntries = habits.flatMap { $0.journalEntries.map { $0.timestamp } }
            return Array(Set(goalEntries + habitEntries))
        }
    }

    private func getDaysWorked() -> Int {
        switch item {
        case .goal(let goal): return goal.daysWorked
        case .habit(let habit): return habit.daysWorked
        case .all(_, _):
            let allEntries = getEntries()
            return Set(allEntries.map { Calendar.current.startOfDay(for: $0) }).count
        }
    }

    private func getTotalEntries() -> Int {
        switch item {
        case .goal(let goal):
            return goal.journalEntries.count + goal.relatedHabits.flatMap { $0.journalEntries }.count
        case .habit(let habit):
            return habit.journalEntries.count
        case .all(let goals, let habits):
            let goalEntries = goals.flatMap { goal in
                goal.journalEntries.count + goal.relatedHabits.flatMap { $0.journalEntries }.count
            }.reduce(0, +)
            let habitEntries = habits.flatMap { $0.journalEntries }.count
            return goalEntries + habitEntries
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

    private func getPieChartColors(_ count: Int) -> [Color] {
        return (0..<count).map { index in
            Color.blue.opacity(0.3 + (Double(index) / Double(count)) * 0.6)
        }
    }

    private func getDayOfWeekBreakdown(entries: [Date]) -> [PieSlice] {
        var dayCount: [Int: Int] = [:]
        let days = Calendar.current.shortWeekdaySymbols
        entries.forEach { date in
            let weekday = Calendar.current.component(.weekday, from: date)
            dayCount[weekday, default: 0] += 1
        }
        
        let sortedData = dayCount.sorted { $0.key < $1.key }
        let colors = getPieChartColors(7)  // 7 days in a week
        
        return sortedData.enumerated().map { index, item in
            PieSlice(
                value: Double(item.value),
                color: colors[item.key - 1],
                label: days[item.key - 1]
            )
        }
    }

    private func getJournalEntrySourceBreakdown(goal: Goal) -> [PieSlice] {
        var sources: [(String, Int)] = []
        
        // Count goal's direct entries and habits
        let goalEntries = goal.journalEntries.count
        if goalEntries > 0 {
            sources.append((goal.title, goalEntries))
        }
        
        for habit in goal.relatedHabits {
            let habitEntries = habit.journalEntries.count
            if habitEntries > 0 {
                sources.append((habit.title, habitEntries))
            }
        }
        
        let colors = getPieChartColors(sources.count)
        
        return sources.enumerated().map { index, source in
            PieSlice(
                value: Double(source.1),
                color: colors[index],
                label: source.0
            )
        }
    }

    private func getDaysWorked(for timeRange: TimeRange) -> Int {
        let entries = getFilteredEntries(for: timeRange)
        return Set(entries.map { Calendar.current.startOfDay(for: $0) }).count
    }
    
    private func getConsistencyRate(for timeRange: TimeRange) -> Int {
        let entries = getFilteredEntries(for: timeRange)
        let days = getDaysInPeriod(for: timeRange)
        return Int((Double(Set(entries.map { Calendar.current.startOfDay(for: $0) }).count) / Double(days)) * 100)
    }
    
    private func getEntriesCount(for timeRange: TimeRange) -> Int {
        getFilteredEntries(for: timeRange).count
    }
    
    private func getFilteredEntries(for timeRange: TimeRange) -> [Date] {
        let allEntries = getEntries()
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .year:
            return getEntriesForSelectedYear()
        case .lastWeek:
            let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            return allEntries.filter { $0 >= startDate }
        case .lastMonth:
            let startDate = calendar.date(byAdding: .month, value: -1, to: now)!
            return allEntries.filter { $0 >= startDate }
        case .last3Months:
            let startDate = calendar.date(byAdding: .month, value: -3, to: now)!
            return allEntries.filter { $0 >= startDate }
        case .last6Months:
            let startDate = calendar.date(byAdding: .month, value: -6, to: now)!
            return allEntries.filter { $0 >= startDate }
        case .allTime:
            return allEntries
        }
    }
    
    private func getDaysInPeriod(for timeRange: TimeRange) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .year:
            return calendar.range(of: .day, in: .year, for: calendarViewModel.selectedYearStartDate)?.count ?? 365
        case .lastWeek:
            return 7
        case .lastMonth:
            return 30
        case .last3Months:
            return 90
        case .last6Months:
            return 180
        case .allTime:
            guard let firstEntry = getEntries().min() else { return 0 }
            return calendar.dateComponents([.day], from: firstEntry, to: now).day ?? 0
        }
    }

    private func getOverallJournalEntryBreakdown(goals: [Goal], habits: [Habit], timeRange: TimeRange) -> [PieSlice] {
        var sources: [(String, Int)] = []
        
        // Add goals and their entries
        for goal in goals {
            let entries = goal.journalEntries
                .filter { entry in
                    isEntry(entry.timestamp, inTimeRange: timeRange)
                }
                .count
            if entries > 0 {
                sources.append((goal.title, entries))
            }
        }
        
        // Add habits and their entries
        for habit in habits {
            let entries = habit.journalEntries
                .filter { entry in
                    isEntry(entry.timestamp, inTimeRange: timeRange)
                }
                .count
            if entries > 0 {
                sources.append((habit.title, entries))
            }
        }
        
        // Sort by entry count to show most active items first
        sources.sort { $0.1 > $1.1 }
        
        let colors = getPieChartColors(sources.count)
        
        return sources.enumerated().map { index, source in
            PieSlice(
                value: Double(source.1),
                color: colors[index],
                label: source.0
            )
        }
    }

    private func isEntry(_ date: Date, inTimeRange timeRange: TimeRange) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .year:
            return calendar.component(.year, from: date) == calendarViewModel.selectedYear
        case .lastWeek:
            let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            return date >= startDate
        case .lastMonth:
            let startDate = calendar.date(byAdding: .month, value: -1, to: now)!
            return date >= startDate
        case .last3Months:
            let startDate = calendar.date(byAdding: .month, value: -3, to: now)!
            return date >= startDate
        case .last6Months:
            let startDate = calendar.date(byAdding: .month, value: -6, to: now)!
            return date >= startDate
        case .allTime:
            return true
        }
    }
}

extension StatisticsItem {
    var isNavigable: Bool {
        switch self {
        case .goal, .habit: return true
        case .all: return false
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
