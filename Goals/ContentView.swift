// Goals Tracker App in Swift (Calendar View with Month Navigation)
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 1  // Add this line to set HOG as default

    var body: some View {
        TabView(selection: $selectedTab) {  // Add selection parameter
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(0)
                
            CombinedTrackerView()
                .tabItem {
                    Label("HoG", systemImage: "checkmark.circle")
                }
                .tag(1)

            StatisticsListView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview{
    ContentView()                
    .modelContainer(for: [Goal.self, Habit.self, JournalEntry.self, GoalHabitRelation.self])

}
