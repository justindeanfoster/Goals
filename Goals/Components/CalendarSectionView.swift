import SwiftUI

struct CalendarSectionView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let hasJournalEntry: (Date) -> Bool
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    @Binding var showCalendar: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    showCalendar.toggle()
                }
            }) {
                HStack {
                    Text("Activity Calendar")
                        .font(.headline)
                    Spacer()
                    Image(systemName: showCalendar ? "chevron.up" : "chevron.down")
                }
                .padding(.bottom, 5)
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
    }
}
