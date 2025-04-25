import SwiftUI
import SwiftData

struct StatisticsListView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section("Goals") {
                    ForEach(goals) { goal in
                        NavigationLink {
                            StatisticsDetailView(item: .goal(goal))
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(goal.title)
                                        .font(.headline)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("\(Int((Double(goal.daysWorked) / 365.0) * 100))%")
                                            .bold()
                                        Text("\(goal.daysWorked) days")
                                            .font(.caption)
                                    }
                                }
                                YearGridView(
                                    entries: goal.journalEntries.map { $0.timestamp },
                                    calendarViewModel: calendarViewModel
                                )
                                .allowsHitTesting(false) // Prevent YearGridView from intercepting taps
                            }
                            .contentShape(Rectangle()) // Make entire area tappable
                        }
                    }
                }
                
                Section("Habits") {
                    ForEach(habits) { habit in
                        NavigationLink {
                            StatisticsDetailView(item: .habit(habit))
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(habit.title)
                                        .font(.headline)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("\(Int((Double(habit.daysWorked) / 365.0) * 100))%")
                                            .bold()
                                        Text("\(habit.daysWorked) days")
                                            .font(.caption)
                                    }
                                }
                                YearGridView(
                                    entries: habit.journalEntries.map { $0.timestamp },
                                    calendarViewModel: calendarViewModel
                                )
                                .allowsHitTesting(false) // Prevent YearGridView from intercepting taps
                            }
                            .contentShape(Rectangle()) // Make entire area tappable
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}
