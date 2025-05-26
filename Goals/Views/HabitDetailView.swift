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
    @State private var isExpanded = false

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
            if !habit.notes.isEmpty || !habit.milestones.isEmpty {
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
                        if !habit.notes.isEmpty {
                            Text(habit.notes)
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        if !habit.milestones.isEmpty {
                            Text("Milestones")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            MilestoneListView(
                                milestones: .init(
                                    get: { habit.milestones },
                                    set: { habit.milestones = $0 }
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
        }
    }

    private var statisticsSection: some View {
        Group {
            Divider()
            NavigationLink(destination: StatisticsDetailView(item: .habit(habit))) {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Statistics")
                        .font(.headline)
                        .foregroundColor(.primary)
                    StatisticsSectionView(statistics: [
                        StatisticRow(label: "Days Worked:", value: "\(habit.daysWorked)")
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
