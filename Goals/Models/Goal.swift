import Foundation
import SwiftData

@Model
final class Goal {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var deadline: Date
    var notes: String = ""
    var isPrivate: Bool = false
    
    @Relationship(deleteRule: .cascade) 
    var milestones: [Milestone] = []
    
    @Relationship(deleteRule: .cascade) 
    var journalEntries: [JournalEntry] = []
    
    @Relationship(deleteRule: .cascade) 
    var habitRelations: [GoalHabitRelation] = []
    
    var relatedHabits: [Habit] {
        habitRelations.compactMap { $0.habit }
    }

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

    var isCompleted: Bool {
        let criteriaMilestones = milestones.filter { $0.completionCriteria }
        guard !criteriaMilestones.isEmpty else { return false }
        return criteriaMilestones.allSatisfy { $0.isCompleted }
    }

    init(id: UUID = UUID(), title: String, deadline: Date, milestones: [String] = [], notes: String = "", relatedHabits: [Habit] = [], isPrivate: Bool = false) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.notes = notes
        self.isPrivate = isPrivate
        self.journalEntries = []
        self.milestones = milestones.map { Milestone(text: $0) }
        self.habitRelations = relatedHabits.map { habit in
            GoalHabitRelation(goal: self, habit: habit)
        }
    }
}

