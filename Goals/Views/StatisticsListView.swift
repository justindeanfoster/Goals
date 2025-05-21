import SwiftUI
import SwiftData

struct StatisticsListView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var showGoals = true
    @State private var showHabits = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    FilterButton(
                        isSelected: $showGoals,
                        title: "Goals",
                        icon: "target",
                        isLeftButton: true,
                        onToggle: { toggleFilter(true) }
                    )
                    FilterButton(
                        isSelected: $showHabits,
                        title: "Habits",
                        icon: "repeat",
                        isLeftButton: false,
                        onToggle: { toggleFilter(false) }
                    )
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollView {
                    VStack(spacing: 16) {
                        GeneralStatisticsView(
                            goals: showGoals ? goals : [],
                            habits: showHabits ? habits : []
                        )
                        .padding(.horizontal)
                        
                        if showGoals {
                            ForEach(goals) { goal in
                                statisticsCard(for: goal)
                            }
                        }
                        
                        if showHabits {
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
    
    private func toggleFilter(_ isGoals: Bool) {
        if isGoals {
            // If trying to deselect goals while habits is also deselected
            if !showHabits {
                showGoals = true // Force goals to stay selected
            } else {
                showGoals.toggle()
            }
        } else {
            // If trying to deselect habits while goals is also deselected
            if !showGoals {
                showHabits = true // Force habits to stay selected
            } else {
                showHabits.toggle()
            }
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

private struct FilterButton: View {
    @Binding var isSelected: Bool
    let title: String
    let icon: String
    let isLeftButton: Bool
    var onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color(.systemGray4) : Color.clear)
            .cornerRadius(8, corners: isLeftButton ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight])
        }
        .foregroundColor(.primary)
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
