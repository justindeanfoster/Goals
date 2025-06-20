import SwiftUI

struct HistogramBin {
    let count: Int
    let weekNumber: Int
}

struct MonthSection {
    let month: String
    let bins: [HistogramBin]
}

// New view for an individual histogram bar without hover label
struct HistogramBarView: View {
    let bin: HistogramBin
    let barWidth: CGFloat
    let graphHeight: CGFloat
    let effectiveMaxCount: Int

    var barHeight: CGFloat {
        max(bin.count == 0 ? 2 : (CGFloat(bin.count) * graphHeight / CGFloat(effectiveMaxCount)), 0)
    }

    var body: some View {
        Rectangle()
            .fill(bin.count == 0 ? Color.red.opacity(0.7) : Color.green.opacity(0.7))
            .frame(width: barWidth, height: barHeight)
    }
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
    
    private func calculateYAxisScale(maxValue: Int) -> (increment: Int, maxScale: Int) {
        let baseIncrements = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
        let targetSteps = 5
        
        // Find the appropriate increment
        let increment = baseIncrements.first { inc in
            let steps = (maxValue + inc) / inc
            return steps <= targetSteps
        } ?? 1
        
        // Calculate the max scale, ensuring we go one increment over unless maxValue is already on an increment
        let maxScale = maxValue % increment == 0 ? maxValue : ((maxValue / increment) + 1) * increment
        
        return (increment, maxScale)
    }
    
    private var yAxisLabels: [Int] {
        let maxCount = monthSections.flatMap { $0.bins }.map { $0.count }.max() ?? 0
        let (increment, maxScale) = calculateYAxisScale(maxValue: maxCount)
        return stride(from: 0, through: maxScale, by: increment).reversed()
    }
    
    private var effectiveMaxCount: Int {
        yAxisLabels.max() ?? 1
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
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Scrollable data section first (switched order)
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
                                                HistogramBarView(
                                                    bin: bin,
                                                    barWidth: metrics.barWidth,
                                                    graphHeight: graphHeight,
                                                    effectiveMaxCount: effectiveMaxCount
                                                )
                                            }
                                        }
                                    }
                                    .frame(height: graphHeight, alignment: .bottom)
                                    
                                    // Month labels with flat orientation
                                    HStack(alignment: .top, spacing: metrics.spacing) {
                                        ForEach(monthSections, id: \.month) { section in
                                            Text(section.month)
                                                .font(.caption)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
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
                        // Added simultaneousGesture to let scroll gestures work alongside hover detection
                        .simultaneousGesture(DragGesture())
                        .onChange(of: timeRange) { _, _ in
                            withAnimation {
                                // Scroll to most recent data for shorter time ranges
                                if timeRange != .allTime && timeRange != .year {
                                    proxy.scrollTo(monthSections.last?.month, anchor: .trailing)
                                }
                            }
                        }
                    }
                    
                    // Y-axis labels now on the right
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(yAxisLabels, id: \.self) { value in
                            Text("\(value)")
                                .font(.caption)
                                .frame(width: yAxisWidth, alignment: .leading)
                                .frame(height: graphHeight / CGFloat(yAxisLabels.count - 1))
                        }
                    }
                    .frame(width: yAxisWidth, height: graphHeight)
                }
            }
        }
        .frame(height: sectionHeight)
    }
}
