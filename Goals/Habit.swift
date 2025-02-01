import Foundation

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var journalEntries: [JournalEntry]
    var milestones: [String]
    var notes: String

    var daysWorked: Int {
        let uniqueDays = Set(journalEntries.map { Calendar.current.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }

    init(id: UUID = UUID(), title: String, journalEntries: [JournalEntry] = [], milestones: [String] = [], notes: String = "") {
        self.id = id
        self.title = title
        self.journalEntries = journalEntries
        self.milestones = milestones
        self.notes = notes
    }

    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.id == rhs.id
    }
}
