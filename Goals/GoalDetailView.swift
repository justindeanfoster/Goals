//
//  GoalDetailView.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//



import SwiftUI

struct GoalDetailView: View {
    @Binding var goal: Goal
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var showingAddJournalEntryForm = false
    @State private var showCalendar = false // State to toggle calendar visibility

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
                    AddJournalEntryForm(goal: .constant(goal), habit: .constant(nil))
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
                            Text("\(goal.journalEntries.count)")
                        }
                        .padding(.bottom, 2)
                    }
                    .padding(.bottom)

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
                    ForEach(allJournalEntries) { entry in
                        VStack(alignment: .leading) {
                            Text(" - \(entry.text)")
                            Text(entry.timestamp, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    Text("Related Habits")
                        .font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], alignment: .leading, content: {
                        {
                            ForEach(goal.relatedHabits) { habit in
                                NavigationLink(destination: HabitDetailView(habit: .constant(habit))) {
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
    }
}

private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}

