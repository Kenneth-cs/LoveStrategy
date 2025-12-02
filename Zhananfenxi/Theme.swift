//
//  Theme.swift
//  恋爱军师
//
//  统一的主题配色管理
//

import SwiftUI

// MARK: - 主题颜色

struct AppTheme {
    
    // MARK: - 粉色系主色调
    
    /// 浅粉色 - 用于背景、导航栏
    static let lightPink = Color(red: 1.0, green: 0.75, blue: 0.8)
    
    /// 中粉色 - 用于按钮、强调元素
    static let accentPink = Color(red: 0.95, green: 0.4, blue: 0.55)
    
    /// 深粉色 - 用于深色强调、图标
    static let darkPink = Color(red: 0.8, green: 0.2, blue: 0.4)
    
    /// 极浅粉 - 用于卡片背景
    static let softPink = Color(red: 1.0, green: 0.9, blue: 0.92)
    
    // MARK: - 渐变色
    
    /// 主按钮渐变（粉色系）
    static let primaryGradient = LinearGradient(
        colors: [accentPink, darkPink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// 柔和渐变（浅粉色系）
    static let softGradient = LinearGradient(
        colors: [lightPink, softPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Logo/图标渐变
    static let iconGradient = LinearGradient(
        colors: [accentPink, Color.purple.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 文字颜色
    
    /// 深色文字（主要文字）
    static let textDark = Color(red: 0.3, green: 0.2, blue: 0.25)
    
    /// 浅色文字（次要文字）
    static let textLight = Color.white
    
    // MARK: - 功能色
    
    /// 成功/安全 - 绿色
    static let success = Color.green
    
    /// 警告 - 橙色
    static let warning = Color.orange
    
    /// 危险/红旗 - 红色
    static let danger = Color.red
    
    /// 信息 - 蓝色
    static let info = Color.blue
    
    // MARK: - 背景色
    
    /// 主背景色
    static let background = Color(UIColor.systemBackground)
    
    /// 次级背景色
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    
    // MARK: - 阴影
    
    /// 卡片阴影
    static let cardShadow = Color.black.opacity(0.1)
}

// MARK: - 扩展 Color，方便使用

extension Color {
    static let theme = AppTheme.self
}

// MARK: - 按钮样式

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    if isDisabled {
                        Color.gray
                    } else {
                        AppTheme.primaryGradient
                    }
                }
            )
            .cornerRadius(30)
            .shadow(color: AppTheme.cardShadow, radius: 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppTheme.darkPink)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.softPink)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(AppTheme.accentPink, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - 卡片样式

struct CardModifier: ViewModifier {
    var backgroundColor: Color = AppTheme.softPink
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(20)
            .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(backgroundColor: Color = AppTheme.softPink) -> some View {
        modifier(CardModifier(backgroundColor: backgroundColor))
    }
}

// MARK: - 预览

#Preview("颜色展示") {
    VStack(spacing: 20) {
        // 主色调
        HStack(spacing: 15) {
            ColorBox(color: AppTheme.lightPink, name: "浅粉色")
            ColorBox(color: AppTheme.accentPink, name: "中粉色")
            ColorBox(color: AppTheme.darkPink, name: "深粉色")
            ColorBox(color: AppTheme.softPink, name: "极浅粉")
        }
        
        // 按钮样式
        VStack(spacing: 15) {
            Button("主按钮") {}
                .buttonStyle(PrimaryButtonStyle())
            
            Button("次要按钮") {}
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal)
        
        // 卡片样式
        VStack(alignment: .leading, spacing: 10) {
            Text("卡片标题")
                .font(.headline)
                .foregroundColor(AppTheme.textDark)
            
            Text("这是一个使用新配色的卡片示例")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .cardStyle()
        .padding(.horizontal)
    }
    .padding()
}

struct ColorBox: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(height: 80)
            
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

