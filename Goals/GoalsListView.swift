import SwiftUI

struct GoalsListView: View {
    @Binding var goals: [Goal]
    @Binding var habits: [Habit]
    
    @State private var showAddGoalForm: Bool = false

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
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                Button(action: {
                    showAddGoalForm = true
                }) {
                    Image(systemName: "plus")
                }
            }.sheet(isPresented: $showAddGoalForm) {
                AddGoalForm(goals: $goals, availableHabits: $habits)
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
