import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let hasJournalEntry: (Date) -> Bool
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { calendarViewModel.moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(calendarViewModel.startOfMonth, formatter: monthFormatter)
                    .font(.headline)
                    .padding()
                
                Button(action: { calendarViewModel.moveMonth(by: 1) }) {
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
                }
                
                ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfMonth)!
                    let isToday = Calendar.current.isDateInToday(date)
                    let isDeadline = isDeadlineDate?(date) ?? false
                    
                    VStack {
                        Circle()
                            .fill(hasJournalEntry(date) ? Color.green : Color.gray)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(Calendar.current.component(.day, from: date).description)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                            .onTapGesture {
                                calendarViewModel.selectedDate = date
                                DispatchQueue.main.async {
                                    onDateSelected(date)
                                }
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
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
