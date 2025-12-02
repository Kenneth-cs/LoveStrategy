//
//  ZhananfenxiApp.swift
//  Zhananfenxi
//
//  Created by zhangshaocong6 on 2025/12/1.
//

import SwiftUI
import SwiftData

@main
struct ZhananfenxiApp: App {
    
    init() {
        // App 启动时请求网络权限
        requestNetworkPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: AnalysisHistory.self)
    }
    
    /// 在 App 启动时触发网络权限请求
    private func requestNetworkPermission() {
        // 发起一个简单的网络请求来触发系统的网络权限弹窗
        Task {
            do {
                // 请求一个轻量级的 URL 来触发权限
                let url = URL(string: "https://www.apple.com")!
                let (_, _) = try await URLSession.shared.data(from: url)
                print("✅ 网络权限已获取")
            } catch {
                print("⚠️ 网络权限请求: \(error.localizedDescription)")
            }
        }
    }
}

