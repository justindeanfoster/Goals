import SwiftUI

struct EditHabitForm: View {
    @Binding var habit: Habit
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String
    @State private var milestones: [String]
    @State private var newMilestone: String = ""
    @State private var notes: String

    init(habit: Binding<Habit>) {
        _habit = habit
        _title = State(initialValue: habit.wrappedValue.title)
        _milestones = State(initialValue: habit.wrappedValue.milestones)
        _notes = State(initialValue: habit.wrappedValue.notes)
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
            .navigationTitle("Edit Habit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        habit.title = title
                        habit.milestones = milestones
                        habit.notes = notes
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
