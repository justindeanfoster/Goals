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

    var body: some View {
        VStack(alignment: .leading) {
            // Calendar for goal activity
            VStack {
                Text("Goal Activity")
                    .font(.headline)
                    .padding(.bottom, 5)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(0..<calendarViewModel.daysInMonth, id: \ .self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfMonth)!
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate)

                        Circle()
                            .fill(isSelected ? Color.blue : Color.gray)
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
            List {
                ForEach(goal.journalEntries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.text)
                        Text(entry.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            HStack {
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
            .padding(.vertical)

            Spacer()
        }
        .padding()
        .navigationTitle(goal.title)
    }
}
