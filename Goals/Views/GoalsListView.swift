import SwiftUI
import SwiftData

struct GoalsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @State private var showAddGoalForm = false
    @State private var selectedGoal: Goal?
    @State private var showEditGoalForm = false
    @State private var goalToDelete: Goal? // Add this state
    var isEmbedded: Bool = false

    var body: some View {
        Group {
            if isEmbedded {
                goalsList
            } else {
                NavigationView {
                    goalsList
                        .navigationTitle("Goals")
                        .toolbar { addButton }
                }
            }
        }
        .sheet(isPresented: $showAddGoalForm) { AddGoalForm() }
        .sheet(item: $selectedGoal) { goal in EditGoalForm(goal: goal) }
        .alert("Delete Goal", isPresented: .constant(goalToDelete != nil), actions: {
            Button("Cancel", role: .cancel) {
                goalToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let goal = goalToDelete {
                    safelyDeleteGoal(goal)
                }
                goalToDelete = nil
            }
        })
        .background(Color(UIColor.systemBackground))
    }

    private var goalsList: some View {
        List {
            ForEach(goals) { goal in
                goalRow(goal)
            }
        }
    }

    // MARK: - Row

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
        .contextMenu { goalContextMenu(goal) }
    }

    // MARK: - Context Menu

    private func goalContextMenu(_ goal: Goal) -> some View {
        Group {
            Button(action: {
                selectedGoal = goal
                showEditGoalForm = true
            }) {
                Label("Edit Goal", systemImage: "pencil")
            }
            Button(action: { goalToDelete = goal }) {  // Update this line
                Label("Delete Goal", systemImage: "trash")
            }
        }
    }

    // MARK: - Toolbar

    private var addButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showAddGoalForm = true }) {
                Image(systemName: "plus")
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
}
