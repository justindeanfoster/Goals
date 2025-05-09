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
    @State private var timeframeUpdateTrigger = Date()

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
                    .onChange(of: showCalendar) { oldValue, newValue in
                        if (!newValue) {
                            // Reset to current week when collapsing
                            calendarViewModel.currentMonth = Date()
                        }
                    }
                    
                    Divider()

                    // Notes Section
                    if (!goal.notes.isEmpty) {
                        CollapsibleSectionView(title: "Notes", content: goal.notes)
                        Divider()
                    }
                    
                    // Milestones Section
                    if !goal.milestones.isEmpty {
                        MilestoneListView(milestones: goal.milestones)
                        Divider()
                    }
                    
                    // Journal Entries Section
                    Text("Journal Entries").font(.headline)
                    JournalEntriesListView(
                        entries: calendarViewModel.getEntriesForCurrentTimeframe(
                            allJournalEntries, 
                            isExpanded: showCalendar
                        ),
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
                    .id(timeframeUpdateTrigger)
                    Divider()
                    
                    // Statistics Section
                    VStack(alignment: .leading, spacing: 15) {
                        NavigationLink(destination: StatisticsDetailView(item: .goal(goal))) {
                            Text("Statistics")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        StatisticsSectionView(statistics: [
                            StatisticRow(label: "Days Worked:", value: "\(goal.daysWorked)"),
                            StatisticRow(label: "Days Remaining:", value: "\(goal.daysRemaining)"),
                            StatisticRow(label: "Total Journal Entries:", value: "\(allJournalEntries.count)")
                        ])
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    Divider()
                    
                    // Related Habits Tags
                    if (!goal.relatedHabits.isEmpty) {
                        Text("Related Habits")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(goal.relatedHabits) { habit in
                                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                                        Text(habit.title)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddJournalEntryForm) {
            AddJournalEntryForm(goal: goal, habit: nil)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
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
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: showCalendar) { _, _ in
            timeframeUpdateTrigger = Date()
        }
        .onChange(of: calendarViewModel.timeframeChanged) { _, _ in
            timeframeUpdateTrigger = Date()
        }
    }
}

private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}

