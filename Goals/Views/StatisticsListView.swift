import SwiftUI
import SwiftData

struct StatisticsListView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
            List {
                goalsSection
                habitsSection
            }
            .navigationTitle("Statistics")
        }
    }

    // MARK: - Sections

    private var goalsSection: some View {
        Section("Goals") {
            ForEach(goals) { goal in
                statisticsRow(
                    title: goal.title,
                    percent: Int((Double(goal.daysWorked) / 365.0) * 100),
                    days: goal.daysWorked,
                    gridEntries: Array(Set(goal.journalEntries.map { $0.timestamp } + goal.relatedHabits.flatMap { $0.journalEntries.map { $0.timestamp } })),
                    destination: StatisticsDetailView(item: .goal(goal))
                )
            }
        }
    }

    private var habitsSection: some View {
        Section("Habits") {
            ForEach(habits) { habit in
                statisticsRow(
                    title: habit.title,
                    percent: Int((Double(habit.daysWorked) / 365.0) * 100),
                    days: habit.daysWorked,
                    gridEntries: habit.journalEntries.map { $0.timestamp },
                    destination: StatisticsDetailView(item: .habit(habit))
                )
            }
        }
    }

    // MARK: - Row

    private func statisticsRow(title: String, percent: Int, days: Int, gridEntries: [Date], destination: some View) -> some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title).font(.headline)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(percent)%").bold()
                        Text("\(days) days").font(.caption)
                    }
                }
                YearGridView(
                    entries: gridEntries,
                    calendarViewModel: calendarViewModel
                )
                .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
        }
    }
}
