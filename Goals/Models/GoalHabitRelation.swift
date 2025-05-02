import Foundation
import SwiftData

@Model
final class GoalHabitRelation {
    @Attribute(.unique) var id: UUID = UUID()
    
    @Relationship(deleteRule: .nullify) var goal: Goal?
    @Relationship(deleteRule: .nullify) var habit: Habit?
    
    init(goal: Goal, habit: Habit) {
        self.goal = goal
        self.habit = habit
    }
}
