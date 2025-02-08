import SwiftUI
import SwiftData

struct GoalsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]

    
    @State private var showAddGoalForm: Bool = false
    @State private var selectedGoal: Goal?
    @State private var showEditGoalForm: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(goals) { goal in
                    NavigationLink(destination: GoalDetailView(goal: goal)) {
                        VStack(alignment: .leading) {
                            Text(goal.title)
                                .font(.headline)
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
                        Button(action: {
                            selectedGoal = goal
                            showEditGoalForm = true
                        }) {
                            Label("Edit Goal", systemImage: "pencil")
                        }
                        Button(action: {
                            modelContext.delete(goal)
                            try? modelContext.save()
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
                AddGoalForm()
            }
            .sheet(item: $selectedGoal) { goal in
                EditGoalForm(goal: goal)
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
