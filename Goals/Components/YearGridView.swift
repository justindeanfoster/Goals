import SwiftUI

struct YearGridView: View {
    let entries: [Date]
    @ObservedObject var calendarViewModel: CalendarViewModel
    let rows = Array(repeating: GridItem(.fixed(8), spacing: 1), count: 7)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 1) {
                ForEach(0..<calendarViewModel.daysInYear(calendarViewModel.selectedYear), id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: calendarViewModel.selectedYearStartDate) ?? calendarViewModel.selectedYearStartDate
                    let hasEntry = entries.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    let isToday = calendarViewModel.isDateToday(date)
                    
                    Rectangle()
                        .fill(hasEntry ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .cornerRadius(1)
                        .overlay(
                            isToday ? 
                                Rectangle()
                                    .stroke(Color.blue, lineWidth: 1)
                                    .cornerRadius(1) : nil
                        )
                }
            }
            .frame(height: 60)
            .padding(.vertical, 1)
        }
    }
}
