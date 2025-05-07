import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()
    @Published var selectedGoals: Set<UUID> = []
    @Published var selectedHabits: Set<UUID> = []
    @Published var timeframeChanged = false
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth)) ?? Date()
    }

    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentMonth)) ?? Date()
    }

    var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: Date())
        return Calendar.current.date(from: components) ?? Date()
    }

    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
    }
    
    var daysInCurrentYear: Int {
        let today = Date()
        // Add 1 to include today
        return (Calendar.current.dateComponents([.day], from: startOfYear, to: today).day ?? 0) + 1
    }

    var startingWeekday: Int {
        Calendar.current.component(.weekday, from: startOfMonth) - 1
    }
    
    var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return Calendar.current.shortWeekdaySymbols
    }
    
    var selectedYearStartDate: Date {
        let components = DateComponents(year: selectedYear, month: 1, day: 1)
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func goalsWorkedOn(for date: Date, goals: [Goal]) -> [Goal] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return goals.filter { goal in
            goal.journalEntries.contains(where: {
                Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay)
            })
        }
    }

    func pctGoalsWorkedOn(for date: Date, goals: [Goal]) -> Double {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let goalsWorkedOn = goals.filter { goal in
            goal.journalEntries.contains(where: {
                Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay)
            })
        }
        return goals.isEmpty ? 0 : Double(goalsWorkedOn.count) / Double(goals.count)
    }

    func moveMonth(by value: Int) {
        currentMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) ?? currentMonth
        timeframeChanged.toggle()
    }

    func moveWeek(by value: Int) {
        currentMonth = Calendar.current.date(byAdding: .weekOfMonth, value: value, to: currentMonth) ?? currentMonth
        timeframeChanged.toggle()
    }
    
    func moveDay(by days: Int) {
        let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate
        selectedDate = newDate
        
        // Check if we need to update the current month
        if !Calendar.current.isDate(newDate, equalTo: currentMonth, toGranularity: .month) {
            currentMonth = newDate
        }
    }
    
    func moveYear(by value: Int) {
        selectedYear += value
        timeframeChanged.toggle()
    }
    
    func initializeFilters(goals: [Goal], habits: [Habit]) {
        selectedGoals = Set(goals.map { $0.id })
        selectedHabits = Set(habits.map { $0.id })
    }
    
    func journalEntries(for date: Date, goals: [Goal], habits: [Habit]) -> [JournalEntryWithSource] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        var entries: [JournalEntryWithSource] = []
        
        // Get entries from filtered goals
        for goal in goals where selectedGoals.contains(goal.id) {
            for entry in goal.journalEntries where Calendar.current.isDate(entry.timestamp, inSameDayAs: startOfDay) {
                entries.append(JournalEntryWithSource(text: entry.text, sourceName: goal.title, sourceType: "Goal", timestamp: entry.timestamp))
            }
        }
        
        // Get entries from filtered habits
        for habit in habits where selectedHabits.contains(habit.id) {
            for entry in habit.journalEntries where Calendar.current.isDate(entry.timestamp, inSameDayAs: startOfDay) {
                entries.append(JournalEntryWithSource(text: entry.text, sourceName: habit.title, sourceType: "Habit", timestamp: entry.timestamp))
            }
        }
        
        return entries.sorted { $0.timestamp > $1.timestamp }
    }

    func filterJournalEntriesByDate(entries: [JournalEntry], date: Date) -> [JournalEntry] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return entries.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay) }
    }

    func hasJournalEntries(for date: Date, goals: [Goal], habits: [Habit]) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return goals.contains { goal in
            selectedGoals.contains(goal.id) &&
            goal.journalEntries.contains { entry in
                Calendar.current.isDate(entry.timestamp, inSameDayAs: startOfDay)
            }
        } || habits.contains { habit in
            selectedHabits.contains(habit.id) &&
            habit.journalEntries.contains { entry in
                Calendar.current.isDate(entry.timestamp, inSameDayAs: startOfDay)
            }
        }
    }
    
    func getEntriesForCurrentTimeframe(_ entries: [JournalEntry], isExpanded: Bool) -> [JournalEntry] {
        if isExpanded {
            // Show entries for current month
            return entries.filter { entry in
                Calendar.current.isDate(entry.timestamp, equalTo: currentMonth, toGranularity: .month)
            }
        } else {
            // Show entries for current week
            let startOfWeek = self.startOfWeek
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
            return entries.filter { entry in
                entry.timestamp >= startOfWeek && entry.timestamp < endOfWeek
            }
        }
    }
    
    func daysInYear(_ year: Int) -> Int {
        let isCurrentYear = year == Calendar.current.component(.year, from: Date())
        if (isCurrentYear) {
            return daysInCurrentYear
        } else {
            let yearDate = Calendar.current.date(from: DateComponents(year: year))!
            return Calendar.current.range(of: .day, in: .year, for: yearDate)?.count ?? 365
        }
    }
    
    func hasDeadlines(on date: Date, goals: [Goal]) -> Bool {
        let calendar = Calendar.current
        return goals.contains { calendar.isDate($0.deadline, inSameDayAs: date) }
    }
    
    func deadlinesForDate(_ date: Date, goals: [Goal]) -> [Goal] {
        let calendar = Calendar.current
        return goals.filter { calendar.isDate($0.deadline, inSameDayAs: date) }
    }
    
    func getRecentMonthRange(months: Int) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let end = Date()
        let start = calendar.date(byAdding: .month, value: -(months-1), to: startOfMonth(for: end))!
        return (start, end)
    }
    
    func startOfMonth(for date: Date) -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)) ?? date
    }

    func getDailyProgress(for date: Date, goals: [Goal], habits: [Habit]) -> Double {
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        // Count selected goals and habits
        var totalSelected = 0
        var completedCount = 0
        
        // Process goals
        for goal in goals where selectedGoals.contains(goal.id) {
            totalSelected += 1
            
            // Check if goal has entries for this date
            if goal.journalEntries.contains(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay) }) {
                completedCount += 1
            } else {
                // Check if any related habits were done
                if goal.relatedHabits.contains(where: { habit in
                    selectedHabits.contains(habit.id) &&
                    habit.journalEntries.contains(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay) })
                }) {
                    completedCount += 1
                }
            }
        }
        
        // Process habits that aren't related to selected goals
        for habit in habits where selectedHabits.contains(habit.id) {
            if !habit.relatedGoals.contains(where: { selectedGoals.contains($0.id) }) {
                totalSelected += 1
                if habit.journalEntries.contains(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay) }) {
                    completedCount += 1
                }
            }
        }
        
        return totalSelected > 0 ? Double(completedCount) / Double(totalSelected) : 0
    }
    
    func getWeeklyHistogramData(entries: [Date]) -> [MonthSection] {
        let calendar = Calendar.current
        let (startDate, endDate) = getRecentMonthRange(months: 12)
        var monthSections: [MonthSection] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let monthStart = startOfMonth(for: currentDate)
            let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
            
            // Get the first day of the first week
            let firstWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: monthStart))!
            
            var weekBins: [HistogramBin] = []
            var weekStart = firstWeekStart
            var weekNumber = 1
            
            while weekStart <= monthEnd {
                let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
                let weekEntries = entries.filter { entry in
                    entry >= weekStart && entry <= weekEnd
                }
                
                weekBins.append(HistogramBin(count: weekEntries.count, weekNumber: weekNumber))
                weekStart = calendar.date(byAdding: .day, value: 7, to: weekStart)!
                weekNumber += 1
            }
            
            let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: currentDate) - 1]
            monthSections.append(MonthSection(month: monthName, bins: weekBins))
            
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        }
        
        return monthSections
    }
}

struct JournalEntryWithSource: Identifiable {
    let id = UUID()
    let text: String
    let sourceName: String
    let sourceType: String
    let timestamp: Date
}
