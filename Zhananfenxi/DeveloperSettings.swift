//
//  DeveloperSettings.swift
//  恋爱军师
//
//  开发者设置
//

import SwiftUI

/// 开发者设置管理
class DeveloperSettings: ObservableObject {
    
    static let shared = DeveloperSettings()
    
    /// 是否使用模拟购买（true=模拟，false=真实）
    @Published var useSimulatedPurchase: Bool {
        didSet {
            UserDefaults.standard.set(useSimulatedPurchase, forKey: "dev_useSimulatedPurchase")
            print("💡 购买模式切换为: \(useSimulatedPurchase ? "模拟" : "真实")")
        }
    }
    
    /// 是否显示开发者菜单
    @Published var showDeveloperMenu: Bool {
        didSet {
            UserDefaults.standard.set(showDeveloperMenu, forKey: "dev_showDeveloperMenu")
        }
    }
    
    private init() {
        // 默认使用模拟购买（安全）
        self.useSimulatedPurchase = UserDefaults.standard.object(forKey: "dev_useSimulatedPurchase") as? Bool ?? true
        self.showDeveloperMenu = UserDefaults.standard.bool(forKey: "dev_showDeveloperMenu")
    }
    
    /// 重置所有桃花签（测试用）
    @MainActor
    func resetCoins() {
        PeachBlossomManager.shared.resetAll()
        print("🔄 桃花签已重置")
    }
    
    /// 添加测试金币
    @MainActor
    func addTestCoins(_ amount: Int) {
        PeachBlossomManager.shared.addCoins(amount, source: "测试")
        print("✅ 添加测试金币: \(amount)签")
    }
}

// MARK: - 开发者设置界面

struct DeveloperSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = DeveloperSettings.shared
    @ObservedObject var coinManager: PeachBlossomManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("购买设置") {
                    Toggle(isOn: $settings.useSimulatedPurchase) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("使用模拟购买")
                                .font(.body)
                            Text(settings.useSimulatedPurchase ? "当前：模拟购买（免费）" : "当前：真实购买（StoreKit 2）")
                                .font(.caption)
                                .foregroundColor(settings.useSimulatedPurchase ? .green : .orange)
                        }
                    }
                    
                    if !settings.useSimulatedPurchase {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("真实购买模式已开启")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("测试工具") {
                    Button {
                        settings.addTestCoins(100)
                    } label: {
                        Label("添加 100 签（测试）", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        settings.addTestCoins(1000)
                    } label: {
                        Label("添加 1000 签（测试）", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    
                    Button(role: .destructive) {
                        settings.resetCoins()
                    } label: {
                        Label("重置桃花签", systemImage: "trash.fill")
                    }
                }
                
                Section("当前状态") {
                    HStack {
                        Text("桃花签余额")
                        Spacer()
                        Text("\(coinManager.balance) 签")
                            .foregroundColor(AppTheme.accentPink)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("购买模式")
                        Spacer()
                        Text(settings.useSimulatedPurchase ? "模拟" : "真实")
                            .foregroundColor(settings.useSimulatedPurchase ? .green : .orange)
                            .fontWeight(.semibold)
                    }
                }
                
                Section {
                    Text("⚠️ 开发者设置仅用于测试\n正式上线前请关闭模拟购买")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("开发者设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DeveloperSettingsView(coinManager: PeachBlossomManager.shared)
}

