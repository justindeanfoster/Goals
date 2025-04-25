import SwiftUI

struct FilterMenu: View {
    @ObservedObject var viewModel: CalendarViewModel
    let goals: [Goal]
    let habits: [Habit]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Goals Column
            VStack(alignment: .leading, spacing: 8) {
                Text("Goals")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                ForEach(goals) { goal in
                    HStack {
                        Image(systemName: viewModel.selectedGoals.contains(goal.id) ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.selectedGoals.contains(goal.id) ? .blue : .gray)
                        Text(goal.title)
                            .lineLimit(1)
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
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // Habits Column
            VStack(alignment: .leading, spacing: 8) {
                Text("Habits")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                ForEach(habits) { habit in
                    HStack {
                        Image(systemName: viewModel.selectedHabits.contains(habit.id) ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.selectedHabits.contains(habit.id) ? .blue : .gray)
                        Text(habit.title)
                            .lineLimit(1)
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
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: 300)
        .fixedSize(horizontal: false, vertical: true)  // Only take up needed vertical space
        .clipped()
        .offset(x: -8) // Align to left edge
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
