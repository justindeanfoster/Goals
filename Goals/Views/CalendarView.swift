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
                        
                        Text(calendarViewModel.startOfMonth, formatter: monthYearFormatter)
                            .font(.headline)
                            
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
                    
                    // Journal Entries Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text(calendarViewModel.selectedDate.formatted(date: .complete, time: .omitted))
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
