import SwiftUI

struct WeekGridView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let hasJournalEntry: (Date) -> Bool
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    
    var body: some View {
        VStack {
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
            Divider()
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(0..<7) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfWeek)!
                let isToday = Calendar.current.isDateInToday(date)
                let isDeadline = isDeadlineDate?(date) ?? false
                let isSelected = Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate)
                
                VStack {
                    ZStack {
                        if isDeadline {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.red.opacity(0.8))
                                .frame(width: 35, height: 35)
                                .zIndex(1)
                        }
                        if isSelected {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.blue.opacity(0.8))
                                .frame(width: 35, height: 35)
                                .zIndex(1)
                        }
                        Circle()
                            .fill(hasJournalEntry(date) ? Color.green : Color.gray)
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
                        onDateSelected(date)
                    }
                }
            }
        }
        }
    }
}
