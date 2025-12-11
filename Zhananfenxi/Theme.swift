//
//  Theme.swift
//  恋爱军师
//
//  统一的主题配色管理
//  支持暗黑模式自适应
//

import SwiftUI

// MARK: - 主题颜色

struct AppTheme {
    
    // MARK: - 粉色系主色调（自适应暗黑模式）
    
    /// 浅粉色 - 用于背景、导航栏
    static let lightPink = Color(
        light: Color(red: 1.0, green: 0.75, blue: 0.8),
        dark: Color(red: 0.4, green: 0.25, blue: 0.3)
    )
    
    /// 中粉色 - 用于按钮、强调元素
    static let accentPink = Color(
        light: Color(red: 0.95, green: 0.4, blue: 0.55),
        dark: Color(red: 0.95, green: 0.5, blue: 0.65)
    )
    
    /// 深粉色 - 用于深色强调、图标
    static let darkPink = Color(
        light: Color(red: 0.8, green: 0.2, blue: 0.4),
        dark: Color(red: 0.9, green: 0.4, blue: 0.6)
    )
    
    /// 极浅粉 - 用于卡片背景
    static let softPink = Color(
        light: Color(red: 1.0, green: 0.9, blue: 0.92),
        dark: Color(red: 0.25, green: 0.2, blue: 0.22)
    )
    
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
    
    // MARK: - 文字颜色（自适应）
    
    /// 主要文字颜色
    static let textPrimary = Color(
        light: Color(red: 0.3, green: 0.2, blue: 0.25),
        dark: Color(red: 0.95, green: 0.92, blue: 0.94)
    )
    
    /// 次要文字颜色
    static let textSecondary = Color(
        light: Color(red: 0.5, green: 0.4, blue: 0.45),
        dark: Color(red: 0.7, green: 0.65, blue: 0.68)
    )
    
    /// 深色文字（主要文字）- 保持向后兼容
    static let textDark = textPrimary
    
    /// 浅色文字（次要文字）- 保持向后兼容
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
    
    /// 卡片阴影（自适应）
    static let cardShadow = Color(
        light: Color.black.opacity(0.1),
        dark: Color.black.opacity(0.3)
    )
}

// MARK: - Color 扩展

extension Color {
    /// 主题快捷访问
    static let theme = AppTheme.self
    
    /// 创建支持明暗模式的自适应颜色
    /// - Parameters:
    ///   - light: 浅色模式下的颜色
    ///   - dark: 深色模式下的颜色
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(dynamicProvider: { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        }))
    }
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
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(20)
            .shadow(
                color: AppTheme.cardShadow,
                radius: colorScheme == .dark ? 10 : 8,
                x: 0,
                y: colorScheme == .dark ? 5 : 4
            )
    }
}

extension View {
    func cardStyle(backgroundColor: Color = AppTheme.softPink) -> some View {
        modifier(CardModifier(backgroundColor: backgroundColor))
    }
}

// MARK: - 预览

#Preview("浅色模式") {
    ThemePreviewContent()
        .preferredColorScheme(.light)
}

#Preview("深色模式") {
    ThemePreviewContent()
        .preferredColorScheme(.dark)
}

struct ThemePreviewContent: View {
    var body: some View {
        ScrollView {
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
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("这是一个使用新配色的卡片示例，支持暗黑模式自适应。")
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .cardStyle()
                .padding(.horizontal)
                
                // 文字颜色展示
                VStack(alignment: .leading, spacing: 10) {
                    Text("主要文字")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("次要文字")
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .cardStyle()
                .padding(.horizontal)
            }
            .padding()
        }
        .background(AppTheme.background)
    }
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

