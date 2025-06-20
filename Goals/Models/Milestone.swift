import Foundation 
import SwiftData

@Model
final class Milestone {
    var text: String
    var isCompleted: Bool
    var dateCompleted: Date?
    var completionCriteria: Bool
    
    init(text: String, isCompleted: Bool = false, dateCompleted: Date? = nil, completionCriteria: Bool = false) {
        self.text = text
        self.isCompleted = isCompleted
        self.dateCompleted = dateCompleted
        self.completionCriteria = completionCriteria
    }
}
