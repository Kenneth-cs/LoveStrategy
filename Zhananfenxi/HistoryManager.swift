//
//  HistoryManager.swift
//  Zhananfenxi
//
//  本地历史记录管理（使用 SwiftData）
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - SwiftData 模型

@Model
class AnalysisHistory {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var imageData: Data?
    var overallScore: Int
    var summary: String
    var advice: String
    
    // 存储为 JSON 字符串（因为 SwiftData 不直接支持复杂嵌套对象）
    var dimensionsJSON: String
    var flagsJSON: String
    
    init(result: AnalysisResult, imageData: Data?) {
        self.id = UUID()
        self.createdAt = Date()
        self.imageData = imageData
        self.overallScore = result.overallScore
        self.summary = result.summary
        self.advice = result.advice
        
        // 将 dimensions 和 flags 转换为 JSON 字符串
        self.dimensionsJSON = Self.encodeToJSON(result.dimensions) ?? "[]"
        self.flagsJSON = Self.encodeToJSON(result.flags) ?? "[]"
    }
    
    // 转换回 AnalysisResult
    func toAnalysisResult() -> AnalysisResult {
        let dimensions = Self.decodeFromJSON([DimensionScore].self, from: dimensionsJSON) ?? []
        let flags = Self.decodeFromJSON([RiskFlag].self, from: flagsJSON) ?? []
        
        return AnalysisResult(
            overallScore: overallScore,
            summary: summary,
            dimensions: dimensions,
            flags: flags,
            advice: advice
        )
    }
    
    // 辅助方法：编码为 JSON
    private static func encodeToJSON<T: Encodable>(_ object: T) -> String? {
        guard let data = try? JSONEncoder().encode(object),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    // 辅助方法：从 JSON 解码
    private static func decodeFromJSON<T: Decodable>(_ type: T.Type, from string: String) -> T? {
        guard let data = string.data(using: .utf8),
              let object = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        return object
    }
}

// 为了支持 JSON 编码，需要让 DimensionScore 和 RiskFlag 遵循 Codable
extension DimensionScore: Codable {
    enum CodingKeys: String, CodingKey {
        case name, score, comment
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.score = try container.decode(Double.self, forKey: .score)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(score, forKey: .score)
        try container.encode(comment, forKey: .comment)
    }
}

extension RiskFlag: Codable {
    enum CodingKeys: String, CodingKey {
        case type, description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(FlagType.self, forKey: .type)
        self.description = try container.decode(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(description, forKey: .description)
    }
}

// MARK: - 历史记录管理器

@MainActor
class HistoryManager: ObservableObject {
    @Published var histories: [AnalysisHistory] = []
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadHistories()
    }
    
    /// 加载所有历史记录
    func loadHistories() {
        let descriptor = FetchDescriptor<AnalysisHistory>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            histories = try modelContext.fetch(descriptor)
        } catch {
            print("❌ 加载历史记录失败: \(error)")
        }
    }
    
    /// 保存新的分析记录
    func saveHistory(_ result: AnalysisResult, imageData: Data?) {
        let history = AnalysisHistory(result: result, imageData: imageData)
        modelContext.insert(history)
        
        do {
            try modelContext.save()
            loadHistories()
            print("✅ 保存历史记录成功")
        } catch {
            print("❌ 保存历史记录失败: \(error)")
        }
    }
    
    /// 删除历史记录
    func deleteHistory(_ history: AnalysisHistory) {
        modelContext.delete(history)
        
        do {
            try modelContext.save()
            loadHistories()
            print("✅ 删除历史记录成功")
        } catch {
            print("❌ 删除历史记录失败: \(error)")
        }
    }
    
    /// 清空所有历史记录
    func clearAllHistories() {
        for history in histories {
            modelContext.delete(history)
        }
        
        do {
            try modelContext.save()
            loadHistories()
            print("✅ 清空历史记录成功")
        } catch {
            print("❌ 清空历史记录失败: \(error)")
        }
    }
}

