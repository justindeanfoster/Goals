import SwiftUI
import SwiftData

struct EditGoalForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query private var availableHabits: [Habit]
    
    let goal: Goal
    
    @State private var title: String
    @State private var deadline: Date
    @State private var milestones: [String]
    @State private var newMilestone: String = ""
    @State private var notes: String
    @State private var selectedHabits: [Habit]

    init(goal: Goal) {
        self.goal = goal
        _title = State(initialValue: goal.title)
        _deadline = State(initialValue: goal.deadline)
        _milestones = State(initialValue: goal.milestones)
        _notes = State(initialValue: goal.notes)
        _selectedHabits = State(initialValue: goal.relatedHabits)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Title", text: $title)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    Text("Notes:")
                    TextEditor(text: $notes) // Notes input
                        .frame(minHeight: 100)
                        .border(Color.gray, width: 1)
                        .padding(.top, 5)
                }

                Section(header: Text("Milestones")) {
                    ForEach(milestones, id: \.self) { milestone in
                        Text(milestone)
                    }
                    HStack {
                        TextField("New Milestone", text: $newMilestone)
                        Button(action: {
                            if !newMilestone.isEmpty {
                                milestones.append(newMilestone)
                                newMilestone = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }

                Section(header: Text("Related Habits")) {
                    ForEach(availableHabits) { habit in
                        MultipleSelectionRow(title: habit.title, isSelected: selectedHabits.contains(where: { $0.id == habit.id })) {
                            if let index = selectedHabits.firstIndex(where: { $0.id == habit.id }) {
                                selectedHabits.remove(at: index)
                            } else {
                                selectedHabits.append(habit)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        goal.title = title
                        goal.deadline = deadline
                        goal.milestones = milestones
                        goal.notes = notes
                        goal.relatedHabits = selectedHabits
                        try? modelContext.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
