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
    private let sectionHeight: CGFloat = 200  // Reduced from 220
    private let graphHeight: CGFloat = 160    // Keep this the same
    private let verticalPadding: CGFloat = 4  // Reduced from 8
    private let labelHeight: CGFloat = 40  // Added fixed height for labels
    
    private var effectiveMaxCount: Int {
        monthSections.flatMap { $0.bins }.map { $0.count }.max() ?? 1
    }
    
    private var yAxisLabels: [Int] {
        let max = effectiveMaxCount
        let steps = stride(from: max, through: 0, by: -(max > 5 ? max / 5 : 1))
        return Array(steps)
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
            
            VStack(spacing: 0) {  // Remove default spacing
                HStack(spacing: 0) {
                    // Y-axis labels with better alignment
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(yAxisLabels, id: \.self) { value in
                            Text("\(value)")
                                .font(.caption)
                                .frame(width: yAxisWidth, alignment: .trailing)
                                .frame(height: graphHeight / CGFloat(max(1, yAxisLabels.count - 1)))
                        }
                    }
                    .frame(width: yAxisWidth, height: graphHeight)
                    
                    // Scrollable data section
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                // Grid lines with fixed spacing
                                VStack(spacing: graphHeight / CGFloat(max(1, yAxisLabels.count - 1))) {
                                    ForEach(yAxisLabels, id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 1)
                                    }
                                }
                                .frame(height: graphHeight)
                                
                                // Bars and labels
                                VStack(alignment: .leading, spacing: 0) {
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
                                    
                                    // Month labels with fixed height
                                    HStack(alignment: .top, spacing: metrics.spacing) {
                                        ForEach(monthSections, id: \.month) { section in
                                            Text(section.month)
                                                .font(.caption)
                                                .rotationEffect(.degrees(-45))
                                                .frame(width: CGFloat(section.bins.count) * (metrics.barWidth + metrics.spacing) - metrics.spacing)
                                                .frame(height: labelHeight)
                                        }
                                    }
                                    .padding(.leading, metrics.barWidth/2)
                                }
                            }
                            .padding(.vertical, verticalPadding)
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
            }
        }
        .frame(height: sectionHeight)
    }
}
