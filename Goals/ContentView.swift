// Goals Tracker App in Swift (Calendar View with Month Navigation)
import SwiftUI


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
    @State private var goals: [Goal] = []
    @State private var habits: [Habit] = []

    @State private var showAddGoalForm = false

    init() {
        loadGoals()
    }

    var body: some View {
        TabView {
            GoalsListView(goals: $goals, showAddGoalForm: $showAddGoalForm)
                .tabItem {
                    Label("Goals", systemImage: "list.bullet")
                }

            HabitsListView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
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
        .onChange(of: goals) {
            saveGoals()
        }
        .onChange(of: habits) {
            saveHabits()
        }
    }

    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: "goals"),
           let decodedGoals = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decodedGoals
        }
    }

    private func saveGoals() {
        if let encodedGoals = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encodedGoals, forKey: "habits")
        }
    }
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "habits"),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decodedHabits
        }
    }

    private func saveHabits() {
        if let encodedHabits = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encodedHabits, forKey: "goals")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
