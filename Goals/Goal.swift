import Foundation

struct Goal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var journalEntries: [JournalEntry]
    var deadline: Date
    var milestones: [String]
    var notes: String

    var daysWorked: Int {
        let uniqueDays = Set(journalEntries.map { Calendar.current.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }

    var daysRemaining: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(remaining, 0)
    }

    init(id: UUID = UUID(), title: String, journalEntries: [JournalEntry] = [], deadline: Date, milestones: [String] = [], notes: String = "") {
        self.id = id
        self.title = title
        self.journalEntries = journalEntries
        self.deadline = deadline
        self.milestones = milestones
        self.notes = notes
    }

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        return lhs.id == rhs.id
    }
}

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let text: String

    init(id: UUID = UUID(), timestamp: Date, text: String) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
    }
}
