// Goals Tracker App in Swift (Calendar View with Month Navigation)
import SwiftUI

struct Goal: Identifiable {
    let id = UUID()
    var title: String
    var journalEntries: [JournalEntry] = []
    var deadline: Date
    var milestones: [String] = []
    var notes: String = "" // New field for notes
    var daysWorked: Int {
        let uniqueDays = Set(journalEntries.map { Calendar.current.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }
    var daysRemaining: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(remaining, 0)
    }
}

struct JournalEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let text: String
}

struct DayProgress: Identifiable {
    let id = UUID()
    let date: Date
    let goalsWorkedOn: Int
    let totalGoals: Int
    var progress: Double {
        return totalGoals > 0 ? Double(goalsWorkedOn) / Double(totalGoals) : 0
    }
}

struct ContentView: View {
    @State private var goals: [Goal] = [
        Goal(title: "Learn Swift", deadline: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, milestones: ["Finish basics", "Build a project"]),
        Goal(title: "Exercise", deadline: Calendar.current.date(byAdding: .day, value: 20, to: Date())!, milestones: ["Join a gym", "Run 5k"]),
        Goal(title: "Read a Book", deadline: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, milestones: ["Read Chapter 1", "Complete Half"])
    ]

    @State private var showAddGoalForm = false

    var body: some View {
        TabView {
            GoalsListView(goals: $goals, showAddGoalForm: $showAddGoalForm)
                .tabItem {
                    Label("Goals", systemImage: "list.bullet")
                }

            CalendarView(goals: goals)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .sheet(isPresented: $showAddGoalForm) {
            AddGoalForm(goals: $goals)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
