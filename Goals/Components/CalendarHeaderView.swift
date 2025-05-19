import SwiftUI

struct CalendarHeaderView: View {
    let title: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                }
                
                Text(title)
                    .font(.headline)
                
                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                }
            }
            
            Spacer()
            
            Button(action: onToday) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
            }
        }
        .padding(.horizontal)
    }
}
