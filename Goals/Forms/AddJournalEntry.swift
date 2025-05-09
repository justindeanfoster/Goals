import SwiftUI
import SwiftData

struct AddJournalEntryForm: View {
    let goal: Goal?
    let habit: Habit?
    let onCompletion: (() -> Void)?
    @State private var newJournalEntry: String = ""
    @State private var entryDate: Date
    @State private var selectedHabits: [Habit] = []
    @Environment(\.presentationMode) var presentationMode
    
    init(goal: Goal?, habit: Habit?, initialDate: Date = Date(), onCompletion: (() -> Void)? = nil) {
        self.goal = goal
        self.habit = habit
        _entryDate = State(initialValue: initialDate)
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Entry Date")
                        Spacer()
                        DatePicker("", selection: $entryDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $newJournalEntry)
                            .frame(height: 100)
                        if newJournalEntry.isEmpty {
                            Text("Write about your progress...")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                    }
                }
                

                if let goal = goal {
                    Section(header: Text("Related Habits")) {
                        ForEach(goal.relatedHabits) { habit in
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
            }
            .navigationTitle("Add Journal Entry")
            .toolbar {
                Button("Done") {
                    if (!newJournalEntry.isEmpty) {
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
                        onCompletion?()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}