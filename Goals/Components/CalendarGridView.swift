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
                            if isToday {
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
                        .frame(width: 35, height: 35)  // Fixed frame for the ZStack
                        .onTapGesture {
                            calendarViewModel.selectedDate = date
                            DispatchQueue.main.async {
                                onDateSelected(date)
                            }
                        }
                    }
                    .frame(height: 35)  // Fixed height for the VStack
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
