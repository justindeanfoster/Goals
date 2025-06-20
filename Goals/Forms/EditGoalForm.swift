import SwiftUI
import SwiftData

struct EditGoalForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Query private var availableHabits: [Habit]
    @Bindable var goal: Goal
    
    // Simplify state management
    @State private var formData: GoalFormData
    
    init(goal: Goal) {
        self.goal = goal
        _formData = State(initialValue: GoalFormData(
            title: goal.title,
            deadline: goal.deadline,
            milestones: goal.milestones,
            notes: goal.notes,
            selectedHabits: Array(goal.relatedHabits),
            isPrivate: goal.isPrivate
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Title", text: $formData.title)
                    DatePicker("Deadline", selection: $formData.deadline, displayedComponents: .date)
                    Text("Notes:")
                    TextEditor(text: $formData.notes)
                        .frame(minHeight: 100)
                        .border(Color.gray, width: 1)
                        .padding(.top, 5)
                    Toggle("Private", isOn: $formData.isPrivate)
                }

                Section(header: Text("Milestones")) {
                    ForEach(formData.milestones) { milestone in
                        HStack {
                            Text(milestone.text)
                            Spacer()
                            Toggle("Completion Criteria", isOn: Binding(
                                get: { milestone.completionCriteria },
                                set: { newValue in
                                    if let index = formData.milestones.firstIndex(of: milestone) {
                                        formData.milestones[index].completionCriteria = newValue
                                    }
                                }
                            ))
                            .labelsHidden()
                            Button(action: {
                                if let index = formData.milestones.firstIndex(of: milestone) {
                                    formData.milestones.remove(at: index)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    HStack {
                        TextField("New Milestone", text: $formData.newMilestone)
                        Button(action: {
                            if !formData.newMilestone.isEmpty {
                                let newMilestone = Milestone(text: formData.newMilestone)
                                formData.milestones.append(newMilestone)
                                formData.newMilestone = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }

                Section(header: Text("Related Habits")) {
                    ForEach(availableHabits) { habit in
                        MultipleSelectionRow(title: habit.title, isSelected: formData.selectedHabits.contains(where: { $0.id == habit.id })) {
                            if let index = formData.selectedHabits.firstIndex(where: { $0.id == habit.id }) {
                                formData.selectedHabits.remove(at: index)
                            } else {
                                formData.selectedHabits.append(habit)
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
                        updateGoal()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func updateGoal() {
        goal.title = formData.title
        goal.deadline = formData.deadline
        goal.milestones = formData.milestones
        goal.notes = formData.notes
        goal.isPrivate = formData.isPrivate
        updateRelatedHabits(with: formData.selectedHabits)
        try? modelContext.save()
    }
    
    private func updateRelatedHabits(with newHabits: [Habit]) {
        // Remove old relations
        let oldRelations = goal.habitRelations
        goal.habitRelations.removeAll()
        
        for relation in oldRelations {
            if let habit = relation.habit {
                habit.goalRelations.removeAll { $0.id == relation.id }
            }
            modelContext.delete(relation)
        }
        
        // Add new relations
        for habit in newHabits {
            let relation = GoalHabitRelation(goal: goal, habit: habit)
            modelContext.insert(relation) // Insert relation first
            habit.goalRelations.append(relation)
            goal.habitRelations.append(relation)
        }
    }
}

// Add this structure to help manage form data
private struct GoalFormData {
    var title: String
    var deadline: Date
    var milestones: [Milestone]
    var notes: String
    var selectedHabits: [Habit]
    var newMilestone: String = ""
    var isPrivate: Bool
}
