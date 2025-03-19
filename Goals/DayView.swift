import SwiftUI
import SwiftData

struct DayView: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let goals: [Goal]
    let habits: [Habit]
    
    private var entriesForDate: [(item: String, entries: [JournalEntry])] {
        var result: [(String, [JournalEntry])] = []
        
        // Filter goals with entries on this date
        for goal in goals {
            let entries = goal.journalEntries.filter { 
                Calendar.current.isDate($0.timestamp, inSameDayAs: date)
            }
            if !entries.isEmpty {
                result.append((goal.title, entries))
            }
        }
        
        // Filter habits with entries on this date
        for habit in habits {
            let entries = habit.journalEntries.filter {
                Calendar.current.isDate($0.timestamp, inSameDayAs: date)
            }
            if !entries.isEmpty {
                result.append((habit.title, entries))
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            Group {
                if entriesForDate.isEmpty {
                    VStack {
                        Spacer()
                        Text("You ain't do nothing today!")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(entriesForDate, id: \.item) { item, entries in
                            Section(header: Text(item)) {
                                ForEach(entries) { entry in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(entry.text)
                                            .font(.body)
                                        Text(entry.timestamp, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(date.formatted(date: .complete, time: .omitted))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
