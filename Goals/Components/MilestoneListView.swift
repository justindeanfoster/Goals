import SwiftUI

struct MilestoneListView: View {
    let milestones: [String]
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
                ForEach(milestones.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                        
                        Text(milestones[index])
                            .font(.subheadline)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
}
