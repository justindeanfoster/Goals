import SwiftUI

struct EditJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var entry: JournalEntry
    @State private var editedText: String
    @State private var editedDate: Date
    
    init(entry: JournalEntry) {
        self.entry = entry
        _editedText = State(initialValue: entry.text)
        _editedDate = State(initialValue: entry.timestamp)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Entry Date")
                        Spacer()
                        DatePicker("", selection: $editedDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $editedText)
                            .frame(height: 100)
                        if editedText.isEmpty {
                            Text("Write about your progress...")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Edit Journal Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        entry.text = editedText
                        entry.timestamp = editedDate
                        dismiss()
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
