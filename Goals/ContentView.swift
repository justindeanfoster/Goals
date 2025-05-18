// Goals Tracker App in Swift (Calendar View with Month Navigation)
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                
            CombinedTrackerView()
                .tabItem {
                    Label("HOG", systemImage: "list.bullet")
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
