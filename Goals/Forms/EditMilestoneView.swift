import SwiftUI
import SwiftData

struct EditMilestoneView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var milestone: Milestone
    
    @State private var editedText: String
    @State private var completionCriteria: Bool   // ✅ state for toggle

    init(milestone: Milestone) {
        self.milestone = milestone
        _editedText = State(initialValue: milestone.text)
        _completionCriteria = State(initialValue: milestone.completionCriteria)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Milestone text", text: $editedText)
                }
                Section {
                    Toggle("Completion Criteria", isOn: $completionCriteria)
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
                        milestone.completionCriteria = completionCriteria   // ✅ save toggle value
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
