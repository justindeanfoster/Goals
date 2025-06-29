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
    @State private var entries: [JournalEntry] = []

    @State private var showingDayView = false
    @State private var isExpanded = false

    // MARK: - Computed Properties

    private var allJournalEntries: [JournalEntry] {
        Array(Set(goal.journalEntries + goal.relatedHabits.flatMap { $0.journalEntries }))
    }
    private var currentTimeframeEntries: [JournalEntry] {
        calendarViewModel.getEntriesForCurrentTimeframe(allJournalEntries, isExpanded: showCalendar)
    }

    // MARK: - Body

    var body: some View {
        VStack {
            headerSection
            ScrollView {
                VStack(alignment: .leading) {
                    calendarSection
                    notesSection
                    journalEntriesSection
                    statisticsSection
                    relatedHabitsSection
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddJournalEntryForm) { addJournalEntrySheet }
        .onChange(of: selectedDate) { _, newValue in handleSelectedDateChange(newValue) }
        .sheet(isPresented: $showingDayView) { dayViewSheet }
        .onChange(of: showCalendar) { _, _ in timeframeUpdateTrigger = Date() }
        .onChange(of: calendarViewModel.timeframeChanged) { _, _ in timeframeUpdateTrigger = Date() }
        .onAppear { entries = allJournalEntries }
        .sheet(item: $selectedEntry) { entry in editJournalEntrySheet(entry) }
    }

    // MARK: - Sections

    private var headerSection: some View {
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
    }

    private var calendarSection: some View {
        CalendarSectionView(
            calendarViewModel: calendarViewModel,
            onDateSelected: { date in
                selectedDate = date
                showingDayView = true
            },
            isDeadlineDate: { date in
                Calendar.current.isDate(date, inSameDayAs: goal.deadline)
            },
            milestoneCompletions: { date in
                goal.milestones.contains { milestone in
                    guard let completedDate = milestone.dateCompleted else { return false }
                    return Calendar.current.isDate(completedDate, inSameDayAs: date)
                }
            },
            getDateColor: { date in
                hasJournalEntryForDate(date) ? .green : .gray
            },
            showCalendar: $showCalendar
        )
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2, x: 0, y: 2)
        .onChange(of: showCalendar) { oldValue, newValue in
            if (!newValue) {
                // Reset to current week when collapsing
                calendarViewModel.currentMonth = Date()
            }
        }
    }

    private var notesSection: some View {
        Group {
            if !goal.notes.isEmpty || !goal.milestones.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: { withAnimation { isExpanded.toggle() } }) {
                        HStack {
                            Text("Notes")
                                .font(.headline)
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    if isExpanded {
                        if !goal.notes.isEmpty {
                            Text(goal.notes)
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        if !goal.milestones.isEmpty {
                            Text("Milestones")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            MilestoneListView(
                                milestones: .init(
                                    get: { goal.milestones },
                                    set: { goal.milestones = $0 }
                                ),
                                selectedDate: calendarViewModel.selectedDate,
                                showHeader: false
                            )
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
    }

    private var journalEntriesSection: some View {
        Group {
            Divider()

            JournalEntriesListView(
                entries: currentTimeframeEntries,
                onEntryTapped: { entry in
                    selectedDate = entry.timestamp
                    showingDayView = true
                },
                canEdit: entryBelongsToGoalOrHabits,
                onEditEntry: { entry in
                    selectedEntry = entry
                    showingEditJournalEntry = true
                },
                onDeleteEntry: deleteEntry,
                sourceLabel: getSourceLabel
            )
            .id(timeframeUpdateTrigger)
            .background(Color(.systemBackground))
            .cornerRadius(10)
        
        }
    }

    private var statisticsSection: some View {
        Group {
            Divider()
            NavigationLink(destination: StatisticsDetailView(item: .goal(goal))) {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Statistics")
                        .font(.headline)
                        .foregroundColor(.primary)
                    StatisticsSectionView(statistics: [
                        StatisticRow(label: "Days Worked:", value: "\(goal.daysWorked)"),
                        StatisticRow(label: "Days Remaining:", value: "\(goal.daysRemaining)"),
                        StatisticRow(label: "Total Journal Entries:", value: "\(allJournalEntries.count)")
                    ])
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var relatedHabitsSection: some View {
        Group {
            if (!goal.relatedHabits.isEmpty) {
                Divider()
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
    }

    // MARK: - Sheets

    private var addJournalEntrySheet: some View {
        AddJournalEntryForm(goal: goal, habit: nil)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }

    private var dayViewSheet: some View {
        Group {
            if let data = dayViewData {
                DayView(date: data.date, goals: data.goals, habits: data.habits)
            } else {
                EmptyView()
            }
        }
    }

    private func editJournalEntrySheet(_ entry: JournalEntry) -> some View {
        EditJournalEntryView(entry: entry)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .onAppear {
                entries = Array(Set(goal.journalEntries + goal.relatedHabits.flatMap { $0.journalEntries }))
            }
    }

    // MARK: - Helpers

    private func hasJournalEntryForDate(_ date: Date) -> Bool {
        allJournalEntries.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }

    private func entryBelongsToGoalOrHabits(_ entry: JournalEntry) -> Bool {
        goal.journalEntries.contains(where: { $0.id == entry.id }) ||
        goal.relatedHabits.flatMap { $0.journalEntries }.contains(where: { $0.id == entry.id })
    }

    private func deleteEntry(_ entry: JournalEntry) {
        if goal.journalEntries.contains(where: { $0.id == entry.id }) {
            goal.journalEntries.removeAll { $0.id == entry.id }
        } else {
            for habit in goal.relatedHabits {
                if habit.journalEntries.contains(where: { $0.id == entry.id }) {
                    habit.journalEntries.removeAll { $0.id == entry.id }
                    break
                }
            }
        }
    }

    private func getSourceLabel(_ entry: JournalEntry) -> String {
        if !goal.journalEntries.contains(where: { $0.id == entry.id }) {
            return "(via \(goal.relatedHabits.first(where: { $0.journalEntries.contains(where: { $0.id == entry.id })})?.title ?? "Unknown Habit"))"
        }
        return ""
    }

    private func handleSelectedDateChange(_ newValue: Date?) {
        if let date = newValue {
            dayViewData = (goals: [goal], habits: Array(goal.relatedHabits), date: date)
            showingDayView = true
        }
    }
}

private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}

