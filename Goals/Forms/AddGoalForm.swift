import SwiftUI
import SwiftData

struct AddGoalForm: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var availableHabits: [Habit]

    @State private var title: String = ""
    @State private var deadline: Date = Date()
    @State private var milestones: [String] = []
    @State private var newMilestone: String = ""
    @State private var notes: String = ""
    @State private var selectedHabits: [Habit] = []
    @State private var showValidationError: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Title", text: $title)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    Text("Notes:")
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                        if notes.isEmpty {
                            Text("Write about your progress...")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
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
            .alert(isPresented: $showValidationError) {
                Alert(title: Text("Validation Error"),
                      message: Text("Please provide a title."),
                      dismissButton: .default(Text("OK")))
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .navigationTitle("Add New Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if title.isEmpty {
                            showValidationError = true
                        } else {
                            saveGoal()
                            dismiss()
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
    }
    
    private func saveGoal() {
        let newGoal = Goal(title: title, deadline: deadline, milestones: milestones, notes: notes)
        modelContext.insert(newGoal)
        
        // Create relationships after goal is inserted
        for habit in selectedHabits {
            let relation = GoalHabitRelation(goal: newGoal, habit: habit)
            modelContext.insert(relation) // Insert relation first
            habit.goalRelations.append(relation)
            newGoal.habitRelations.append(relation)
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
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .cornerRadius(10)
                    .foregroundColor(isSelected ? .blue : .primary)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
