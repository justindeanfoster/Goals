import SwiftUI

struct JournalEntriesListView: View {
    @Environment(\.modelContext) private var modelContext
    let entries: [JournalEntry]
    let onEntryTapped: (JournalEntry) -> Void
    let canEdit: (JournalEntry) -> Bool
    let onEditEntry: (JournalEntry) -> Void
    let onDeleteEntry: (JournalEntry) -> Void
    let sourceLabel: ((JournalEntry) -> String)?
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: { 
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { 
                    isExpanded.toggle() 
                }
            }) {
                HStack {
                    Text("Journal Entries")
                        .font(.headline)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.blue)
            }
            
            if isExpanded {
                VStack(spacing: 8) {  // Add spacing between entries
                    ForEach(entries.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.text)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                            HStack {
                                Text(entry.timestamp, style: .date)
                                if let sourceLabel = sourceLabel {
                                    Text(sourceLabel(entry))
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 2, x: 0, y: 2)
                        .padding(.vertical, 4)
                        .onTapGesture {
                            onEntryTapped(entry)
                        }
                        .contextMenu {
                            if (canEdit(entry)) {
                                Button(action: { onEditEntry(entry) }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(role: .destructive, action: { onDeleteEntry(entry) }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .transition(.slide.combined(with: .opacity))
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .move(edge: .top)).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .move(edge: .bottom)).combined(with: .opacity)
                    ))
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: isExpanded ? 0.4 : 0.2, dampingFraction: 0.8), value: isExpanded)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
}
