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
                    AddJournalEntryForm(goal: $goal)
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

                    if showCalendar {
                        // Calendar for goal activity
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
                                // Add empty cells for days before the start of the month
                                ForEach(0..<calendarViewModel.startingWeekday, id: \.self) { _ in
                                    Text("")
                                        .frame(width: 30, height: 30)
                                        .id("empty-\(String(describing: index))") // Unique identifier for empty cells
                                }
                                ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { offset in
                                    let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfMonth)!
                                    let isSelected = Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate)
                                    let hasJournalEntry = goal.journalEntries.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }

                                    Circle()
                                        .fill(hasJournalEntry ? Color.green : (isSelected ? Color.blue : Color.gray))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Text(Calendar.current.component(.day, from: date).description)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                        }
                        .padding(.bottom)

                        Divider()
                    }

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
                    ForEach(goal.milestones, id: \ .self) { milestone in
                        Text("- \(milestone)")
                    }

                    Divider()

                    Text("Journal Entries")
                        .font(.headline)
                    ForEach(goal.journalEntries) { entry in
                        VStack(alignment: .leading) {
                            Text(" - \(entry.text)")
                            Text(entry.timestamp, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
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

