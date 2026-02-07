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
    @State private var showingAddMilestoneForm = false
    @State private var selectedEntry: JournalEntry?
    @State private var selectedDate: Date?
    @State private var dayViewData: (goals: [Goal], habits: [Habit], date: Date)?
    @State private var timeframeUpdateTrigger = Date()
    @State private var entries: [JournalEntry] = []

    @State private var showingDayView = false
    @State private var showingEditForm = false
    @State private var selectedTab = 0  // 0: Notes, 1: Milestones, 2: Journal Entries

    // MARK: - Computed Properties

    private var allJournalEntries: [JournalEntry] {
        Array(Set(goal.journalEntries + goal.relatedHabits.flatMap { $0.journalEntries }))
    }
    private var currentTimeframeEntries: [JournalEntry] {
        calendarViewModel.getEntriesForCurrentTimeframe(allJournalEntries, isExpanded: showCalendar)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack {
                headerSection
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        calendarSection
                        
                        // Tab Navigation
                        HStack(spacing: 0) {
                            TabButton(
                                title: "Notes",
                                isSelected: selectedTab == 0,
                                position: .left
                            ) {
                                selectedTab = 0
                            }
                            
                            TabButton(
                                title: "Milestones",
                                isSelected: selectedTab == 1,
                                position: .middle
                            ) {
                                selectedTab = 1
                            }
                            
                            TabButton(
                                title: "Journal",
                                isSelected: selectedTab == 2,
                                position: .right
                            ) {
                                selectedTab = 2
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding()
                        
                        // Tab Content
                        if selectedTab == 0 {
                            notesSection
                                .padding()
                        } else if selectedTab == 1 {
                            milestonesSection
                                .padding()
                        } else {
                            journalEntriesSection
                                .padding()
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Menu {
                        Button(action: { showingAddJournalEntryForm = true }) {
                            Label("Add Journal Entry", systemImage: "note.text.badge.plus")
                        }
                        Button(action: { showingAddMilestoneForm = true }) {
                            Label("Add Milestone", systemImage: "flag.badge.checkmark")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: menuButton)
        .sheet(isPresented: $showingAddJournalEntryForm) { addJournalEntrySheet }
        .sheet(isPresented: $showingEditForm) { editGoalSheet }
        .sheet(isPresented: $showingAddMilestoneForm) {
            AddMilestoneView(
                isForGoal: true,
                onSave: { milestone in
                    goal.milestones.append(milestone)
                }
            )
        }
        .onChange(of: selectedDate) { _, newValue in handleSelectedDateChange(newValue) }
        .sheet(isPresented: $showingDayView) { dayViewSheet }
        .onChange(of: showCalendar) { _, _ in timeframeUpdateTrigger = Date() }
        .onChange(of: calendarViewModel.timeframeChanged) { _, _ in timeframeUpdateTrigger = Date() }
        .onAppear { entries = allJournalEntries }
        .sheet(item: $selectedEntry) { entry in editJournalEntrySheet(entry) }
    }

    // MARK: - Sections

    private var menuButton: some View {
        Menu {
            Button(action: { showingEditForm = true }) {
                Label("Edit", systemImage: "pencil")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
    }

    private var headerSection: some View {
        HStack {
            Text(goal.title)
                .font(.largeTitle)
                .bold()
            Spacer()
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
        VStack(alignment: .leading, spacing: 16) {            
            // Statistics - Clickable to StatisticsDetailView
            NavigationLink(destination: StatisticsDetailView(item: .goal(goal))) {
                VStack(alignment: .leading, spacing: 12) {
                    // Statistics
                    Text(goal.notes)
                        .font(.headline)
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
            
            // Related Habits
            if !goal.relatedHabits.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
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
    }
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
//            Text("Milestones")
//                .font(.headline)
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

    private var journalEntriesSection: some View {
        Group {
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

    // MARK: - Sheets

    private var addJournalEntrySheet: some View {
        AddJournalEntryForm(goal: goal, habit: nil)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }

    private var editGoalSheet: some View {
        EditGoalForm(goal: goal)
            .presentationDetents([.large])
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

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let position: Position
    let action: () -> Void
    
    enum Position {
        case left, middle, right
        
        var corners: UIRectCorner {
            switch self {
            case .left: return [.topLeft, .bottomLeft]
            case .middle: return []
            case .right: return [.topRight, .bottomRight]
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
                .foregroundColor(isSelected ? .blue : .secondary)
                .cornerRadius(8, corners: position.corners)
        }
    }
}

private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}

