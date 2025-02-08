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

                Section(header: Text("Milestones")) {
                    ForEach(milestones, id: \ .self) { milestone in
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
                            do {
                                let newGoal = Goal(title: title, deadline: deadline, milestones: milestones, notes: notes, relatedHabits: selectedHabits)
                                modelContext.insert(newGoal)
                                try modelContext.save()
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                                showError = true
                                print("Save error: \(error)")
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
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
