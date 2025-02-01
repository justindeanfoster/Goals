//
//  CalendarView.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//

import SwiftUI


struct CalendarView: View {
    let goals: [Goal]
    @StateObject private var calendarViewModel = CalendarViewModel()

    
    var body: some View {
        VStack {
            // Calendar View
            VStack {
                HStack {
                    Spacer()
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

                Divider()
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
                    ForEach(0..<calendarViewModel.startingWeekday, id: \.self) { index in
                        Text("")
                            .frame(width: 30, height: 30)
                            .id("empty-\(index)") // Unique identifier for empty cells

                    }
                    ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset , to: calendarViewModel.startOfMonth)!
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate)
                        let progress = calendarViewModel.pctGoalsWorkedOn(for: date, goals: goals)

                        Circle()
                            .fill(isSelected ? Color.blue : color(for: progress))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(Calendar.current.component(.day, from: date).description)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                            .onTapGesture {
                                calendarViewModel.selectedDate = date
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
                        calendarViewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: calendarViewModel.selectedDate) ?? calendarViewModel.selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                    }

                    Text("\(calendarViewModel.selectedDate, formatter: dayFormatter)")
                        .font(.headline)

                    Button(action: {
                        calendarViewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: calendarViewModel.selectedDate) ?? calendarViewModel.selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    Spacer()
                }
                .padding(.bottom, 5)

                Divider()

                List {
                    ForEach(calendarViewModel.journalEntries(for: calendarViewModel.selectedDate, goals: goals)) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.text)
                                .font(.headline)
                            Text(entry.goalTitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Calendar Progress")
        .background(Color(UIColor.systemBackground))
    }
    
    private func color(for progress: Double) -> Color {
            switch progress {
            case 0:
                return .gray
            case 0..<0.5:
                return .yellow
            case 0.5..<1:
                return .teal
            default:
                return .green
            }
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
