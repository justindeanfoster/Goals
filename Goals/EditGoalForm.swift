import SwiftUI

struct EditGoalForm: View {
    @Binding var goal: Goal
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String
    @State private var deadline: Date
    @State private var milestones: [String]
    @State private var newMilestone: String = ""
    @State private var notes: String

    init(goal: Binding<Goal>) {
        _goal = goal
        _title = State(initialValue: goal.wrappedValue.title)
        _deadline = State(initialValue: goal.wrappedValue.deadline)
        _milestones = State(initialValue: goal.wrappedValue.milestones)
        _notes = State(initialValue: goal.wrappedValue.notes)
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
