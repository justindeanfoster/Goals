import SwiftUI

struct CalendarSectionView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    let hasJournalEntry: (Date) -> Bool
    let onDateSelected: (Date) -> Void
    let isDeadlineDate: ((Date) -> Bool)?
    @Binding var showCalendar: Bool
    @State private var lastTimeframeUpdate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {  // Added spacing: 0
            Button(action: {
                withAnimation {
                    showCalendar.toggle()
                }
            }) {
                HStack {
                    Text("Activity Calendar")
                        .font(.headline)
                    Image(systemName: showCalendar ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.blue)
                .padding(.bottom, 5)
            }
            
            VStack(spacing: 5) { // New container for consistent spacing
                if !showCalendar {
                    WeekRangeView(calendarViewModel: calendarViewModel)
                }
                
                // Days of week header - now outside conditional rendering
                // HStack {
                //     ForEach(calendarViewModel.daysOfWeek, id: \.self) { day in
                //         Text(day)
                //             .font(.subheadline)
                //             .frame(maxWidth: .infinity)
                //     }
                // }
                // .padding(.bottom, 5)
                
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
            }.padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .onChange(of: showCalendar) { _, _ in
            lastTimeframeUpdate = Date()
        }
        .onChange(of: calendarViewModel.timeframeChanged) { _, _ in
            lastTimeframeUpdate = Date()
        }
        
    }
}
