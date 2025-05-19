import SwiftUI
import SwiftData

struct EditMilestoneView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var milestone: Milestone
    @State private var editedText: String

    init(milestone: Milestone) {
        self.milestone = milestone
        _editedText = State(initialValue: milestone.text)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Milestone text", text: $editedText)
                }
            }
            .navigationTitle("Edit Milestone")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        milestone.text = editedText
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
