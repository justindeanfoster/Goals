import Foundation

struct JournalEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let text: String

    init(id: UUID = UUID(), timestamp: Date, text: String) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        return lhs.id == rhs.id
    }
}