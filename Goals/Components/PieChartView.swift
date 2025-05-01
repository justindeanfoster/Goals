import SwiftUI

struct PieSlice: Identifiable {
    let id = UUID()
    let value: Double
    let color: Color
    let label: String
}

struct PieChartView: View {
    let slices: [PieSlice]
    let title: String
    
    private var total: Double {
        slices.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 4)
            }
            
            HStack(alignment: .center, spacing: 20) {
                // Pie Chart
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2
                    var startAngle = Angle.degrees(-90)
                    
                    for slice in slices {
                        let angle = Angle.degrees(360 * (slice.value / total))
                        let endAngle = startAngle + angle
                        
                        let path = Path { p in
                            p.move(to: center)
                            p.addArc(center: center, radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
                            p.closeSubpath()
                        }
                        
                        context.fill(path, with: .color(slice.color))
                        startAngle = endAngle
                    }
                }
                .frame(width: 150, height: 150)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(slices) { slice in
                        HStack {
                            Circle()
                                .fill(slice.color)
                                .frame(width: 10, height: 10)
                            Text(slice.label)
                                .font(.caption)
                            Spacer()
                            Text("\(Int((slice.value / total) * 100))%")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
