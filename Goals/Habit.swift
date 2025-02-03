import Foundation

class Habit: Identifiable, ObservableObject, Equatable, Codable, Hashable {
    let id: UUID
    @Published var title: String
    @Published var journalEntries: [JournalEntry]
    @Published var milestones: [String]
    @Published var notes: String

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

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, journalEntries, milestones, notes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        journalEntries = try container.decode([JournalEntry].self, forKey: .journalEntries)
        milestones = try container.decode([String].self, forKey: .milestones)
        notes = try container.decode(String.self, forKey: .notes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(journalEntries, forKey: .journalEntries)
        try container.encode(milestones, forKey: .milestones)
        try container.encode(notes, forKey: .notes)
    }
}

