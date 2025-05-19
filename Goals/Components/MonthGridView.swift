import SwiftUI

struct MonthGridView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    let milestoneCompletions: ((Date) -> Bool)?
    let getDateColor: (Date) -> Color
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Spacer()
                Spacer()

                Button(action: { calendarViewModel.moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Text(calendarViewModel.startOfMonth, formatter: monthFormatter)
                    .font(.headline)
                    .padding()
                Button(action: { calendarViewModel.moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
                
                Spacer()
                
                Button(action: {
                    calendarViewModel.selectedDate = Date()
                    calendarViewModel.currentMonth = Date()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                Spacer()
            }
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
