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
                        // Filter and Calendar Controls
                        HStack {
                            Button(action: {
                                withAnimation {
                                    showingFilter.toggle()
                                }
                            }) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.title2)
                                    .foregroundColor(showingFilter ? .primary : .blue)
                            }
                            
                            Spacer()
                            
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
                                
                            Spacer()
                            
                            Button(action: {
                                calendarViewModel.selectedDate = Date()
                                calendarViewModel.currentMonth = Date()
                            }) {
                                Text("Today")
                                    .font(.headline)
                            }
                        }
                        .padding(.horizontal)
                        .zIndex(1)
                        
                        // Calendar Grid
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
                                // Add empty cells for days before the start of the month
                                ForEach(0..<calendarViewModel.startingWeekday, id: \.self) { index in
                                    Text("")
                                        .frame(width: 30, height: 30)
                                        .id("empty-\(index)") // Unique identifier for empty cells

                                }
                                ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { offset in
                                    let date = Calendar.current.date(byAdding: .day, value: offset , to: calendarViewModel.startOfMonth)!
                                    let isSelected = Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate)
                                    let hasDeadline = calendarViewModel.hasDeadlines(on: date, goals: goals)

                                    VStack {
                                        ZStack {
                                            if hasDeadline {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(Color.red.opacity(0.8))
                                                    .frame(width: 35, height: 35)
                                                    .zIndex(1)
                                            }
                                            Circle()
                                                .fill(color(for: date))
                                                .frame(width: 30, height: 30)
                                                .zIndex(2)
                                                .overlay(
                                                    Text(Calendar.current.component(.day, from: date).description)
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                        .zIndex(3)
                                                )
                                        }
                                        .onTapGesture {
                                            calendarViewModel.selectedDate = date
                                        }
                                        Rectangle()
                                            .fill(isSelected ? Color.blue : Color.clear)
                                            .frame(height: 2)
                                    }
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
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Combined Date and Deadlines Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text(calendarViewModel.selectedDate.formatted(date: .complete, time: .omitted))
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal)
                            
                            
                            
                            if !calendarViewModel.deadlinesForDate(calendarViewModel.selectedDate, goals: goals).isEmpty {
                                Text("Deadlines")
                                .font(.headline)
                                .padding(.horizontal)
                                ForEach(calendarViewModel.deadlinesForDate(calendarViewModel.selectedDate, goals: goals)) { goal in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(goal.title)
                                            .font(.subheadline)
                                            .bold()
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Journal Entries Section
                            VStack(alignment: .leading, spacing: 10) {
                                
                                
                                if calendarViewModel.journalEntries(for: calendarViewModel.selectedDate, goals: goals, habits: habits).isEmpty {
                                    Text("You ain't do nothing today")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    Text("Journal Entries")
                                    .font(.headline)
                                    .padding(.horizontal)
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
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical)
                }
                
                if showingFilter {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showingFilter = false
                            }
                        }
                    
                    FilterMenu(viewModel: calendarViewModel, goals: goals, habits: habits)
                        .padding(.top, 45)
                        .padding(.leading, 10)
                }
            }
            .navigationTitle("Calendar")
        }
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
