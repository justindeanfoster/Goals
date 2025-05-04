import SwiftUI

struct CalendarSectionView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let hasJournalEntry: (Date) -> Bool
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    @Binding var showCalendar: Bool
    @State private var lastTimeframeUpdate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 5) {
                if !showCalendar {
                    WeekRangeView(calendarViewModel: calendarViewModel)
                }
                
                if showCalendar {
                    CalendarGridView(
                        calendarViewModel: calendarViewModel,
                        hasJournalEntry: hasJournalEntry,
                        onDateSelected: onDateSelected,
                        isDeadlineDate: isDeadlineDate
                    )
                } else {
                    WeekGridView(
                        calendarViewModel: calendarViewModel,
                        hasJournalEntry: hasJournalEntry,
                        onDateSelected: onDateSelected,
                        isDeadlineDate: isDeadlineDate
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
