import SwiftUI
import SwiftData

struct MilestoneListView: View {
    @Environment(\.modelContext) private var modelContext
    let milestones: [Milestone]
    let selectedDate: Date
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text("Milestones")
                        .font(.headline)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.blue)
            }
            
            if isExpanded {
                ForEach(milestones) { milestone in
                    Button(action: {
                        milestone.isCompleted.toggle()
                        milestone.dateCompleted = milestone.isCompleted ? selectedDate : nil
                        try? modelContext.save()
                    }) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(milestone.isCompleted ? .green : .blue)
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(milestone.text)
                                    .font(.subheadline)
                                if let completed = milestone.dateCompleted {
                                    Text("Completed \(completed.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
}
