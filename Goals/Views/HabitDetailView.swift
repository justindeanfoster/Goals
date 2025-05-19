import SwiftUI
import SwiftData

struct HabitDetailView: View {
    let habit: Habit
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var showingAddJournalEntryForm = false
    @State private var showCalendar = false
    @State private var selectedEntry: JournalEntry?
    @State private var selectedDate: Date?
    @State private var dayViewData: (goals: [Goal], habits: [Habit], date: Date)?
    @State private var showingDayView = false
    @State private var entries: [JournalEntry] = []

    // MARK: - Computed Properties

    private var currentTimeframeEntries: [JournalEntry] {
        calendarViewModel.getEntriesForCurrentTimeframe(habit.journalEntries, isExpanded: showCalendar)
    }

    // MARK: - Body

    var body: some View {
        VStack {
            headerSection
            ScrollView {
                VStack(alignment: .leading) {
                    calendarSection
                    notesSection
                    milestonesSection
                    journalEntriesSection
                    statisticsSection
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddJournalEntryForm) { addJournalEntrySheet }
        .onChange(of: selectedDate) { oldValue, newValue in handleSelectedDateChange(newValue) }
        .sheet(isPresented: $showingDayView) { dayViewSheet }
        .onAppear { entries = Array(habit.journalEntries) }
        .sheet(item: $selectedEntry) { entry in editJournalEntrySheet(entry) }
    }

    // MARK: - Sections

    private var headerSection: some View {
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
    }

    private var calendarSection: some View {
        CalendarSectionView(
            calendarViewModel: calendarViewModel,
            onDateSelected: { date in
                selectedDate = date
                showingDayView = true
            },
            isDeadlineDate: nil,
            milestoneCompletions: { date in
                habit.milestones.contains { milestone in
                    guard let completedDate = milestone.dateCompleted else { return false }
                    return Calendar.current.isDate(completedDate, inSameDayAs: date)
                }
            },
            getDateColor: { date in
                habit.journalEntries.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: date) } ? .green : .gray
            },
            showCalendar: $showCalendar
        )
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2, x: 0, y: 2)
        .onChange(of: showCalendar) { oldValue, newValue in
            if (!newValue) { calendarViewModel.currentMonth = Date() }
        }
    }

    private var notesSection: some View {
        Group {
            if !habit.notes.isEmpty {
                Divider()
                CollapsibleSectionView(title: "Notes", content: habit.notes)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
            }
        }
    }

    private var milestonesSection: some View {
        Group {
            if !habit.milestones.isEmpty {
                Divider()
                MilestoneListView(
                    milestones: .init( // Create binding
                        get: { habit.milestones },
                        set: { habit.milestones = $0 }
                    ),
                    selectedDate: calendarViewModel.selectedDate
                )
                .background(Color(.systemBackground))
                .cornerRadius(10)
                Divider()
            }
        }
    }

    private var journalEntriesSection: some View {
        Group {
            if !currentTimeframeEntries.isEmpty {
                Divider()
                JournalEntriesListView(
                    entries: currentTimeframeEntries,
                    onEntryTapped: { entry in
                        selectedDate = entry.timestamp
                        showingDayView = true
                    },
                    canEdit: { _ in true },
                    onEditEntry: { entry in
                        selectedEntry = entry
                    },
                    onDeleteEntry: { entry in
                        habit.journalEntries.removeAll { $0.id == entry.id }
                    },
                    sourceLabel: nil
                )
                .background(Color(.systemBackground))
                .cornerRadius(10)
            } else {
                EmptyView()
            }
        }
    }

    private var statisticsSection: some View {
        Group{
            Divider()
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
            .shadow(radius: 2, x: 0, y: 2)
        }
    }

    // MARK: - Sheets

    private var addJournalEntrySheet: some View {
        AddJournalEntryForm(goal: nil, habit: habit)
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
                entries = Array(habit.journalEntries)
            }
    }

    // MARK: - Helpers

    private func handleSelectedDateChange(_ newValue: Date?) {
        if let date = newValue {
            dayViewData = (goals: [], habits: [habit], date: date)
            showingDayView = true
        }
    }
}
