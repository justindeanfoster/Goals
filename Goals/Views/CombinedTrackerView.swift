import SwiftUI
import SwiftData

struct CombinedTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    
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
    
    var body: some View {
        NavigationView {
            List {
                Section(header: header("Goals", action: { showingAddGoalForm = true })) {
                    ForEach(goals) { goal in
                        goalRow(goal)
                    }
                }
                
                Section(header: header("Habits", action: { showingAddHabitForm = true })) {
                    ForEach(habits) { habit in
                        habitRow(habit)
                    }
                }
            }
            .navigationTitle("Habits Over Goals")
            .sheet(isPresented: $showingAddGoalForm) { AddGoalForm() }
            .sheet(isPresented: $showingAddHabitForm) { AddHabitForm() }
            .sheet(item: $selectedGoal) { goal in EditGoalForm(goal: goal) }
            .sheet(item: $selectedHabit) { habit in EditHabitForm(habit: habit) }
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
    
    // MARK: - Goal Row
    private func goalRow(_ goal: Goal) -> some View {
        NavigationLink(destination: GoalDetailView(goal: goal)) {
            VStack(alignment: .leading) {
                Text(goal.title).font(.headline)
                HStack {
                    Text("Days Worked: \(goal.daysWorked)")
                    Spacer()
                    Text("Days Remaining: \(goal.daysRemaining)")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding(.vertical, 5)
        }
        .contextMenu {
            Button(action: { selectedGoal = goal }) {
                Label("Edit Goal", systemImage: "pencil")
            }
            Button(action: { goalToDelete = goal }) {
                Label("Delete Goal", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Habit Row
    private func habitRow(_ habit: Habit) -> some View {
        NavigationLink(destination: HabitDetailView(habit: habit)) {
            VStack(alignment: .leading) {
                Text(habit.title).font(.headline)
                HStack {
                    Text("Days Worked: \(habit.daysWorked)")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding(.vertical, 5)
        }
        .contextMenu {
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
