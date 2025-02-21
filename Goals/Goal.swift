import Foundation
import SwiftData

@Model
final class Goal {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var deadline: Date
    var milestones: [String] = []
    var notes: String = ""
    
    @Relationship(deleteRule: .cascade) 
    var journalEntries: [JournalEntry] = []
    
    @Relationship(deleteRule: .nullify) 
    var relatedHabits: [Habit] = []

    var daysWorked: Int {
        let calendar = Calendar.current
        let uniqueDates = Set(journalEntries.map { calendar.startOfDay(for: $0.timestamp) })
        let habitDates = Set(relatedHabits.flatMap { habit in
            habit.journalEntries.map { calendar.startOfDay(for: $0.timestamp) }
        })
        return Set(uniqueDates).union(habitDates).count
    }

    var daysRemaining: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(remaining, 0)
    }

    init(id: UUID = UUID(), title: String, deadline: Date, milestones: [String] = [], notes: String = "", relatedHabits: [Habit] = []) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.milestones = milestones
        self.notes = notes
        self.relatedHabits = relatedHabits
        self.journalEntries = []
    }
}

