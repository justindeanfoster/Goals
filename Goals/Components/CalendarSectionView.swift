import SwiftUI

struct CalendarSectionView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    let milestoneCompletions: ((Date) -> Bool)?
    let getDateColor: (Date) -> Color
    @Binding var showCalendar: Bool
    @State private var lastTimeframeUpdate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 5) {
                
                if showCalendar {
                    MonthGridView(
                        calendarViewModel: calendarViewModel,
                        onDateSelected: onDateSelected,
                        isDeadlineDate: isDeadlineDate,
                        milestoneCompletions: milestoneCompletions,
                        getDateColor: getDateColor
                    )
                } else {
                    WeekGridView(
                        calendarViewModel: calendarViewModel,
                        onDateSelected: onDateSelected,
                        isDeadlineDate: isDeadlineDate,
                        milestoneCompletions: milestoneCompletions,
                        getDateColor: getDateColor
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .onTapGesture {
                withAnimation {
                    showCalendar.toggle()
                }
            }
        }
        .onChange(of: showCalendar) { _, _ in
            lastTimeframeUpdate = Date()
        }
        .onChange(of: calendarViewModel.timeframeChanged) { _, _ in
            lastTimeframeUpdate = Date()
        }
    }
}
