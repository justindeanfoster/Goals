import SwiftUI

struct EditGoalForm: View {
    @Binding var goal: Goal
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String
    @State private var deadline: Date
    @State private var milestones: [String]
    @State private var newMilestone: String = ""
    @State private var notes: String
    @State private var selectedHabits: [Habit]
    @State private var availableHabits: [Habit] = [] // This should be passed or fetched from a data source

    init(goal: Binding<Goal>) {
        _goal = goal
        _title = State(initialValue: goal.wrappedValue.title)
        _deadline = State(initialValue: goal.wrappedValue.deadline)
        _milestones = State(initialValue: goal.wrappedValue.milestones)
        _notes = State(initialValue: goal.wrappedValue.notes)
        _selectedHabits = State(initialValue: goal.wrappedValue.relatedHabits)
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
