import SwiftUI

struct HabitsListView: View {
    @Binding var habits: [Habit]
    @State private var showingAddHabitForm: Bool = false
    @State private var selectedHabit: Habit?
    @State private var showEditHabitForm: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(habits.indices, id: \.self) { index in
                    NavigationLink(destination: HabitDetailView(habit: $habits[index])) {
                        VStack(alignment: .leading) {
                            Text(habits[index].title)
                                .font(.headline)
                            HStack {
                                Text("Days Worked: \(habits[index].daysWorked)")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                    .contextMenu {
                        Button(action: {
                            selectedHabit = habits[index]
                            showEditHabitForm = true
                        }) {
                            Label("Edit Habit", systemImage: "pencil")
                        }
                        Button(action: {
                            habits.remove(at: index)
                        }) {
                            Label("Delete Habit", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                Button(action: {
                    showingAddHabitForm = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .background(Color(UIColor.systemBackground))
            .sheet(isPresented: $showingAddHabitForm) {
                AddHabitForm(habits: $habits)
            }
            .sheet(item: $selectedHabit) { habit in
                EditHabitForm(habit: Binding(
                    get: { habit },
                    set: { updatedHabit in
                        if let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) {
                            habits[index] = updatedHabit
                        }
                    }
                ))
            }
        }
    }
}
