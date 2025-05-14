import SwiftUI
import SwiftData

struct HabitsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var habits: [Habit]
    @State private var showingAddHabitForm = false
    @State private var selectedHabit: Habit?
    @State private var showEditHabitForm = false

    var body: some View {
        NavigationView {
            List {
                ForEach(habits) { habit in
                    habitRow(habit)
                }
            }
            .navigationTitle("Habits")
            .toolbar { addButton }
            .background(Color(UIColor.systemBackground))
            .sheet(isPresented: $showingAddHabitForm) { AddHabitForm() }
            .sheet(item: $selectedHabit) { habit in EditHabitForm(habit: habit) }
        }
    }

    // MARK: - Row

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
        .contextMenu { habitContextMenu(habit) }
    }

    // MARK: - Context Menu

    private func habitContextMenu(_ habit: Habit) -> some View {
        Group {
            Button(action: {
                selectedHabit = habit
                showEditHabitForm = true
            }) {
                Label("Edit Habit", systemImage: "pencil")
            }
            Button(action: { safelyDeleteHabit(habit) }) {
                Label("Delete Habit", systemImage: "trash")
            }
        }
    }

    // MARK: - Toolbar

    private var addButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddHabitForm = true }) {
                Image(systemName: "plus")
            }
        }
    }

    // MARK: - Helpers

    private func safelyDeleteHabit(_ habit: Habit) {
        do {
            habit.journalEntries.forEach { modelContext.delete($0) }
            habit.goalRelations.forEach { modelContext.delete($0) }
            habit.journalEntries.removeAll()
            habit.goalRelations.removeAll()
            modelContext.delete(habit)
            try modelContext.save()
        } catch {
            print("Failed to delete habit: \(error)")
        }
    }
}
