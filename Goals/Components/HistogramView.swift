import SwiftUI

struct HistogramBin {
    let count: Int
    let weekNumber: Int
}

struct MonthSection {
    let month: String
    let bins: [HistogramBin]
}

enum HistogramDuration {
    case threeMonths, sixMonths, year
}

struct HistogramView: View {
    let monthSections: [MonthSection]
    let maxCount: Int
    @State private var selectedDuration: HistogramDuration = .threeMonths
    
    private let yAxisWidth: CGFloat = 30
    private let barSpacing: CGFloat = 4
    private let barWidth: CGFloat = 15
    private let horizontalLinesCount = 5
    
    private var effectiveMaxCount: Int {
        let actualMax = monthSections.flatMap { $0.bins }.map { $0.count }.max() ?? 0
        return max(actualMax, 5) // Ensure we have at least 5 lines
    }
    
    private var filteredMonthSections: [MonthSection] {
        let numberOfMonths: Int
        switch selectedDuration {
        case .threeMonths: numberOfMonths = 3
        case .sixMonths: numberOfMonths = 6
        case .year: numberOfMonths = 12
        }
        
        return Array(monthSections.suffix(numberOfMonths))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Existing histogram view
            HStack(spacing: 0) {
                // Fixed Y-axis
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach((0...horizontalLinesCount).reversed(), id: \.self) { i in
                        Text("\(i * effectiveMaxCount / horizontalLinesCount)")
                            .font(.caption)
                            .frame(width: yAxisWidth, alignment: .trailing)
                            .frame(height: 200.0 / CGFloat(horizontalLinesCount))
                            .offset(y: -8) // Adjust text position to align with grid lines
                    }
                }
                .frame(width: yAxisWidth)
                
                // Scrollable data section
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        // Grid lines
                        VStack(spacing: 200.0 / CGFloat(horizontalLinesCount)) {
                            ForEach((0...horizontalLinesCount).reversed(), id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 1)
                            }
                        }
                        .frame(height: 200)
                        
                        // Bars and month labels
                        VStack(alignment: .leading) {
                            // Bars
                            HStack(alignment: .bottom, spacing: barSpacing) {
                                ForEach(filteredMonthSections, id: \.month) { section in
                                    ForEach(section.bins, id: \.weekNumber) { bin in
                                        Rectangle()
                                            .fill(bin.count == 0 ? Color.red.opacity(0.7) : Color.green.opacity(0.7))
                                            .frame(width: barWidth, height: bin.count == 0 ? 2 : (CGFloat(bin.count) * 200 / CGFloat(effectiveMaxCount)) - 1) // Subtract 1 to account for grid line height
                                    }
                                }
                            }
                            .frame(height: 200, alignment: .bottom)
                            
                            // Month labels
                            HStack(alignment: .bottom, spacing: barSpacing) {
                                ForEach(filteredMonthSections, id: \.month) { section in
                                    Text(section.month)
                                        .font(.caption)
                                        .rotationEffect(.degrees(-45))
                                        .frame(width: CGFloat(section.bins.count) * (barWidth + barSpacing) - barSpacing)
                                }
                            }
                            .padding(.leading, barWidth/2)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .frame(height: 260)
            
            // Duration filter buttons
            HStack(spacing: 12) {
                FilterButton(title: "3M", isSelected: selectedDuration == .threeMonths) {
                    selectedDuration = .threeMonths
                }
                
                FilterButton(title: "6M", isSelected: selectedDuration == .sixMonths) {
                    selectedDuration = .sixMonths
                }
                
                FilterButton(title: "1Y", isSelected: selectedDuration == .year) {
                    selectedDuration = .year
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}
