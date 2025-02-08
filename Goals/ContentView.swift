// Goals Tracker App in Swift (Calendar View with Month Navigation)
import SwiftUI
import SwiftData


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
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            GoalsListView()
                .tabItem {
                    Label("Goals", systemImage: "list.bullet")
                }

            HabitsListView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview{
    ContentView()                
    .modelContainer(for :[Goal.self, Habit.self, JournalEntry.self])

}
