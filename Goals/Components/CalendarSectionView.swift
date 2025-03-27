import SwiftUI

struct CalendarSectionView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let hasJournalEntry: (Date) -> Bool
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    @Binding var showCalendar: Bool
    @State private var lastTimeframeUpdate = Date()
    
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
        .onChange(of: showCalendar) { _, _ in
            lastTimeframeUpdate = Date()
        }
        .onChange(of: calendarViewModel.timeframeChanged) { _, _ in
            lastTimeframeUpdate = Date()
        }
    }
}
