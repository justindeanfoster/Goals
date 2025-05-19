import SwiftUI

struct WeekGridView: View {
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

                Button(action: { calendarViewModel.moveWeek(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Text(weekRange)
                    .font(.headline)
                    .padding()
                Button(action: { calendarViewModel.moveWeek(by: 1) }) {
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
            ForEach(0..<7) { offset in
                let date = Calendar.current.date(byAdding: .day, value: offset, to: calendarViewModel.startOfWeek)!
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
                        onDateSelected(date)
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
                        calendarViewModel.moveWeek(by: -1)
                    } else if value.translation.width < -50 {
                        // Swipe left - go forward
                        calendarViewModel.moveWeek(by: 1)
                    }
                }
        )
    }
    
    private var weekRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: calendarViewModel.startOfWeek)!
        return "\(formatter.string(from: calendarViewModel.startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
}
