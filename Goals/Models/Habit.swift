import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var notes: String = ""
    
    @Relationship(deleteRule: .cascade) 
    var milestones: [Milestone] = []
    
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
        self.notes = notes
        self.milestones = milestones.map { Milestone(text: $0) }
    }
}

