//
//  GoalDetailView.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//

import SwiftUI

struct GoalDetailView: View {
    @Binding var goal: Goal
    @State private var newJournalEntry: String = ""
    @State private var currentMonth: Date = Date()
    @State private var currentDate: Date  = Date()

    private var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth)) ?? Date()
    }

    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Calendar for goal activity
            VStack {
                Text("Goal Activity")
                    .font(.headline)
                    .padding(.bottom, 5)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(0..<daysInMonth, id: \ .self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: startOfMonth)!
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: currentDate)

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
                TextField("New Journal Entry", text: $newJournalEntry)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    if !newJournalEntry.isEmpty {
                        let entry = JournalEntry(timestamp: Date(), text: newJournalEntry)
                        goal.journalEntries.append(entry)
                        newJournalEntry = ""
                    }
                }) {
                    Text("Add")
                }
            }
            .padding(.vertical)

            Spacer()
        }
        .padding()
        .navigationTitle(goal.title)
    }
}
