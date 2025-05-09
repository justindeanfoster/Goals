import SwiftUI
import SwiftData

struct HabitDetailView: View {
    let habit: Habit
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var showingAddJournalEntryForm = false
    @State private var showCalendar = false
    @State private var showingEditJournalEntry = false
    @State private var selectedEntry: JournalEntry?
    @State private var selectedDate: Date?
    @State private var dayViewData: (goals: [Goal], habits: [Habit], date: Date)?
    @State private var showingDayView = false

    var body: some View {
        VStack {
            // Header
            HStack {
                Text(habit.title)
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: { showingAddJournalEntryForm = true }) {
                    Image(systemName: "plus").font(.title)
                }
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading) {
                    // Calendar Section
                    CalendarSectionView(
                        calendarViewModel: calendarViewModel,
                        hasJournalEntry: { date in
                            habit.journalEntries.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
                        },
                        onDateSelected: { date in
                            selectedDate = date
                            showingDayView = true
                        },
                        isDeadlineDate: nil,
                        showCalendar: $showCalendar
                    )
                    .onChange(of: showCalendar) { oldValue, newValue in
                        if (!newValue) {
                            // Reset to current week when collapsing
                            calendarViewModel.currentMonth = Date()
                        }
                    }
                    
                    Divider()

                    // Notes Section
                    if !habit.notes.isEmpty {
                        CollapsibleSectionView(title: "Notes", content: habit.notes)
                        Divider()
                    }
                    
                    // Milestones Section
                    if !habit.milestones.isEmpty {
                        MilestoneListView(milestones: habit.milestones)
                        Divider()
                    }
                    
                    // Journal Entries Section
                    Text("Journal Entries").font(.headline)
                    JournalEntriesListView(
                        entries: calendarViewModel.getEntriesForCurrentTimeframe(
                            habit.journalEntries, 
                            isExpanded: showCalendar
                        ),
                        onEntryTapped: { entry in
                            selectedDate = entry.timestamp
                            showingDayView = true
                        },
                        canEdit: { _ in true },
                        onEditEntry: { entry in
                            selectedEntry = entry
                            showingEditJournalEntry = true
                        },
                        onDeleteEntry: { entry in
                            habit.journalEntries.removeAll { $0.id == entry.id }
                        },
                        sourceLabel: nil
                    )
                    Divider()
                    
                    // Statistics Section
                    VStack(alignment: .leading, spacing: 15) {
                        NavigationLink(destination: StatisticsDetailView(item: .habit(habit))) {
                            Text("Statistics")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        StatisticsSectionView(statistics: [
                            StatisticRow(label: "Days Worked:", value: "\(habit.daysWorked)")
                        ])
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddJournalEntryForm) {
            AddJournalEntryForm(goal: nil, habit: habit)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            if let date = newValue {
                dayViewData = (goals: [], habits: [habit], date: date)
                showingDayView = true
            }
        }
        .sheet(isPresented: $showingDayView) {
            if let data = dayViewData {
                DayView(date: data.date, goals: data.goals, habits: data.habits)
            }
        }
        .sheet(isPresented: $showingEditJournalEntry) {
            if let entry = selectedEntry {
                EditJournalEntryView(entry: entry)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
