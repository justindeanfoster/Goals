import SwiftUI
import SwiftData

struct StatisticsListView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("Goals").font(.title2).bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ForEach(goals) { goal in
                        statisticsCard(
                            title: goal.title,
                            percent: Int((Double(goal.daysWorked) / 365.0) * 100),
                            days: goal.daysWorked,
                            gridEntries: Array(Set(goal.journalEntries.map { $0.timestamp } + goal.relatedHabits.flatMap { $0.journalEntries.map { $0.timestamp } })),
                            destination: StatisticsDetailView(item: .goal(goal))
                        )
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Habits").font(.title2).bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ForEach(habits) { habit in
                        statisticsCard(
                            title: habit.title,
                            percent: Int((Double(habit.daysWorked) / 365.0) * 100),
                            days: habit.daysWorked,
                            gridEntries: habit.journalEntries.map { $0.timestamp },
                            destination: StatisticsDetailView(item: .habit(habit))
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
        }
    }

    private func statisticsCard<D: View>(title: String, percent: Int, days: Int, gridEntries: [Date], destination: D) -> some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(percent)%")
                            .bold()
                            .foregroundColor(.primary)
                        Text("\(days) days")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                YearGridView(
                    entries: gridEntries,
                    calendarViewModel: calendarViewModel
                )
                .allowsHitTesting(false)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .shadow(radius: 2, x: 0, y: 2)
        }
    }
}
