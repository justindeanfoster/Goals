import SwiftUI
import SwiftData

struct AddMilestoneView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let isForGoal: Bool
    let onSave: (Milestone) -> Void
    @State private var text: String = ""
    @State private var completionCriteria: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Milestone text", text: $text)
                        .textFieldStyle(DefaultTextFieldStyle())
                    if isForGoal {
                        Toggle("Completion Criteria", isOn: $completionCriteria)
                    }
                }
            }
            .navigationTitle("Add Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if !text.isEmpty {
                            let milestone = Milestone(text: text, completionCriteria: completionCriteria)
                            onSave(milestone)
                            dismiss()
                        }
                    }
                    .disabled(text.isEmpty)
                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
