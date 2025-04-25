import Foundation
import SwiftData

@Model
final class GoalHabitRelation {
    @Attribute(.unique) var id: UUID = UUID()
    
    @Relationship(deleteRule: .cascade) var goal: Goal?
    @Relationship(deleteRule: .cascade) var habit: Habit?
    
    init(goal: Goal, habit: Habit) {
        self.goal = goal
        self.habit = habit
    }
}
