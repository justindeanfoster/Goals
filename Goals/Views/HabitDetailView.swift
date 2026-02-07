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
    @State private var showingEditForm = false
    @State private var selectedTab = 0  // 0: Notes, 1: Milestones, 2: Journal Entries

    // MARK: - Computed Properties

    private var currentTimeframeEntries: [JournalEntry] {
        calendarViewModel.getEntriesForCurrentTimeframe(habit.journalEntries, isExpanded: showCalendar)
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
        .sheet(isPresented: $showingEditForm) { editHabitSheet }
        .onChange(of: selectedDate) { oldValue, newValue in handleSelectedDateChange(newValue) }
        .sheet(isPresented: $showingDayView) { dayViewSheet }
        .onAppear { entries = Array(habit.journalEntries) }
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
            Text(habit.title)
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
        VStack(alignment: .leading, spacing: 16) {
            
            // Statistics with Notes - Clickable to StatisticsDetailView
            NavigationLink(destination: StatisticsDetailView(item: .habit(habit))) {
                VStack(alignment: .leading, spacing: 12) {
                    // Statistics
                    Text(habit.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !habit.milestones.isEmpty {
                Text("Milestones")
                    .font(.headline)
                MilestoneListView(
                    milestones: .init(
                        get: { habit.milestones },
                        set: { habit.milestones = $0 }
                    ),
                    selectedDate: calendarViewModel.selectedDate,
                    showHeader: false
                )
            } else {
                Text("No milestones yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }

    private var journalEntriesSection: some View {
        Group {
            JournalEntriesListView(
                entries: habit.journalEntries.sorted { $0.timestamp > $1.timestamp },
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

    // MARK: - Sheets

    private var addJournalEntrySheet: some View {
        AddJournalEntryForm(goal: nil, habit: habit)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }

    private var editHabitSheet: some View {
        EditHabitForm(habit: habit)
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
