import SwiftUI

struct CompactMonthGridView: View {
    let entries: [Date]
    @ObservedObject var calendarViewModel: CalendarViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min((geometry.size.width - (6 * 4)) / 7, 20) // Width minus spacing divided by 7 columns, max 20pt
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 4), count: 7), spacing: 4) {
                // Days of the month
                ForEach(0..<calendarViewModel.daysInMonth, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: .day, value: day, to: calendarViewModel.startOfMonth)!
                    let hasEntry = entries.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    
                    Rectangle()
                        .fill(hasEntry ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: cellSize, height: cellSize)
                        .cornerRadius(3)
                }
            }
        }
        .frame(height: 100) // Reduced height in the card
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
