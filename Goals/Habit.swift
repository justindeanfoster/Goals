import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var milestones: [String] = []
    var notes: String = ""
    
    @Relationship(deleteRule: .cascade) 
    var journalEntries: [JournalEntry] = []

    var daysWorked: Int {
        let uniqueDays = Set(journalEntries.map { Calendar.current.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }

    init(title: String, milestones: [String] = [], notes: String = "") {
        self.title = title
        self.milestones = milestones
        self.notes = notes
    }
}

