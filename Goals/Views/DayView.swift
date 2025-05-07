import SwiftUI
import SwiftData

struct DayView: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let goals: [Goal]
    let habits: [Habit]
    @State private var entries: [(String, [JournalEntry])]
    @State private var showingAddJournalEntryForm = false

    init(date: Date, goals: [Goal], habits: [Habit]) {
        self.date = date
        self.goals = goals
        self.habits = habits
        // Initialize entries immediately
        self._entries = State(initialValue: DayView.loadEntries(for: date, goals: goals, habits: habits))
    }

    var body: some View {
        NavigationView {
            Group {
                if entries.isEmpty {
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
                        ForEach(entries, id: \.0) { item, entries in
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddJournalEntryForm = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
        .sheet(isPresented: $showingAddJournalEntryForm) {
            AddJournalEntryForm(
                goal: goals.first,
                habit: habits.first,
                initialDate: date,
                onCompletion: {
                    dismiss()
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            entries = DayView.loadEntries(for: date, goals: goals, habits: habits)
        }
    }

    private static func loadEntries(for date: Date, goals: [Goal], habits: [Habit]) -> [(String, [JournalEntry])] {
        var result: [(String, [JournalEntry])] = []
        let calendar = Calendar.current

        // Filter goals with entries on this date
        for goal in goals {
            let entries = goal.journalEntries.filter {
                calendar.isDate($0.timestamp, inSameDayAs: date)
            }
            if !entries.isEmpty {
                result.append((goal.title, entries))
            }
        }

        // Filter habits with entries on this date
        for habit in habits {
            let entries = habit.journalEntries.filter {
                calendar.isDate($0.timestamp, inSameDayAs: date)
            }
            if !entries.isEmpty {
                result.append((habit.title, entries))
            }
        }

        return result
    }
}
