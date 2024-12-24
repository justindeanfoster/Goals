// Goals Tracker App in Swift (Calendar View with Month Navigation)
import SwiftUI

struct Goal: Identifiable {
    let id = UUID()
    var title: String
    var journalEntries: [JournalEntry] = []
    var deadline: Date
    var milestones: [String]
    var notes: String = "" // New field for notes
    var daysWorked: Int {
        let uniqueDays = Set(journalEntries.map { Calendar.current.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }
    var daysRemaining: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(remaining, 0)
    }
}

struct JournalEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let text: String
}

struct DayProgress: Identifiable {
    let id = UUID()
    let date: Date
    let goalsWorkedOn: Int
    let totalGoals: Int
    var progress: Double {
        return totalGoals > 0 ? Double(goalsWorkedOn) / Double(totalGoals) : 0
    }
}

struct ContentView: View {
    @State private var goals: [Goal] = [
        Goal(title: "Learn Swift", deadline: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, milestones: ["Finish basics", "Build a project"]),
        Goal(title: "Exercise", deadline: Calendar.current.date(byAdding: .day, value: 20, to: Date())!, milestones: ["Join a gym", "Run 5k"]),
        Goal(title: "Read a Book", deadline: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, milestones: ["Read Chapter 1", "Complete Half"])
    ]

    @State private var showAddGoalForm = false

    var body: some View {
        TabView {
            GoalsListView(goals: $goals, showAddGoalForm: $showAddGoalForm)
                .tabItem {
                    Label("Goals", systemImage: "list.bullet")
                }

            CalendarView(goals: goals)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .sheet(isPresented: $showAddGoalForm) {
            AddGoalForm(goals: $goals)
        }
    }
}

struct GoalsListView: View {
    @Binding var goals: [Goal]
    @Binding var showAddGoalForm: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(goals.indices, id: \ .self) { index in
                    NavigationLink(destination: GoalDetailView(goal: $goals[index])) {
                        VStack(alignment: .leading) {
                            Text(goals[index].title)
                                .font(.headline)
                            HStack {
                                Text("Days Worked: \(goals[index].daysWorked)")
                                Spacer()
                                Text("Days Remaining: \(goals[index].daysRemaining)")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                Button(action: {
                    showAddGoalForm = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct GoalDetailView: View {
    @Binding var goal: Goal
    @State private var newJournalEntry: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text(goal.title)
                .font(.largeTitle)
                .padding(.bottom, 10)

            if !goal.notes.isEmpty {
                Text("Notes")
                    .font(.headline)
                Text(goal.notes)
                    .padding(.bottom, 10)
            }

            Text("Milestones")
                .font(.headline)
            ForEach(goal.milestones, id: \ .self) { milestone in
                Text("- \(milestone)")
            }

            Divider()

            Text("Journal Entries")
                .font(.headline)
            List {
                ForEach(goal.journalEntries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.text)
                        Text(entry.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            HStack {
                TextField("New Journal Entry", text: $newJournalEntry)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    if !newJournalEntry.isEmpty {
                        let entry = JournalEntry(timestamp: Date(), text: newJournalEntry)
                        goal.journalEntries.append(entry)
                        newJournalEntry = ""
                    }
                }) {
                    Text("Add")
                }
            }
            .padding(.vertical)

            Spacer()
        }
        .padding()
        .navigationTitle("Goal Details")
    }
}

struct AddGoalForm: View {
    @Binding var goals: [Goal]
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var deadline: Date = Date()
    @State private var milestones: [String] = []
    @State private var newMilestone: String = ""
    @State private var notes: String = "" // New state for notes

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Title", text: $title)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    Text("Notes:")
                    TextEditor(text: $notes) // Notes input
                        .frame(minHeight: 100)
                        .border(Color.gray, width: 1)
                        .padding(.top, 5)
                }

                Section(header: Text("Milestones")) {
                    ForEach(milestones, id: \ .self) { milestone in
                        Text(milestone)
                    }
                    HStack {
                        TextField("New Milestone", text: $newMilestone)
                        Button(action: {
                            if !newMilestone.isEmpty {
                                milestones.append(newMilestone)
                                newMilestone = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Add New Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newGoal = Goal(title: title, deadline: deadline, milestones: milestones, notes: notes)
                        goals.append(newGoal)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct CalendarView: View {
    let goals: [Goal]

    @State private var currentMonth: Date = Date()

    private var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth)) ?? Date()
    }

    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
    }

    private func goalsWorkedOn(for date: Date) -> Double {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let goalsWorkedOn = goals.filter { goal in
            goal.journalEntries.contains(where: {
                Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay)
            })
        }
        return goals.isEmpty ? 0 : Double(goalsWorkedOn.count) / Double(goals.count)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(startOfMonth, formatter: monthYearFormatter)
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.bottom)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(0..<daysInMonth, id: \ .self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: startOfMonth)!
                    let progress = goalsWorkedOn(for: date)

                    Circle()
                        .fill(color(for: progress))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text(Calendar.current.component(.day, from: date).description)
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(.top)
        .navigationTitle("Calendar Progress")
    }

    private func color(for progress: Double) -> Color {
        switch progress {
        case 0:
            return .gray
        case 0..<0.5:
            return .red
        case 0.5..<1:
            return .orange
        default:
            return .green
        }
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
