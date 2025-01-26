import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()

    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth)) ?? Date()
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
    
    func journalEntries(for date: Date, goals: [Goal]) -> [JournalEntryWithGoal] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        var entries: [JournalEntryWithGoal] = []
        for goal in goals {
            for entry in goal.journalEntries where Calendar.current.isDate(entry.timestamp, inSameDayAs: startOfDay) {
                entries.append(JournalEntryWithGoal(text: entry.text, goalTitle: goal.title))
            }
        }
        return entries
    }
}

struct JournalEntryWithGoal: Identifiable {
    let id = UUID()
    let text: String
    let goalTitle: String
}
