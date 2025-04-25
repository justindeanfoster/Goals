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

    @Relationship(deleteRule: .cascade) 
    var goalRelations: [GoalHabitRelation] = []
    
    var relatedGoals: [Goal] {
        goalRelations.compactMap { $0.goal }
    }

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

