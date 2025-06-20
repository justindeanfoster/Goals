import SwiftUI
import SwiftData

struct CombinedTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @AppStorage("showCompletedGoals") private var showCompletedGoals = false
    @AppStorage("showPrivateItems") private var showPrivateItems = false
    
    // Goal states
    @State private var showingAddGoalForm = false
    @State private var selectedGoal: Goal?
    @State private var showEditGoalForm = false
    @State private var goalToDelete: Goal?
    
    // Habit states
    @State private var showingAddHabitForm = false
    @State private var selectedHabit: Habit?
    @State private var showEditHabitForm = false
    @State private var habitToDelete: Habit?
    
    // Journal Entry states
    @State private var journalEntryTarget: JournalEntryTarget?
    
    var filteredGoals: [Goal] {
        var filtered = showCompletedGoals ? goals : goals.filter { !$0.isCompleted }
        if !showPrivateItems {
            filtered = filtered.filter { !$0.isPrivate }
        }
        return filtered
    }
    
    var filteredHabits: [Habit] {
        return showPrivateItems ? habits : habits.filter { !$0.isPrivate }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("Goals").font(.title2).bold()
                        Spacer()
                        Button(action: { showingAddGoalForm = true }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(filteredGoals) { goal in
                        goalRow(goal)
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Habits").font(.title2).bold()
                        Spacer()
                        Button(action: { showingAddHabitForm = true }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredHabits) { habit in
                            habitCell(habit)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Habits | Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showCompletedGoals.toggle() }) {
                            Label(showCompletedGoals ? "Hide Completed Goals" : "Show Completed Goals",
                                  systemImage: showCompletedGoals ? "eye.slash" : "eye")
                        }
                        Button(action: { showPrivateItems.toggle() }) {
                            Label(showPrivateItems ? "Hide Private Items" : "Show Private Items",
                                  systemImage: showPrivateItems ? "eye.slash" : "eye")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoalForm) { AddGoalForm() }
            .sheet(isPresented: $showingAddHabitForm) { AddHabitForm() }
            .sheet(item: $selectedGoal) { goal in EditGoalForm(goal: goal) }
            .sheet(item: $selectedHabit) { habit in EditHabitForm(habit: habit) }
            .sheet(item: $journalEntryTarget) { target in
                journalEntrySheet(target: target)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .alert("Delete Goal", isPresented: .constant(goalToDelete != nil), actions: {
                Button("Cancel", role: .cancel) { goalToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let goal = goalToDelete { safelyDeleteGoal(goal) }
                    goalToDelete = nil
                }
            })
            .alert("Delete Habit", isPresented: .constant(habitToDelete != nil), actions: {
                Button("Cancel", role: .cancel) { habitToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let habit = habitToDelete { safelyDeleteHabit(habit) }
                    habitToDelete = nil
                }
            })
        }
    }
    
    private func header(_ title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: action) {
                Image(systemName: "plus.circle.fill")
            }
        }
    }
    
    // MARK: - Generalized Journal Entry Sheet
    @ViewBuilder
    private func journalEntrySheet(target: JournalEntryTarget) -> some View {
        switch target {
        case .goal(let goal):
            AddJournalEntryForm(goal: goal, habit: nil)
        case .habit(let habit):
            AddJournalEntryForm(goal: nil, habit: habit)
        }
    }
    
    // MARK: - Goal Row
    private func goalRow(_ goal: Goal) -> some View {
        NavigationLink(destination: GoalDetailView(goal: goal)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                HStack {
                    Text("Days Worked: \(goal.daysWorked)")
                    Spacer()
                    Text("Days Remaining: \(goal.daysRemaining)")
                }
                .font(.caption)
                .foregroundColor(.gray)
                let currentWeekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentWeekStart)!
                        let hasDirectEntry = goal.journalEntries.contains(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: date) })
                        let hasHabitEntry = goal.relatedHabits.contains(where: { habit in
                            habit.journalEntries.contains(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: date) })
                        })
                        RoundedRectangle(cornerRadius: 2)
                            .fill(hasDirectEntry || hasHabitEntry ? Color.green : Color.gray)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(goal.isCompleted ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
            .opacity(goal.isCompleted ? 0.8 : 1.0)
            .shadow(radius: 2, x: 0, y: 2)
        }
        .contextMenu {
            Button(action: {
                journalEntryTarget = .goal(goal)
            }) {
                Label("Add Journal Entry", systemImage: "square.and.pencil")
            }
            Button(action: { selectedGoal = goal }) {
                Label("Edit Goal", systemImage: "pencil")
            }
            Button(action: { goalToDelete = goal }) {
                Label("Delete Goal", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Habit Cell
    private func habitCell(_ habit: Habit) -> some View {
        NavigationLink(destination: HabitDetailView(habit: habit)) {
            VStack(alignment: .leading) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("Days: \(habit.daysWorked)")
                    .font(.caption)
                    .foregroundColor(.gray)
                let currentWeekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentWeekStart)!
                        RoundedRectangle(cornerRadius: 2)
                            .fill(habit.journalEntries.contains(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }) ? Color.green : Color.gray)
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .shadow(radius: 2, x: 0, y: 2)
        }
        .contextMenu {
            Button(action: {
                journalEntryTarget = .habit(habit)
            }) {
                Label("Add Journal Entry", systemImage: "square.and.pencil")
            }
            Button(action: { selectedHabit = habit }) {
                Label("Edit Habit", systemImage: "pencil")
            }
            Button(action: { habitToDelete = habit }) {
                Label("Delete Habit", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Helpers

    private func safelyDeleteGoal(_ goal: Goal) {
        let relations = goal.habitRelations
        goal.habitRelations.removeAll()
        for relation in relations {
            if let habit = relation.habit {
                habit.goalRelations.removeAll { $0.id == relation.id }
            }
            modelContext.delete(relation)
        }
        modelContext.delete(goal)
    }
    
    private func safelyDeleteHabit(_ habit: Habit) {
        habit.journalEntries.forEach { modelContext.delete($0) }
        habit.goalRelations.forEach { modelContext.delete($0) }
        habit.journalEntries.removeAll()
        habit.goalRelations.removeAll()
        modelContext.delete(habit)
    }
}

// MARK: - JournalEntryTarget Enum

private enum JournalEntryTarget: Identifiable {
    case goal(Goal)
    case habit(Habit)

    var id: String {
        switch self {
        case .goal(let goal): return "goal-\(goal.id.uuidString)"
        case .habit(let habit): return "habit-\(habit.id.uuidString)"
        }
    }
}
