import Foundation
import SwiftData

@Model
final class JournalEntry {
    var timestamp: Date
    var text: String
    var goalId: UUID?
    var habitId: UUID?

    init(timestamp: Date, text: String) {
        self.timestamp = timestamp
        self.text = text
    }
}
