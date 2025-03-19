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
    @State private var showingDayView = false

    var body: some View {
        VStack {
            HStack {
                Text(goal.title)
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: {
                    showingAddJournalEntryForm = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                }
                .sheet(isPresented: $showingAddJournalEntryForm) {
                    AddJournalEntryForm(goal: goal, habit: nil)
                }
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading) {
                    // Toggle button for calendar visibility

                    Button(action: {
                        withAnimation {
                            showCalendar.toggle()
                        }
                    }) {
                        HStack {
                            Text("Goal Activity Calendar")
                                .font(.headline)
                            Spacer()
                            Image(systemName: showCalendar ? "chevron.up" : "chevron.down")
                        }
                        .padding(.bottom, 5)
                    }
                    let allJournalEntries = Array(Set(goal.journalEntries + goal.relatedHabits.flatMap { $0.journalEntries }))
                    if showCalendar {
                        // Calendar for habit activity
                        
                        VStack {
                            HStack {
                                Button(action: {
                                    calendarViewModel.moveMonth(by: -1)
                                }) {
                                    Image(systemName: "chevron.left")
                                }

                                Text(calendarViewModel.startOfMonth, formatter: monthYearFormatter)
                                    .font(.headline)
                                    .padding()

                                Button(action: {
                                    calendarViewModel.moveMonth(by: 1)
                                }) {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .padding(.bottom)

                            // Days of the week header
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
                                    Text("")
                                        .frame(width: 30, height: 30)
                                        .id("empty-\(index)") // Unique identifier for empty cells
                                }
                                ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { offset in
                                    let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfMonth)!
                                    let isToday = Calendar.current.isDateInToday(date)
                                    let isDeadline = Calendar.current.isDate(date, inSameDayAs: goal.deadline)
                                    let hasJournalEntry = allJournalEntries.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }

                                    VStack {
                                        Circle()
                                            .fill(hasJournalEntry ? Color.green :  Color.gray)
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Text(Calendar.current.component(.day, from: date).description)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            )
                                            .onTapGesture {
                                                selectedDate = date
                                                showingDayView = true
                                            }
                                        if isToday {
                                            Rectangle()
                                                .fill(Color.blue)
                                                .frame(height: 2)
                                        }
                                        if isDeadline {
                                            Rectangle()
                                                .fill(Color.red)
                                                .frame(height: 2)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                    } else {
                        // Last week view
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
                                ForEach(0..<7, id: \.self) { offset in
                                    let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfWeek)!
                                    let isToday = Calendar.current.isDateInToday(date)
                                    let isDeadline = Calendar.current.isDate(date, inSameDayAs: goal.deadline)
                                    let hasJournalEntry = allJournalEntries.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }

                                    VStack {
                                        Circle()
                                            .fill(hasJournalEntry ? Color.green : Color.gray)
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Text(Calendar.current.component(.day, from: date).description)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            )
                                            .onTapGesture {
                                                selectedDate = date
                                                showingDayView = true
                                            }
                                        if isToday {
                                            Rectangle()
                                                .fill(Color.blue)
                                                .frame(height: 2)
                                        }
                                        if isDeadline {
                                            Rectangle()
                                                .fill(Color.red)
                                                .frame(height: 2)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                    }

                    Divider()
                    

                    // Statistics Section
                    VStack(alignment: .leading) {
                        Text("Statistics")
                            .font(.headline)
                            .padding(.bottom, 5)

                        HStack {
                            Text("Days Worked:")
                            Spacer()
                            Text("\(goal.daysWorked)")
                        }
                        .padding(.bottom, 2)

                        HStack {
                            Text("Days Remaining:")
                            Spacer()
                            Text("\(goal.daysRemaining)")
                        }
                        .padding(.bottom, 2)

                        HStack {
                            Text("Total Journal Entries:")
                            Spacer()
                            Text("\(allJournalEntries.count)")
                        }
                        .padding(.bottom, 2)
                    }

                    Divider()

                    if !goal.notes.isEmpty {
                        Text("Notes")
                            .font(.headline)
                        Text(goal.notes)
                            .padding(.bottom, 10)
                    }

                    Text("Milestones")
                        .font(.headline)
                    ForEach(goal.milestones, id: \.self) { milestone in
                        Text("- \(milestone)")
                    }

                    Divider()

                    Text("Journal Entries")
                        .font(.headline)
                        ForEach(allJournalEntries.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(entry.text)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                                HStack {
                                    Text(entry.timestamp, style: .date)
                                    if !goal.journalEntries.contains(where: { $0.id == entry.id }) {
                                        // Show which habit this entry is from if it's not directly from the goal
                                        Text("(via \(goal.relatedHabits.first(where: { $0.journalEntries.contains(where: { $0.id == entry.id })})?.title ?? "Unknown Habit"))")
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.vertical, 4)
                            .contextMenu {
                                // Only show edit/delete for entries that belong directly to the goal
                                if goal.journalEntries.contains(where: { $0.id == entry.id }) {
                                    Button(action: {
                                        selectedEntry = entry
                                        showingEditJournalEntry = true
                                    }) {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button(role: .destructive, action: {
                                        goal.journalEntries.removeAll { $0.id == entry.id }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    
                    
                    Divider()
                    Text("Related Habits")
                        .font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], alignment: .leading, content: {
                        {
                            ForEach(goal.relatedHabits) { habit in
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    Text(habit.title)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(10)
                                        .foregroundColor(.primary)
                                }
                            }
                        }()
                        .padding(.horizontal)
                    })

                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDayView) {
            if let date = selectedDate {
                DayView(date: date, goals: [goal], habits: Array(goal.relatedHabits))
            }
        }
    }
}

private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}

