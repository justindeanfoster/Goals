import SwiftUI

struct HalfYearGridView: View {
    let entries: [Date]
    @ObservedObject var calendarViewModel: CalendarViewModel
    private let rows = Array(repeating: GridItem(.fixed(8), spacing: 1), count: 7)
    
    private var lastSixMonthsDates: [(Date, Bool)] {
        let calendar = Calendar.current
        let today = Date()
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: today)!
        let startOfSixMonthsAgo = calendar.startOfDay(for: sixMonthsAgo)
        
        var dates: [(Date, Bool)] = []
        var currentDate = startOfSixMonthsAgo
        
        while currentDate <= today {
            let hasEntry = entries.contains { calendar.isDate($0, inSameDayAs: currentDate) }
            dates.append((currentDate, hasEntry))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 1) {
                ForEach(lastSixMonthsDates, id: \.0) { date, hasEntry in
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