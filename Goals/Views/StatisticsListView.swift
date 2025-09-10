import SwiftUI
import SwiftData

struct StatisticsListView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var selectedTab = Tab.hog
    
    private var completedGoalsCount: Int {
        goals.filter { $0.isCompleted }.count
    }
    
    private var totalMilestonesCompleted: Int {
        let goalMilestones = goals.flatMap { $0.milestones }.filter { $0.isCompleted }.count
        let habitMilestones = habits.flatMap { $0.milestones }.filter { $0.isCompleted }.count
        return goalMilestones + habitMilestones
    }
    
    private var goalCompletionRate: Int {
        guard !goals.isEmpty else { return 0 }
        return Int((Double(completedGoalsCount) / Double(goals.count)) * 100)
    }
    
    private var mostActiveHabit: Habit? {
        habits.max(by: { $0.daysWorked < $1.daysWorked })
    }
    
    private var totalJournalEntries: Int {
        let goalEntries = goals.flatMap { $0.journalEntries }.count
        let habitEntries = habits.flatMap { $0.journalEntries }.count
        return goalEntries + habitEntries
    }
    
    private var longestStreak: Int {
        let allTimestamps = (goals.flatMap { $0.journalEntries.map { $0.timestamp } }) + (habits.flatMap { $0.journalEntries.map { $0.timestamp } })
        guard !allTimestamps.isEmpty else { return 0 }

        let calendar = Calendar.current
        let uniqueDates = Set(allTimestamps.map { calendar.startOfDay(for: $0) }).sorted()

        var longest = 0
        var current = 0
        var previousDate: Date?

        for date in uniqueDates {
            if let prev = previousDate, calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: prev)!) {
                current += 1
            } else {
                current = 1
            }
            if current > longest {
                longest = current
            }
            previousDate = date
        }
        return longest
    }
    
    private var overallMilestoneCompletionRate: Int {
        let totalGoalMilestones = goals.flatMap { $0.milestones }.count
        let totalHabitMilestones = habits.flatMap { $0.milestones }.count
        let totalMilestones = totalGoalMilestones + totalHabitMilestones
        
        guard totalMilestones > 0 else { return 0 }
        
        return Int((Double(totalMilestonesCompleted) / Double(totalMilestones)) * 100)
    }
    
    private var mostProductiveDay: String {
        let allTimestamps = (goals.flatMap { $0.journalEntries.map { $0.timestamp } }) + (habits.flatMap { $0.journalEntries.map { $0.timestamp } })
        guard !allTimestamps.isEmpty else { return "N/A" }

        let calendar = Calendar.current
        let weekdays = allTimestamps.map { calendar.component(.weekday, from: $0) }
        
        let counts = weekdays.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        
        if let (weekday, _) = counts.max(by: { $0.value < $1.value }) {
            return calendar.weekdaySymbols[weekday - 1]
        }
        
        return "N/A"
    }
    
    enum Tab {
        case goals, hog, habits
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                HStack(spacing: 0) {
                    TabButton(
                        title: "Goals",
                        icon: "target",
                        isSelected: selectedTab == .goals,
                        position: .left
                    ) {
                        selectedTab = .goals
                    }
                    
                    TabButton(
                        title: "HoG",
                        icon: "checkmark.circle",
                        isSelected: selectedTab == .hog,
                        position: .middle
                    ) {
                        selectedTab = .hog
                    }
                    
                    TabButton(
                        title: "Habits",
                        icon: "repeat",
                        isSelected: selectedTab == .habits,
                        position: .right
                    ) {
                        selectedTab = .habits
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .hog:
                            GeneralStatisticsView(
                                goals: goals,
                                habits: habits
                            )
                            .padding(.horizontal)
                            
                            progressMetricsSection
                            
                        case .goals:
                            ForEach(goals) { goal in
                                statisticsCard(for: goal)
                            }
                            
                        case .habits:
                            ForEach(habits) { habit in
                                statisticsCard(for: habit)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Statistics")
        }
    }
    
    private var progressMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Overview")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                metricCard(title: "Goals Completed", value: "\(completedGoalsCount)")
                metricCard(title: "Milestones Done", value: "\(totalMilestonesCompleted)")
                metricCard(title: "Success Rate", value: "\(goalCompletionRate)%")
                
                if let habit = mostActiveHabit {
                    metricCard(title: "Top Habit", value: habit.title, isText: true)
                }
                
                metricCard(title: "Longest Streak", value: "\(longestStreak) Days")
                metricCard(title: "Journal Entries", value: "\(totalJournalEntries)")
                metricCard(title: "Milestone Rate", value: "\(overallMilestoneCompletionRate)%")
                metricCard(title: "Busiest Day", value: mostProductiveDay, isText: true)
            }
            .padding(.horizontal)
        }
    }
    
    private func metricCard(title: String, value: String, isText: Bool = false) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if isText {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            } else {
                Text(value)
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private func statisticsCard(for goal: Goal) -> some View {
        statisticsCard(
            title: goal.title,
            percent: Int((Double(goal.daysWorked) / 365.0) * 100),
            days: goal.daysWorked,
            gridEntries: Array(Set(goal.journalEntries.map { $0.timestamp } + goal.relatedHabits.flatMap { $0.journalEntries.map { $0.timestamp } })),
            destination: StatisticsDetailView(item: .goal(goal)),
            itemType: "Goal"
        )
        .padding(.horizontal)
    }
    
    private func statisticsCard(for habit: Habit) -> some View {
        statisticsCard(
            title: habit.title,
            percent: Int((Double(habit.daysWorked) / 365.0) * 100),
            days: habit.daysWorked,
            gridEntries: habit.journalEntries.map { $0.timestamp },
            destination: StatisticsDetailView(item: .habit(habit)),
            itemType: "Habit"
        )
        .padding(.horizontal)
    }

    private func statisticsCard<D: View>(title: String, percent: Int, days: Int, gridEntries: [Date], destination: D, itemType: String) -> some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack(spacing: 4) {
                            Image(systemName: itemType == "Goal" ? "target" : "repeat")
                                .font(.caption)
                            Text(itemType)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
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

private struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let position: Position
    let action: () -> Void
    
    enum Position {
        case left, middle, right
        
        var corners: UIRectCorner {
            switch self {
            case .left: return [.topLeft, .bottomLeft]
            case .middle: return []
            case .right: return [.topRight, .bottomRight]
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            .foregroundColor(isSelected ? .blue : .secondary)
            .cornerRadius(8, corners: position.corners)
        }
    }
}

// Add this extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
