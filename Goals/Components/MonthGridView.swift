import SwiftUI

struct MonthGridView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    let milestoneCompletions: ((Date) -> Bool)?
    let getDateColor: (Date) -> Color
    @Binding var showCalendar: Bool
    
    var body: some View {
        VStack {
            CalendarHeaderView(
                title: monthFormatter.string(from: calendarViewModel.startOfMonth),
                onPrevious: { calendarViewModel.moveMonth(by: -1) },
                onNext: { calendarViewModel.moveMonth(by: 1) },
                onToday: {
                    calendarViewModel.selectedDate = Date()
                    calendarViewModel.currentMonth = Date()
                }
            )
            
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
                ForEach(0..<calendarViewModel.startingWeekday, id: \.self) { index in
                    Text("")
                        .frame(width: 30, height: 30)
                        .id("empty-\(index)")
                }
                
                ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfMonth)!
                    let isToday = Calendar.current.isDateInToday(date)
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: calendarViewModel.selectedDate)
                    let isDeadline = isDeadlineDate?(date) ?? false
                    
                    CalendarDayCell(
                        date: date,
                        isSelected: isSelected,
                        hasDeadline: isDeadline,
                        hasMilestone: milestoneCompletions?(date) ?? false,
                        cellColor: getDateColor(date),
                        onTap: {
                            calendarViewModel.selectedDate = date
                            DispatchQueue.main.async {
                                onDateSelected(date)
                            }
                        }
                    )
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        // Swipe right - go back
                        calendarViewModel.moveMonth(by: -1)
                    } else if value.translation.width < -50 {
                        // Swipe left - go forward
                        calendarViewModel.moveMonth(by: 1)
                    }
                }
        )
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
