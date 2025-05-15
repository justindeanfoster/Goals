import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasDeadline: Bool
    let hasMilestone: Bool
    let cellColor: Color  // Renamed from progressColor
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                if hasDeadline {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 35, height: 35)
                        .zIndex(1)
                }
                if isSelected {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 35, height: 35)
                        .zIndex(1)
                }
                if hasMilestone {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 35, height: 35)
                        .zIndex(0)
                }
                Circle()
                    .fill(cellColor)
                    .frame(width: 30, height: 30)
                    .zIndex(2)
                    .overlay(
                        Text(Calendar.current.component(.day, from: date).description)
                            .font(.caption)
                            .foregroundColor(.white)
                            .zIndex(3)
                    )
            }
            .frame(width: 35, height: 35)
            .onTapGesture(perform: onTap)
        }
        .frame(height: 35)
    }
}
