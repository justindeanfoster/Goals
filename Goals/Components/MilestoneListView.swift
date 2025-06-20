import SwiftUI
import SwiftData

struct MilestoneListView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var milestones: [Milestone]  // Changed to @Binding
    let selectedDate: Date
    @State private var isExpanded = true // Changed from false to true
    @State private var selectedMilestone: Milestone?
    let showHeader: Bool
    let isForGoal: Bool  // Add this parameter
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(milestones: Binding<[Milestone]>, selectedDate: Date, showHeader: Bool = true, isForGoal: Bool) {
        self._milestones = milestones
        self.selectedDate = selectedDate
        self.showHeader = showHeader
        self.isForGoal = isForGoal
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showHeader {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack {
                        Text("Milestones")
                            .font(.headline)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .foregroundColor(.blue)
                }
            }
            
            if isExpanded || !showHeader {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(milestones) { milestone in
                        Button(action: {
                            milestone.isCompleted.toggle()
                            milestone.dateCompleted = milestone.isCompleted ? selectedDate : nil
                            try? modelContext.save()
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(milestone.isCompleted ? .indigo : .blue)
                                        .font(.system(size: 20))
                                    
                                    Text(milestone.text)
                                        .font(.subheadline)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                if let completed = milestone.dateCompleted {
                                    Text("Completed \(completed.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .contextMenu {
                            Button {
                                selectedMilestone = milestone
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                if let index = milestones.firstIndex(of: milestone) {
                                    milestones.remove(at: index)
                                    try? modelContext.save()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedMilestone) { milestone in
            EditMilestoneView(milestone: milestone, isForGoal: isForGoal)
        }
    }
}
