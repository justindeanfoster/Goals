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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Year Navigation
                HStack {
                    Button(action: { calendarViewModel.moveYear(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text("\(calendarViewModel.selectedYear)")
                        .font(.title2.bold())
                    Spacer()
                    Button(action: { calendarViewModel.moveYear(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
                // Year View
                VStack(alignment: .leading) {
                    Text("Year Overview")
                        .font(.headline)
                    YearGridView(
                        entries: getEntriesForSelectedYear(),
                        calendarViewModel: calendarViewModel
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Statistics
                VStack(alignment: .leading, spacing: 15) {
                    Text("Statistics")
                        .font(.headline)
                    
                    Group {
                        StatRow(label: "Days Active This Year", value: "\(getDaysWorkedInYear())")
                        StatRow(label: "Year Consistency Rate", value: "\(getYearConsistencyRate())%")
                        StatRow(label: "Current Streak", value: "\(getCurrentStreak()) days")
                        StatRow(label: "Longest Streak", value: "\(getLongestStreak()) days")
                        StatRow(label: "Total Entries This Year", value: "\(getEntriesForSelectedYear().count)")
                        
                        if case .goal(let goal) = item {
                            StatRow(label: "Days Remaining", value: "\(goal.daysRemaining)")
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getEntries() -> [Date] {
        switch item {
        case .goal(let goal): return goal.journalEntries.map { $0.timestamp }
        case .habit(let habit): return habit.journalEntries.map { $0.timestamp }
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
        case .goal(let goal): return goal.journalEntries.count
        case .habit(let habit): return habit.journalEntries.count
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
    
    // Add implementations for getCurrentStreak and getLongestStreak
    private func getCurrentStreak() -> Int {
        // Implementation needed
        return 0
    }
    
    private func getLongestStreak() -> Int {
        // Implementation needed
        return 0
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
