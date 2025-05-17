import SwiftUI

struct CollapsibleJournalEntriesView: View {
    let entries: [JournalEntry]
    let onEntryTapped: (JournalEntry) -> Void
    let canEdit: (JournalEntry) -> Bool
    let onEditEntry: (JournalEntry) -> Void
    let onDeleteEntry: (JournalEntry) -> Void
    let sourceLabel: ((JournalEntry) -> String)?
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text("Journal Entries")
                        .font(.headline)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.blue)
            }
            
            if isExpanded {
                JournalEntriesListView(
                    entries: entries,
                    onEntryTapped: onEntryTapped,
                    canEdit: canEdit,
                    onEditEntry: onEditEntry,
                    onDeleteEntry: onDeleteEntry,
                    sourceLabel: sourceLabel
                )
            }
        }
    }
}
