//
//  CalendarView.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var calendarViewModel = CalendarViewModel()
    @Query var goals: [Goal]
    @Query var habits: [Habit]
    @Query var journalEntries: [JournalEntry]
    @State private var showingFilter = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(spacing: 20) {
                        filterAndCalendarControls
                        calendarGridSection
                        Divider().padding(.horizontal)
                        combinedDateAndDeadlinesSection
                    }
                    .padding(.vertical)
                }
                if showingFilter { filterOverlay }
            }
            .navigationTitle("Calendar")
        }
        .background(Color(UIColor.systemBackground))
        .onAppear { calendarViewModel.initializeFilters(goals: goals, habits: habits) }
    }

    // MARK: - Sections

    private var filterAndCalendarControls: some View {
        HStack {
            Button(action: { withAnimation { showingFilter.toggle() } }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(showingFilter ? .primary : .blue)
            }
            Spacer()
            monthNavigation
            Spacer()
            Button(action: {
                calendarViewModel.selectedDate = Date()
                calendarViewModel.currentMonth = Date()
            }) {
                Text("Today").font(.headline)
            }
        }
        .padding(.horizontal)
        .zIndex(1)
    }

    private var monthNavigation: some View {
        HStack {
            Spacer()
            Button(action: { calendarViewModel.moveMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(calendarViewModel.startOfMonth, formatter: monthYearFormatter)
                .font(.headline)
            Spacer()
            Button(action: { calendarViewModel.moveMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
            Spacer()
        }
    }

    private var calendarGridSection: some View {
        VStack {
            HStack {
                ForEach(calendarViewModel.daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 5)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(0..<calendarViewModel.startingWeekday, id: \.self) { index in
                    Text("").frame(width: 30, height: 30).id("empty-\(index)")
                }
                ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfMonth)!
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate)
                    let hasDeadline = calendarViewModel.hasDeadlines(on: date, goals: goals)
                    calendarDayCell(date: date, isSelected: isSelected, hasDeadline: hasDeadline)
                }
            }
        }
        .padding(.horizontal)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        calendarViewModel.moveMonth(by: -1)
                    } else if value.translation.width < -50 {
                        calendarViewModel.moveMonth(by: 1)
                    }
                }
        )
    }

    private func calendarDayCell(date: Date, isSelected: Bool, hasDeadline: Bool) -> some View {
        let progress = calendarViewModel.getDailyProgress(for: date, goals: goals, habits: habits)
        let cellColor = progress > 0 ? 
            Color.blue.opacity(0.3 + (progress * 0.7)) : 
            Color.gray
            
        return CalendarDayCell(
            date: date,
            isSelected: isSelected,
            hasDeadline: hasDeadline,
            hasMilestone: hasMilestoneCompletions(on: date),
            cellColor: cellColor,
            onTap: { calendarViewModel.selectedDate = date }
        )
    }

    private var combinedDateAndDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(calendarViewModel.selectedDate.formatted(date: .complete, time: .omitted))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            if !calendarViewModel.deadlinesForDate(calendarViewModel.selectedDate, goals: goals).isEmpty {
                deadlinesSection
            }
            if !getMilestonesCompletedOn(calendarViewModel.selectedDate).isEmpty {
                milestonesSection
            }
            Divider().padding(.horizontal)
            journalEntriesSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var deadlinesSection: some View {
        Group {
            Text("Deadlines")
                .font(.headline)
                .padding(.horizontal)
            ForEach(calendarViewModel.deadlinesForDate(calendarViewModel.selectedDate, goals: goals)) { goal in
                NavigationLink(destination: GoalDetailView(goal: goal)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }

    private var journalEntriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            let entries = calendarViewModel.journalEntries(for: calendarViewModel.selectedDate, goals: goals, habits: habits)
            if entries.isEmpty {
                Text("You ain't do nothing today")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text("Journal Entries")
                    .font(.headline)
                    .padding(.horizontal)
                ForEach(entries) { entry in
                    NavigationLink(destination: getDestinationView(for: entry)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.text)
                                .font(.body)
                                .foregroundColor(.primary)
                            HStack {
                                Text(entry.sourceName)
                                Text("(\(entry.sourceType))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var milestonesSection: some View {
        Group {
            Text("Milestones Completed")
                .font(.headline)
                .padding(.horizontal)
            ForEach(getMilestonesCompletedOn(calendarViewModel.selectedDate), id: \.id) { milestone in
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.text)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.primary)
                    Text(getMilestoneSource(milestone) ?? "Unknown Source")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }

    private var filterOverlay: some View {
        Color.black.opacity(0.1)
            .ignoresSafeArea()
            .onTapGesture { withAnimation { showingFilter = false } }
            .overlay(
                FilterMenu(viewModel: calendarViewModel, goals: goals, habits: habits)
                    .padding(.top, 45)
                    .padding(.leading, 10),
                alignment: .topLeading
            )
    }

    // MARK: - Helpers

    private func color(for date: Date) -> Color {
        let progress = calendarViewModel.getDailyProgress(for: date, goals: goals, habits: habits)
        if progress > 0 {
            return Color.blue.opacity(0.3 + (progress * 0.7))
        }
        return .gray
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    @ViewBuilder
    private func getDestinationView(for entry: JournalEntryWithSource) -> some View {
        if entry.sourceType == "Goal" {
            if let goal = goals.first(where: { $0.title == entry.sourceName }) {
                GoalDetailView(goal: goal)
            }
        } else {
            if let habit = habits.first(where: { $0.title == entry.sourceName }) {
                HabitDetailView(habit: habit)
            }
        }
    }

    private func hasMilestoneCompletions(on date: Date) -> Bool {
        for goal in goals {
            if goal.milestones.contains(where: { milestone in
                guard let completedDate = milestone.dateCompleted else { return false }
                return Calendar.current.isDate(completedDate, inSameDayAs: date)
            }) {
                return true
            }
        }
        for habit in habits {
            if habit.milestones.contains(where: { milestone in
                guard let completedDate = milestone.dateCompleted else { return false }
                return Calendar.current.isDate(completedDate, inSameDayAs: date)
            }) {
                return true
            }
        }
        return false
    }

    private func getMilestonesCompletedOn(_ date: Date) -> [Milestone] {
        var completedMilestones: [Milestone] = []
        
        for goal in goals {
            completedMilestones.append(contentsOf: goal.milestones.filter { milestone in
                guard let completedDate = milestone.dateCompleted else { return false }
                return Calendar.current.isDate(completedDate, inSameDayAs: date)
            })
        }
        
        for habit in habits {
            completedMilestones.append(contentsOf: habit.milestones.filter { milestone in
                guard let completedDate = milestone.dateCompleted else { return false }
                return Calendar.current.isDate(completedDate, inSameDayAs: date)
            })
        }
        
        return completedMilestones
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
}
