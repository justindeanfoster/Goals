import SwiftUI

struct HistogramBin {
    let count: Int
    let weekNumber: Int
}

struct MonthSection {
    let month: String
    let bins: [HistogramBin]
}

struct HistogramView: View {
    let monthSections: [MonthSection]
    let maxCount: Int  // This parameter is no longer needed but kept for compatibility
    let timeRange: TimeRange
    
    private let yAxisWidth: CGFloat = 35  // Increased from 30 to accommodate labels
    private let minBarWidth: CGFloat = 15
    private let horizontalLinesCount = 5
    private let sectionHeight: CGFloat = 200  // Reduced from 220
    private let graphHeight: CGFloat = 160    // Keep this the same
    private let verticalPadding: CGFloat = 4  // Reduced from 8
    
    private var effectiveMaxCount: Int {
        // Use actual maximum count from data
        let actualMax = monthSections.flatMap { $0.bins }.map { $0.count }.max() ?? 0
        return max(actualMax, 1) // Ensure we have at least 1 line
    }
    
    // Calculate dynamic spacing and width
    private func calculateBarMetrics(availableWidth: CGFloat) -> (barWidth: CGFloat, spacing: CGFloat) {
        let totalBins = monthSections.reduce(0) { $0 + $1.bins.count }
        let minTotalWidth = CGFloat(totalBins) * minBarWidth
        
        if minTotalWidth < availableWidth {
            // If minimum width is less than available, expand to fill
            let barWidth = availableWidth / CGFloat(totalBins)
            return (barWidth: barWidth * 0.8, spacing: barWidth * 0.2)
        } else {
            // Otherwise use minimum width with tight spacing
            return (barWidth: minBarWidth, spacing: 4)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let metrics = calculateBarMetrics(availableWidth: geometry.size.width - yAxisWidth)
            
            VStack {  // Added VStack for vertical centering
                Spacer()
                HStack(spacing: 0) {
                    // Y-axis labels
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(effectiveMaxCount)")
                            .font(.caption)
                            .frame(width: yAxisWidth, alignment: .trailing)
                            .frame(height: graphHeight / CGFloat(horizontalLinesCount))
                        
                        ForEach(1..<horizontalLinesCount, id: \.self) { i in
                            Text("\(effectiveMaxCount - (i * effectiveMaxCount / horizontalLinesCount))")
                                .font(.caption)
                                .frame(width: yAxisWidth, alignment: .trailing)
                                .frame(height: graphHeight / CGFloat(horizontalLinesCount))
                        }
                        
                        Text("0")
                            .font(.caption)
                            .frame(width: yAxisWidth, alignment: .trailing)
                            .frame(height: graphHeight / CGFloat(horizontalLinesCount))
                    }
                    .frame(width: yAxisWidth)
                    
                    // Scrollable data section with adjusted alignment
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                // Grid lines aligned with y-axis labels
                                VStack(spacing: graphHeight / CGFloat(horizontalLinesCount)) {
                                    ForEach((0...horizontalLinesCount).reversed(), id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 1)
                                            .offset(y: -0.5) // Adjust line position to align with labels
                                    }
                                }
                                .frame(height: graphHeight)
                                
                                // Bars aligned with grid
                                VStack(alignment: .leading, spacing: 2) { // Reduced spacing from 4
                                    HStack(alignment: .bottom, spacing: metrics.spacing) {
                                        ForEach(monthSections, id: \.month) { section in
                                            ForEach(section.bins, id: \.weekNumber) { bin in
                                                Rectangle()
                                                    .fill(bin.count == 0 ? Color.red.opacity(0.7) : Color.green.opacity(0.7))
                                                    .frame(width: metrics.barWidth, 
                                                          height: max(bin.count == 0 ? 2 : (CGFloat(bin.count) * graphHeight / CGFloat(effectiveMaxCount)), 0))
                                            }
                                        }
                                    }
                                    .frame(height: graphHeight, alignment: .bottom)
                                    
                                    // Month labels with less spacing
                                    HStack(alignment: .bottom, spacing: metrics.spacing) {
                                        ForEach(monthSections, id: \.month) { section in
                                            Text(section.month)
                                                .font(.caption)
                                                .rotationEffect(.degrees(-45))
                                                .frame(width: CGFloat(section.bins.count) * (metrics.barWidth + metrics.spacing) - metrics.spacing)
                                        }
                                    }
                                    .padding(.leading, metrics.barWidth/2)
                                }
                            }
                            .padding(.vertical, verticalPadding)  // Use smaller vertical padding
                            .frame(minWidth: geometry.size.width - yAxisWidth)
                        }
                        .onChange(of: timeRange) { _, _ in
                            withAnimation {
                                // Scroll to most recent data for shorter time ranges
                                if timeRange != .allTime && timeRange != .year {
                                    proxy.scrollTo(monthSections.last?.month, anchor: .trailing)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .frame(height: sectionHeight)  // Fixed overall height
    }
}
