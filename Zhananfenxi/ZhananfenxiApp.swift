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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: AnalysisHistory.self)
    }
}

