import SwiftUI
import SwiftData

struct HabitsListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query var habits: [Habit]
    @State private var showingAddHabitForm: Bool = false
    @State private var selectedHabit: Habit?
    @State private var showEditHabitForm: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(habits) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                        VStack(alignment: .leading) {
                            Text(habit.title)
                                .font(.headline)
                            HStack {
                                Text("Days Worked: \(habit.daysWorked)")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                    .contextMenu {
                        Button(action: {
                            selectedHabit = habit
                            showEditHabitForm = true
                        }) {
                            Label("Edit Habit", systemImage: "pencil")
                        }
                        Button(action: {
                            modelContext.delete(habit)
                            try? modelContext.save()
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
                AddHabitForm()
            }
            .sheet(item: $selectedHabit) { habit in
                EditHabitForm(habit: habit)
            }
        }
    }
}
