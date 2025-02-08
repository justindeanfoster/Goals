import SwiftUI

struct GoalsListView: View {
    @Binding var goals: [Goal]
    @Binding var habits: [Habit]
    
    @State private var showAddGoalForm: Bool = false
    @State private var selectedGoal: Goal?
    @State private var showEditGoalForm: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(goals.indices, id: \.self) { index in
                    NavigationLink(destination: GoalDetailView(goal: $goals[index])) {
                        VStack(alignment: .leading) {
                            Text(goals[index].title)
                                .font(.headline)
                            HStack {
                                Text("Days Worked: \(goals[index].daysWorked)")
                                Spacer()
                                Text("Days Remaining: \(goals[index].daysRemaining)")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                    .contextMenu {
                        Button(action: {
                            selectedGoal = goals[index]
                            showEditGoalForm = true
                        }) {
                            Label("Edit Goal", systemImage: "pencil")
                        }
                        Button(action: {
                            goals.remove(at: index)
                        }) {
                            Label("Delete Goal", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                Button(action: {
                    showAddGoalForm = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddGoalForm) {
                AddGoalForm(goals: $goals, availableHabits: $habits)
            }
            .sheet(item: $selectedGoal) { goal in
                EditGoalForm(goal: Binding(
                    get: { goal },
                    set: { updatedGoal in
                        if let index = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
                            goals[index] = updatedGoal
                        }
                    }
                ), availableHabits: $habits)
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
