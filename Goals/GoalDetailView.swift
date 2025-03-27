//
//  GoalDetailView.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//



import SwiftUI
import SwiftData

struct GoalDetailView: View {
    let goal: Goal  // Changed from @Binding to direct reference
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var showingAddJournalEntryForm = false
    @State private var showCalendar = false // State to toggle calendar visibility
    @State private var showingEditJournalEntry = false
    @State private var selectedEntry: JournalEntry?
    @State private var selectedDate: Date?
    @State private var dayViewData: (goals: [Goal], habits: [Habit], date: Date)?

    @State private var showingDayView = false

    var body: some View {
        VStack {
            // Header
            HStack {
                Text(goal.title)
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
                    let allJournalEntries = Array(Set(goal.journalEntries + goal.relatedHabits.flatMap { $0.journalEntries }))
                    
                    // Calendar Section
                    CalendarSectionView(
                        calendarViewModel: calendarViewModel,
                        hasJournalEntry: { date in
                            allJournalEntries.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
                        },
                        onDateSelected: { date in
                            selectedDate = date
                            showingDayView = true
                        },
                        isDeadlineDate: { date in
                            Calendar.current.isDate(date, inSameDayAs: goal.deadline)
                        },
                        showCalendar: $showCalendar
                    )
                    
                    Divider()
                    
                    // Statistics Section
                    StatisticsSectionView(statistics: [
                        StatisticsItem(label: "Days Worked:", value: "\(goal.daysWorked)"),
                        StatisticsItem(label: "Days Remaining:", value: "\(goal.daysRemaining)"),
                        StatisticsItem(label: "Total Journal Entries:", value: "\(allJournalEntries.count)")
                    ])
                    
                    Divider()
                    
                    // Notes and Milestones
                    if (!goal.notes.isEmpty) {
                        Text("Notes").font(.headline)
                        Text(goal.notes).padding(.bottom, 10)
                    }
                    
                    Text("Milestones").font(.headline)
                    ForEach(goal.milestones, id: \.self) { milestone in
                        Text("- \(milestone)")
                    }
                    
                    Divider()
                    
                    // Journal Entries
                    Text("Journal Entries").font(.headline)
                    JournalEntriesListView(
                        entries: allJournalEntries,
                        onEntryTapped: { entry in
                            selectedDate = entry.timestamp
                            showingDayView = true
                        },
                        canEdit: { entry in
                            goal.journalEntries.contains(where: { $0.id == entry.id })
                        },
                        onEditEntry: { entry in
                            selectedEntry = entry
                            showingEditJournalEntry = true
                        },
                        onDeleteEntry: { entry in
                            goal.journalEntries.removeAll { $0.id == entry.id }
                        },
                        sourceLabel: { entry in
                            if (!goal.journalEntries.contains(where: { $0.id == entry.id })) {
                                return "(via \(goal.relatedHabits.first(where: { $0.journalEntries.contains(where: { $0.id == entry.id })})?.title ?? "Unknown Habit"))"
                            }
                            return ""
                        }
                    )
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddJournalEntryForm) {
            AddJournalEntryForm(goal: goal, habit: nil)
        }
        .onChange(of: selectedDate) { _, newValue in
            if let date = newValue {
                dayViewData = (goals: [goal], habits: Array(goal.relatedHabits), date: date)
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
            }
        }
    }
}

private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}

