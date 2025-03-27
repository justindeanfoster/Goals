import SwiftUI

struct StatisticsItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

struct StatisticsSectionView: View {
    let statistics: [StatisticsItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Statistics")
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(statistics) { stat in
                HStack {
                    Text(stat.label)
                    Spacer()
                    Text(stat.value)
                }
                .padding(.bottom, 2)
            }
        }
        .padding(.bottom)
    }
}
