//
//  RadarChartView.swift
//  Zhananfenxi
//
//  六边形雷达图组件
//

import SwiftUI

struct RadarChartView: View {
    let dimensions: [DimensionScore]
    let maxValue: Double = 100.0
    
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("七维分析")
                .font(.headline)
            
            ZStack {
                // 背景网格（3层）
                ForEach([0.33, 0.66, 1.0], id: \.self) { scale in
                    RadarPolygon(sides: dimensions.count, scale: scale)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }
                
                // 数据区域（填充）
                RadarDataShape(dimensions: dimensions, maxValue: maxValue, animationProgress: animationProgress)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.8, green: 0.2, blue: 0.4).opacity(0.3),
                                Color(red: 0.6, green: 0.1, blue: 0.6).opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // 数据边框
                RadarDataShape(dimensions: dimensions, maxValue: maxValue, animationProgress: animationProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.8, green: 0.2, blue: 0.4),
                                Color(red: 0.6, green: 0.1, blue: 0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                
                // 数据点
                ForEach(Array(dimensions.enumerated()), id: \.offset) { index, dimension in
                    let angle = angleForIndex(index, total: dimensions.count)
                    let radius = CGFloat(dimension.score / maxValue) * 120 * animationProgress
                    let point = pointOnCircle(angle: angle, radius: radius)
                    
                    Circle()
                        .fill(Color(red: 0.8, green: 0.2, blue: 0.4))
                        .frame(width: 8, height: 8)
                        .position(x: point.x + 150, y: point.y + 150)
                }
                
                // 维度标签
                ForEach(Array(dimensions.enumerated()), id: \.offset) { index, dimension in
                    let angle = angleForIndex(index, total: dimensions.count)
                    let labelRadius: CGFloat = 140
                    let point = pointOnCircle(angle: angle, radius: labelRadius)
                    
                    VStack(spacing: 2) {
                        Text(dimension.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("\(Int(dimension.score))")
                            .font(.caption2)
                            .foregroundColor(scoreColor(score: dimension.score))
                    }
                    .position(x: point.x + 150, y: point.y + 150)
                }
            }
            .frame(width: 300, height: 300)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
        .padding()
    }
    
    private func angleForIndex(_ index: Int, total: Int) -> Double {
        let anglePerSide = 360.0 / Double(total)
        return Double(index) * anglePerSide - 90 // -90 让第一个点在顶部
    }
    
    private func pointOnCircle(angle: Double, radius: CGFloat) -> CGPoint {
        let radians = angle * .pi / 180
        let x = radius * cos(radians)
        let y = radius * sin(radians)
        return CGPoint(x: x, y: y)
    }
    
    private func scoreColor(score: Double) -> Color {
        if score < 50 { return .red }
        if score < 80 { return .orange }
        return .green
    }
}

// MARK: - 雷达图多边形背景

struct RadarPolygon: Shape {
    let sides: Int
    let scale: Double
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * 0.8 * scale
        
        var path = Path()
        
        for i in 0..<sides {
            let angle = angleForIndex(i, total: sides)
            let point = pointOnCircle(angle: angle, radius: radius, center: center)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
    
    private func angleForIndex(_ index: Int, total: Int) -> Double {
        let anglePerSide = 360.0 / Double(total)
        return Double(index) * anglePerSide - 90
    }
    
    private func pointOnCircle(angle: Double, radius: Double, center: CGPoint) -> CGPoint {
        let radians = angle * .pi / 180
        let x = center.x + radius * cos(radians)
        let y = center.y + radius * sin(radians)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - 雷达图数据形状

struct RadarDataShape: Shape {
    let dimensions: [DimensionScore]
    let maxValue: Double
    var animationProgress: CGFloat
    
    var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2 * 0.8
        
        var path = Path()
        
        for (index, dimension) in dimensions.enumerated() {
            let angle = angleForIndex(index, total: dimensions.count)
            let normalizedValue = dimension.score / maxValue
            let radius = maxRadius * normalizedValue * animationProgress
            let point = pointOnCircle(angle: angle, radius: radius, center: center)
            
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
    
    private func angleForIndex(_ index: Int, total: Int) -> Double {
        let anglePerSide = 360.0 / Double(total)
        return Double(index) * anglePerSide - 90
    }
    
    private func pointOnCircle(angle: Double, radius: Double, center: CGPoint) -> CGPoint {
        let radians = angle * .pi / 180
        let x = center.x + radius * cos(radians)
        let y = center.y + radius * sin(radians)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - 预览

#Preview {
    RadarChartView(dimensions: [
        DimensionScore(name: "回复速度", score: 80),
        DimensionScore(name: "关心度", score: 30),
        DimensionScore(name: "承诺兑现", score: 20),
        DimensionScore(name: "情绪稳定", score: 60),
        DimensionScore(name: "暧昧指数", score: 35),
        DimensionScore(name: "真诚度", score: 40),
        DimensionScore(name: "时间投入", score: 50)
    ])
}

