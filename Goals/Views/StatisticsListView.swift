import SwiftUI
import SwiftData

struct StatisticsListView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var selectedTab = Tab.hog
    
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
                        // Always show GeneralStatisticsView with filtered content
                        GeneralStatisticsView(
                            goals: selectedTab == .habits ? [] : goals,
                            habits: selectedTab == .goals ? [] : habits
                        )
                        .padding(.horizontal)
                        
                        // Show filtered items based on selected tab
                        switch selectedTab {
                        case .goals:
                            ForEach(goals) { goal in
                                statisticsCard(for: goal)
                            }
                        case .hog:
                            ForEach(goals) { goal in
                                statisticsCard(for: goal)
                            }
                            ForEach(habits) { habit in
                                statisticsCard(for: habit)
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
