//
//  ErrorView.swift
//  恋爱军师
//
//  优化的错误提示界面
//

import SwiftUI

// MARK: - 错误类型

enum AppError: Error, Identifiable {
    case networkError
    case apiError(message: String)
    case imageError
    case limitReached
    case unknown(message: String)
    
    var id: String {
        switch self {
        case .networkError: return "network"
        case .apiError(let msg): return "api_\(msg)"
        case .imageError: return "image"
        case .limitReached: return "limit"
        case .unknown(let msg): return "unknown_\(msg)"
        }
    }
    
    var title: String {
        switch self {
        case .networkError:
            return "网络连接失败"
        case .apiError:
            return "AI 分析失败"
        case .imageError:
            return "图片加载失败"
        case .limitReached:
            return "使用次数已达上限"
        case .unknown:
            return "出错了"
        }
    }
    
    var message: String {
        switch self {
        case .networkError:
            return "请检查您的网络连接后重试"
        case .apiError(let msg):
            return msg
        case .imageError:
            return "无法加载图片，请选择其他图片"
        case .limitReached:
            return UsageLimitManager.getLimitReachedMessage()
        case .unknown(let msg):
            return msg
        }
    }
    
    var icon: String {
        switch self {
        case .networkError:
            return "wifi.slash"
        case .apiError:
            return "exclamationmark.triangle"
        case .imageError:
            return "photo.badge.exclamationmark"
        case .limitReached:
            return "hourglass.circle"
        case .unknown:
            return "questionmark.circle"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .networkError:
            return .orange
        case .apiError:
            return .red
        case .imageError:
            return .yellow
        case .limitReached:
            return .purple
        case .unknown:
            return .gray
        }
    }
}

// MARK: - 错误展示视图

struct ErrorView: View {
    let error: AppError
    let retryAction: (() -> Void)?
    let dismissAction: (() -> Void)?
    
    init(
        error: AppError,
        retryAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) {
        self.error = error
        self.retryAction = retryAction
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 错误图标
            Image(systemName: error.icon)
                .font(.system(size: 60))
                .foregroundColor(error.iconColor)
            
            // 标题
            Text(error.title)
                .font(.title2)
                .fontWeight(.bold)
            
            // 消息
            Text(error.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 操作按钮
            HStack(spacing: 15) {
                if let dismiss = dismissAction {
                    Button {
                        dismiss()
                    } label: {
                        Text("关闭")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(minWidth: 100)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                
                if let retry = retryAction {
                    Button {
                        retry()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("重试")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(minWidth: 100)
                        .padding()
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - 空状态视图

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.gray.opacity(0.3), .gray.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 10) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
        }
        .padding(40)
    }
}

// MARK: - 预览

#Preview("网络错误") {
    ErrorView(
        error: .networkError,
        retryAction: {},
        dismissAction: {}
    )
}

#Preview("API 错误") {
    ErrorView(
        error: .apiError(message: "AI 服务暂时不可用，请稍后重试"),
        retryAction: {},
        dismissAction: {}
    )
}

#Preview("次数限制") {
    ErrorView(
        error: .limitReached,
        dismissAction: {}
    )
}

#Preview("空状态") {
    EmptyStateView(
        icon: "clock.arrow.circlepath",
        title: "暂无历史记录",
        message: "上传聊天截图，开始你的第一次分析",
        actionTitle: "开始分析",
        action: {}
    )
}

