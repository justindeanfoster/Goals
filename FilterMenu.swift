import SwiftUI

struct FilterMenu: View {
    @ObservedObject var viewModel: CalendarViewModel
    let goals: [Goal]
    let habits: [Habit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !goals.isEmpty {
                Text("Goals")
                    .font(.headline)
                ForEach(goals) { goal in
                    HStack {
                        Image(systemName: viewModel.selectedGoals.contains(goal.id) ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.selectedGoals.contains(goal.id) ? .blue : .gray)
                        Text(goal.title)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if viewModel.selectedGoals.contains(goal.id) {
                            viewModel.selectedGoals.remove(goal.id)
                        } else {
                            viewModel.selectedGoals.insert(goal.id)
                        }
                    }
                }
            }
            
            if !habits.isEmpty {
                Text("Habits")
                    .font(.headline)
                    .padding(.top, 8)
                ForEach(habits) { habit in
                    HStack {
                        Image(systemName: viewModel.selectedHabits.contains(habit.id) ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.selectedHabits.contains(habit.id) ? .blue : .gray)
                        Text(habit.title)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if viewModel.selectedHabits.contains(habit.id) {
                            viewModel.selectedHabits.remove(habit.id)
                        } else {
                            viewModel.selectedHabits.insert(habit.id)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
}
