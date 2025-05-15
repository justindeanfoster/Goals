import SwiftUI
import SwiftData

struct EditHabitForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode

    let habit: Habit
    
    @State private var title: String
    @State private var milestones: [Milestone]  // Changed from [String]
    @State private var newMilestone: String = ""
    @State private var notes: String

    init(habit: Habit) {
        self.habit = habit
        _title = State(initialValue: habit.title)
        _milestones = State(initialValue: habit.milestones)
        _notes = State(initialValue: habit.notes)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Title", text: $title)
                    Text("Notes:")
                    TextEditor(text: $notes) // Notes input
                        .frame(minHeight: 100)
                        .border(Color.gray, width: 1)
                        .padding(.top, 5)
                }

                Section(header: Text("Milestones")) {
                    ForEach(milestones) { milestone in
                        Text(milestone.text)  // Changed from milestone to milestone.text
                    }
                    HStack {
                        TextField("New Milestone", text: $newMilestone)
                        Button(action: {
                            if !newMilestone.isEmpty {
                                let milestone = Milestone(text: newMilestone)  // Create new Milestone object
                                milestones.append(milestone)
                                newMilestone = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateHabit()
                    }
                }
            }
        }
    }
    
    private func updateHabit() {
        habit.title = title
        habit.milestones = milestones  // Direct assignment since types match
        habit.notes = notes
        try? modelContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}
