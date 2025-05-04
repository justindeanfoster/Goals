import SwiftUI

struct WeekRangeView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    
    private var weekRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: calendarViewModel.startOfWeek)!
        return "\(formatter.string(from: calendarViewModel.startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: { calendarViewModel.moveWeek(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            
            Text(weekRange)
                .font(.headline) // Changed from .subheadline to .headline
                .padding() // Added padding to match month view
                .frame(minWidth: 120)
            
            Button(action: { calendarViewModel.moveWeek(by: 1) }) {
                Image(systemName: "chevron.right")
            }
            
            Spacer()
        }
        // .padding(.vertical, 5)
    }
}
