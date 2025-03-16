import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()
    @Published var selectedGoals: Set<UUID> = []
    @Published var selectedHabits: Set<UUID> = []
    
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth)) ?? Date()
    }

    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentMonth)) ?? Date()
    }

    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
    }
    
    var startingWeekday: Int {
        Calendar.current.component(.weekday, from: startOfMonth) - 1
    }
    
    var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return Calendar.current.shortWeekdaySymbols
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
    }

    func moveWeek(by value: Int) {
        currentMonth = Calendar.current.date(byAdding: .weekOfMonth, value: value, to: currentMonth) ?? currentMonth
    }
    
    func moveDay(by days: Int) {
        let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate
        selectedDate = newDate
        
        // Check if we need to update the current month
        if !Calendar.current.isDate(newDate, equalTo: currentMonth, toGranularity: .month) {
            currentMonth = newDate
        }
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
}

struct JournalEntryWithSource: Identifiable {
    let id = UUID()
    let text: String
    let sourceName: String
    let sourceType: String
    let timestamp: Date
}
