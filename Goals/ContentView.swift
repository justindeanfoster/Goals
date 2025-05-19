// Goals Tracker App in Swift (Calendar View with Month Navigation)
import SwiftUI
import SwiftData

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

            StatisticsListView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview{
    ContentView()                
    .modelContainer(for: [Goal.self, Habit.self, JournalEntry.self, GoalHabitRelation.self])

}
