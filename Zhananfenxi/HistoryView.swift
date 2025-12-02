//
//  HistoryView.swift
//  Zhananfenxi
//
//  历史记录列表页面
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var historyManager: HistoryManager
    @State private var showDeleteAlert = false
    @State private var selectedHistory: AnalysisHistory?
    
    init(modelContext: ModelContext) {
        _historyManager = StateObject(wrappedValue: HistoryManager(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if historyManager.histories.isEmpty {
                    // 空状态
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: "暂无历史记录",
                        message: "上传聊天截图，开始你的第一次分析"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 历史记录列表
                    List {
                        ForEach(historyManager.histories) { history in
                            NavigationLink {
                                HistoryDetailView(history: history)
                            } label: {
                                HistoryRowView(history: history)
                            }
                        }
                        .onDelete(perform: deleteHistories)
                    }
                }
            }
            .navigationTitle("历史记录")
            .toolbar {
                if !historyManager.histories.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("清空", systemImage: "trash")
                        }
                    }
                }
            }
            .alert("清空历史记录", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("清空", role: .destructive) {
                    historyManager.clearAllHistories()
                }
            } message: {
                Text("确定要清空所有历史记录吗？此操作不可恢复。")
            }
        }
    }
    
    private func deleteHistories(at offsets: IndexSet) {
        for index in offsets {
            let history = historyManager.histories[index]
            historyManager.deleteHistory(history)
        }
    }
}

// MARK: - 历史记录行视图

struct HistoryRowView: View {
    let history: AnalysisHistory
    
    var body: some View {
        HStack(spacing: 15) {
            // 缩略图或默认图标
            if let imageData = history.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 5) {
                // 日期
                Text(history.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 摘要
                Text(history.summary)
                    .font(.subheadline)
                    .lineLimit(2)
                
                // 评分
                HStack {
                    Text("渣男指数: \(100 - history.overallScore)%")
                        .font(.caption)
                        .foregroundColor(scoreColor(score: history.overallScore))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(scoreColor(score: history.overallScore).opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 5)
    }
    
    private func scoreColor(score: Int) -> Color {
        if score < 50 { return .red }
        if score < 80 { return .orange }
        return .green
    }
}

// MARK: - 历史记录详情页

struct HistoryDetailView: View {
    let history: AnalysisHistory
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 显示原图
                if let imageData = history.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                }
                
                // 显示分析结果
                ResultCardView(result: history.toAnalysisResult())
            }
        }
        .navigationTitle("分析详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}

