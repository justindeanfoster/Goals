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
        VStack {
            // Calendar View
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showingFilter.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                            .foregroundColor(showingFilter ? .primary : .blue)
                    }
                    .overlay(alignment: .topLeading) {
                        if showingFilter {
                            FilterMenu(viewModel: calendarViewModel, goals: goals, habits: habits)
                                .offset(y: 90)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    Spacer()
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


                    Button(action: {
                        calendarViewModel.selectedDate = Date()
                        calendarViewModel.currentMonth = Date()
                    }) {
                        Text("Today")
                            .font(.headline)
                            .padding(.leading, 10)
                    }
                    Spacer()
                }
                .padding(.bottom)
                .zIndex(1) // Ensure buttons stay on top

                VStack {
                    // Days of the week header and calendar grid
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
                        ForEach(0..<calendarViewModel.startingWeekday, id: \.self) { index in
                            Text("")
                                .frame(width: 30, height: 30)
                                .id("empty-\(index)") // Unique identifier for empty cells

                        }
                        ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { offset in
                            let date = Calendar.current.date(byAdding: .day, value: offset , to: calendarViewModel.startOfMonth)!
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate)

                            VStack {
                                Circle()
                                    .fill(color(for: date))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Text(Calendar.current.component(.day, from: date).description)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    ).onTapGesture {
                                        calendarViewModel.selectedDate = date
                                    }
                                Rectangle()
                                    .fill(isSelected ? Color.blue : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
            }
            .padding(.top)

            Divider()

            // Progress View for Selected Day
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        calendarViewModel.moveDay(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                    }

                    Text("\(calendarViewModel.selectedDate, formatter: dayFormatter)")
                        .font(.headline)

                    Button(action: {
                        calendarViewModel.moveDay(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    Spacer()
                }
                .padding(.bottom, 5)

                Divider()

                List {
                    ForEach(calendarViewModel.journalEntries(for: calendarViewModel.selectedDate, goals: goals, habits: habits)) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.text)
                                .font(.body)
                            HStack {
                                Text(entry.sourceName)
                                Text("(\(entry.sourceType))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Calendar Progress")
        .background(Color(UIColor.systemBackground))
        .onAppear {
            calendarViewModel.initializeFilters(goals: goals, habits: habits)
        }
    }
    
    private func color(for date: Date) -> Color {
        return calendarViewModel.hasJournalEntries(for: date, goals: goals, habits: habits) ? .blue : .gray
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}
