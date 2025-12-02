//
//  SkeletonView.swift
//  恋爱军师
//
//  骨架屏 Loading 效果
//

import SwiftUI

// MARK: - 骨架屏修饰器

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.clear, location: 0),
                        .init(color: Color.white.opacity(0.6), location: 0.5),
                        .init(color: Color.clear, location: 1)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(70))
                .offset(x: phase)
            )
            .onAppear {
                withAnimation(
                    Animation
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - 分析加载骨架屏

struct AnalysisLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 16)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 40)
                }
                
                Spacer()
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
            .shimmer()
            
            Divider()
            
            // 雷达图占位
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 250)
                .shimmer()
            
            Divider()
            
            // 文本内容占位
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 20)
                
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 16)
                }
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 16)
            }
            .shimmer()
            
            Divider()
            
            // 建议占位
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 20)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 80)
            }
            .shimmer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .padding()
    }
}

// MARK: - 带动画的加载提示

struct AnimatedLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 动画 Logo
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.iconGradient)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.6 : 1.0)
                .animation(
                    Animation
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // 加载文字
            VStack(spacing: 8) {
                Text("AI 正在分析中...")
                    .font(.headline)
                
                Text("深度解读聊天内容")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 进度指示器
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accentPink))
                .scaleEffect(1.5)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 10)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - 回复助手加载

struct ReplyLoadingView: View {
    @State private var dotCount = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "message.badge.waveform")
                .foregroundColor(AppTheme.accentPink)
            
            Text("AI 正在生成回复\(String(repeating: ".", count: dotCount))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.softPink)
        .cornerRadius(12)
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}

// MARK: - 预览

#Preview("分析加载") {
    AnalysisLoadingView()
}

#Preview("动画加载") {
    AnimatedLoadingView()
}

#Preview("回复加载") {
    ReplyLoadingView()
}

