import Foundation

class Goal: Identifiable, ObservableObject, Equatable, Codable {
    let id: UUID
    @Published var title: String
    @Published var journalEntries: [JournalEntry] = []
    @Published var deadline: Date
    @Published var milestones: [String]
    @Published var notes: String
    @Published var relatedHabits: [Habit] = []

    var daysWorked: Int {
        let uniqueDays = Set(journalEntries.map { Calendar.current.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }

    var daysRemaining: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(remaining, 0)
    }

    init(id: UUID = UUID(), title: String, journalEntries: [JournalEntry] = [], deadline: Date, milestones: [String] = [], notes: String = "", relatedHabits: [Habit] = []) {
        self.id = id
        self.title = title
        self.journalEntries = journalEntries
        self.deadline = deadline
        self.milestones = milestones
        self.notes = notes
        self.relatedHabits = relatedHabits
    }

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, title, journalEntries, deadline, milestones, notes, relatedHabits
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        journalEntries = try container.decode([JournalEntry].self, forKey: .journalEntries)
        deadline = try container.decode(Date.self, forKey: .deadline)
        milestones = try container.decode([String].self, forKey: .milestones)
        notes = try container.decode(String.self, forKey: .notes)
        relatedHabits = try container.decode([Habit].self, forKey: .relatedHabits)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(journalEntries, forKey: .journalEntries)
        try container.encode(deadline, forKey: .deadline)
        try container.encode(milestones, forKey: .milestones)
        try container.encode(notes, forKey: .notes)
        try container.encode(relatedHabits, forKey: .relatedHabits)
    }
}

