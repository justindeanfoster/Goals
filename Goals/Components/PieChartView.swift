import SwiftUI

struct PieSlice: Identifiable {
    let id = UUID()
    let value: Double
    let color: Color
    let label: String
}

struct SliceData {
    let startAngle: Angle
    let endAngle: Angle
    let slice: PieSlice
}

enum PieChartAlignment {
    case left, right
}

struct PieChartView: View {
    let slices: [PieSlice]
    let title: String
    let alignment: PieChartAlignment  // This property is no longer needed but kept for compatibility
    
    @State private var selectedSlice: PieSlice?
    @State private var highlightLocation: CGPoint = .zero
    
    init(slices: [PieSlice], title: String, alignment: PieChartAlignment = .left) {
        self.slices = slices
        self.title = title
        self.alignment = alignment
    }
    
    private var total: Double {
        slices.reduce(0) { $0 + $1.value }
    }
    
    private var slicesData: [SliceData] {
        // Ensure the order of slicesData matches the legend and the drawing order
        var startAngle = Angle.degrees(-90)
        return slices.enumerated().map { (index, slice) in
            let angle = Angle.degrees(360 * (slice.value / total))
            let endAngle = startAngle + angle
            let data = SliceData(startAngle: startAngle, endAngle: endAngle, slice: slice)
            startAngle = endAngle
            return data
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
            }
            
            GeometryReader { geometry in
                pieChart
                    .frame(
                        width: min(geometry.size.width, geometry.size.height),
                        height: min(geometry.size.width, geometry.size.height)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }
    
    private var pieChart: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            for sliceData in slicesData {
                let path = Path { p in
                    p.move(to: center)
                    // Draw COUNTERCLOCKWISE, starting at -90°
                    p.addArc(center: center,
                             radius: radius,
                             startAngle: sliceData.startAngle,
                             endAngle: sliceData.endAngle,
                             clockwise: false)
                    p.closeSubpath()
                }
                context.fill(path, with: .color(sliceData.slice.color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateSelectedSlice(at: value.location, in: geometry.size)
                                highlightLocation = value.location
                            }
                            .onEnded { _ in
                                withAnimation {
                                    selectedSlice = nil
                                }
                            }
                    )
                if let selected = selectedSlice {
                    let text = "\(selected.label): \(Int((selected.value / total) * 100))%"
                    // Offset the hover above the tap location
                    Text(text)
                        .font(.caption)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .position(x: highlightLocation.x, y: max(0, highlightLocation.y - 36))
                        .transition(.opacity)
                }
            }
        }
    }

    private func updateSelectedSlice(at point: CGPoint, in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2

        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)

        guard distance <= radius else {
            selectedSlice = nil
            return
        }

        // Calculate the touch angle relative to the drawing's starting angle (-90°)
        let touchAngle = atan2(dy, dx) * 180 / .pi   // standard angle in degrees
        var relativeTouchAngle = (touchAngle + 90).truncatingRemainder(dividingBy: 360)
        if relativeTouchAngle < 0 { relativeTouchAngle += 360 }

        // Iterate slicesData; each slice's relative start is (slice.startAngle + 90) modulo 360.
        for sliceData in slicesData {
            let arcLength = sliceData.endAngle.degrees - sliceData.startAngle.degrees
            var sliceStart = (sliceData.startAngle.degrees + 90).truncatingRemainder(dividingBy: 360)
            if sliceStart < 0 { sliceStart += 360 }
            let sliceEnd = sliceStart + arcLength

            if relativeTouchAngle >= sliceStart && relativeTouchAngle < sliceEnd {
                selectedSlice = sliceData.slice
                return
            }
        }
        selectedSlice = nil
    }
}
