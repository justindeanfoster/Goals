//
//  CalendarView.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//

import SwiftUI


struct CalendarView: View {
    let goals: [Goal]

    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()

    private var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth)) ?? Date()
    }

    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
    }

    private func goalsWorkedOn(for date: Date) -> [Goal] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return goals.filter { goal in
            goal.journalEntries.contains(where: {
                Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay)
            })
        }
    }
    private func pctGoalsWorkedOn(for date: Date) -> Double {
            let startOfDay = Calendar.current.startOfDay(for: date)
            let goalsWorkedOn = goals.filter { goal in
                goal.journalEntries.contains(where: {
                    Calendar.current.isDate($0.timestamp, inSameDayAs: startOfDay)
                })
            }
            return goals.isEmpty ? 0 : Double(goalsWorkedOn.count) / Double(goals.count)
        }

    var body: some View {
        VStack {
            // Calendar View
            VStack {
                HStack {
                    Button(action: {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }) {
                        Image(systemName: "chevron.left")
                    }

                    Text(startOfMonth, formatter: monthYearFormatter)
                        .font(.headline)
                        .padding()

                    Button(action: {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.bottom)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(0..<daysInMonth, id: \ .self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: startOfMonth)!
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let progress  = pctGoalsWorkedOn(for: date)

                        Circle()
                            .fill(isSelected ? Color.blue : color(for: progress))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(Calendar.current.component(.day, from: date).description)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                    }
                }
            }
            .padding(.top)

            Divider()

            // Progress View for Selected Day
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                    }

                    Text("\(selectedDate, formatter: dayFormatter)")
                        .font(.headline)

                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.bottom, 5)

                List(goalsWorkedOn(for: selectedDate)) { goal in
                    VStack(alignment: .leading) {
                        Text(goal.title)
                            .font(.headline)
                        Text("Milestones: \(goal.milestones.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Calendar Progress")
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
