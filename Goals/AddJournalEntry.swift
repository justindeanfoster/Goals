import SwiftUI

struct AddJournalEntryForm: View {
    @Binding var goal: Goal?
    @Binding var habit: Habit?
    @State private var newJournalEntry: String = ""
    @State private var entryDate: Date = Date()
    @State private var selectedHabits: [Habit] = []
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Entry Date", selection: $entryDate, displayedComponents: .date)
                    .padding()

                TextField("New Journal Entry", text: $newJournalEntry)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let goal = goal {
                    Section(header: Text("Related Habits")) {
                        ForEach(goal.relatedHabits) { habit in
                            HStack {
                                Text(habit.title)
                                Spacer()
                                if selectedHabits.contains(where: { $0.id == habit.id }) {
                                    Button(action: {
                                        if let index = selectedHabits.firstIndex(where: { $0.id == habit.id }) {
                                            selectedHabits.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                } else {
                                    Button(action: {
                                        selectedHabits.append(habit)
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            }.padding()
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Add Journal Entry")
            .navigationBarItems(trailing: Button("Done") {
                if !newJournalEntry.isEmpty {
                    let entry = JournalEntry(timestamp: entryDate, text: newJournalEntry)
                    if let goal = goal {
                        goal.journalEntries.append(entry)
                        for habit in selectedHabits {
                            habit.journalEntries.append(entry)
                        }
                    } else if let habit = habit {
                        habit.journalEntries.append(entry)
                    }
                    newJournalEntry = ""
                }
                presentationMode.wrappedValue.dismiss()
            })
            .background(Color(UIColor.systemBackground))
        }
    }
}
