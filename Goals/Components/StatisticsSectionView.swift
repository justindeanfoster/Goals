import SwiftUI

struct StatisticRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

struct StatisticsSectionView: View {
    let statistics: [StatisticRow]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(statistics) { stat in
                HStack {
                    Text(stat.label)
                    Spacer()
                    Text(stat.value)
                }
                .padding(.bottom, 2)
            }
        }
    }
}
