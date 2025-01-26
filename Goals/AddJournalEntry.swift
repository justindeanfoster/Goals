import SwiftUI

struct AddJournalEntryForm: View {
    @Binding var goal: Goal
    @State private var newJournalEntry: String = ""
    @State private var entryDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Entry Date", selection: $entryDate, displayedComponents: .date)
                    .padding()

                TextField("New Journal Entry", text: $newJournalEntry)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Spacer()
            }
            .navigationTitle("Add Journal Entry")
            .navigationBarItems(trailing: Button("Done") {
                if (!newJournalEntry.isEmpty) {
                    let entry = JournalEntry(timestamp: entryDate, text: newJournalEntry)
                    goal.journalEntries.append(entry)
                    newJournalEntry = ""
                }
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
