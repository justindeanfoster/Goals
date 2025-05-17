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
                if entries.isEmpty && getMilestonesForDate(date).isEmpty && !hasDeadlinesForDate(date) {
                    VStack {
                        Spacer()
                        Text("You ain't do nothing today!")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                } else {
                    List {
                        if hasDeadlinesForDate(date) {
                            Section(header: Text("Deadlines")) {
                                ForEach(getDeadlinesForDate(date)) { goal in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(goal.title)
                                            .font(.subheadline)
                                            .bold()
                                        Text("Goal Deadline")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        // Show milestones if any exist
                        if !getMilestonesForDate(date).isEmpty {
                            Section(header: Text("Milestones Completed")) {
                                ForEach(getMilestonesForDate(date), id: \.id) { milestone in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(milestone.text)
                                            .font(.subheadline)
                                            .bold()
                                        Text(getMilestoneSource(milestone) ?? "Unknown Source")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteMilestone(milestone)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button {
                                            milestone.text = milestone.text // Trigger edit sheet here
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Show entries if any exist
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

    private func getMilestonesForDate(_ date: Date) -> [Milestone] {
        var milestones: [Milestone] = []
        
        for goal in goals {
            milestones.append(contentsOf: goal.milestones.filter { milestone in
                guard let completedDate = milestone.dateCompleted else { return false }
                return Calendar.current.isDate(completedDate, inSameDayAs: date)
            })
        }
        
        for habit in habits {
            milestones.append(contentsOf: habit.milestones.filter { milestone in
                guard let completedDate = milestone.dateCompleted else { return false }
                return Calendar.current.isDate(completedDate, inSameDayAs: date)
            })
        }
        
        return milestones
    }
    
    private func getMilestoneSource(_ milestone: Milestone) -> String? {
        if let goal = goals.first(where: { $0.milestones.contains(where: { $0.id == milestone.id }) }) {
            return "\(goal.title) (Goal)"
        }
        if let habit = habits.first(where: { $0.milestones.contains(where: { $0.id == milestone.id }) }) {
            return "\(habit.title) (Habit)"
        }
        return nil
    }
    
    private func deleteMilestone(_ milestone: Milestone) {
        for goal in goals {
            if let index = goal.milestones.firstIndex(where: { $0.id == milestone.id }) {
                goal.milestones.remove(at: index)
                return
            }
        }
        for habit in habits {
            if let index = habit.milestones.firstIndex(where: { $0.id == milestone.id }) {
                habit.milestones.remove(at: index)
                return
            }
        }
    }
    
    private func hasDeadlinesForDate(_ date: Date) -> Bool {
        goals.contains { Calendar.current.isDate($0.deadline, inSameDayAs: date) }
    }
    
    private func getDeadlinesForDate(_ date: Date) -> [Goal] {
        goals.filter { Calendar.current.isDate($0.deadline, inSameDayAs: date) }
    }
}
