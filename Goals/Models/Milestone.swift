import Foundation 
import SwiftData

@Model
final class Milestone {
    var text: String
    var isCompleted: Bool
    var dateCompleted: Date?
    
    init(text: String, isCompleted: Bool = false, dateCompleted: Date? = nil) {
        self.text = text
        self.isCompleted = isCompleted
        self.dateCompleted = dateCompleted
    }
}
