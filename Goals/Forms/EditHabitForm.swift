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
    @State private var isPrivate: Bool

    init(habit: Habit) {
        self.habit = habit
        _title = State(initialValue: habit.title)
        _milestones = State(initialValue: habit.milestones)
        _notes = State(initialValue: habit.notes)
        _isPrivate = State(initialValue: habit.isPrivate)
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
                    Toggle("Private", isOn: $isPrivate)
                }

                Section(header: Text("Milestones")) {
                    ForEach(milestones) { milestone in
                        HStack {
                            Text(milestone.text)
                            Spacer()
                            Button(action: {
                                if let index = milestones.firstIndex(of: milestone) {
                                    milestones.remove(at: index)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
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
        habit.notes = notes
        habit.isPrivate = isPrivate
        
        // Ensure all milestones have completionCriteria set to false
        milestones.forEach { milestone in
            milestone.completionCriteria = false
        }
        habit.milestones = milestones
        
        try? modelContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}
