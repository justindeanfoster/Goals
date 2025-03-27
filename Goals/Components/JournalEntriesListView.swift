import SwiftUI

struct JournalEntriesListView: View {
    let entries: [JournalEntry]
    let onEntryTapped: (JournalEntry) -> Void
    let canEdit: (JournalEntry) -> Bool
    let onEditEntry: (JournalEntry) -> Void
    let onDeleteEntry: (JournalEntry) -> Void
    let sourceLabel: ((JournalEntry) -> String)?
    
    var body: some View {
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
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            .padding(.vertical, 4)
            .onTapGesture {
                onEntryTapped(entry)
            }
            .contextMenu {
                if canEdit(entry) {
                    Button(action: { onEditEntry(entry) }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: { onDeleteEntry(entry) }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}
