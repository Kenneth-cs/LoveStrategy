import Foundation
import UIKit

// MARK: - Data Models

struct AnalysisResult: Identifiable, Codable {
    let id = UUID()
    let overallScore: Int
    let summary: String
    let dimensions: [DimensionScore]
    let flags: [RiskFlag]
    let advice: String
    
    enum CodingKeys: String, CodingKey {
        case overallScore, summary, dimensions, flags, advice
    }
}

struct DimensionScore: Identifiable, Codable {
    let id = UUID()
    let name: String
    let score: Double
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case name, score, comment
    }
}

struct RiskFlag: Identifiable, Codable {
    let id = UUID()
    let type: FlagType
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case type, description
    }
}

enum FlagType: String, Codable {
    case red
    case yellow
    case green
    
    var color: UIColor {
        switch self {
        case .red: return .systemRed
        case .yellow: return .systemOrange
        case .green: return .systemGreen
        }
    }
}

struct HexagramResult: Identifiable {
    let id = UUID()
    let hexagram: String
    let hexagramText: String
    let interpretation: String
    let advice: String
}

struct ReplyOptions {
    let coldStyle: [String]
    let sweetStyle: [String]
    let dramaStyle: [String]
}

// MARK: - Analysis Service

class AnalysisService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var result: AnalysisResult?
    
    private let volcengineService = VolcengineService()
    
    func analyzeScreenshots(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        self.isAnalyzing = true
        self.result = nil
        
        // 使用真实的火山引擎 API
        volcengineService.analyzeImages(images) { [weak self] result in
            DispatchQueue.main.async {
                self?.result = result
                self?.isAnalyzing = false
            }
        }
    }
}

// MARK: - Volcengine Service

class VolcengineService {
    // ⚠️ 请替换为你的火山引擎 API 配置
    private let apiKey = "YOUR_VOLCENGINE_API_KEY"
    private let endpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions"
    private let modelID = "YOUR_ENDPOINT_ID" // 例如: ep-20241201-xxxxx
    
    // 是否使用 Mock 数据（开发测试用）
    private let useMockData = true
    
    func analyzeImages(_ images: [UIImage], completion: @escaping (AnalysisResult?) -> Void) {
        // 如果使用 Mock 数据，直接返回模拟结果
        if useMockData {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                completion(self.getMockResult())
            }
            return
        }
        
        // 真实 API 调用逻辑
        guard let firstImage = images.first,
              let base64Image = firstImage.jpegData(compressionQuality: 0.6)?.base64EncodedString() else {
            completion(nil)
            return
        }
        
        let prompt = self.getAnalysisPrompt()
        let requestBody = self.createRequestBody(base64Image: base64Image, prompt: prompt)
        
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("JSON Encode Error: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network Error: \(error?.localizedDescription ?? "Unknown")")
                completion(nil)
                return
            }
            
            // 解析响应
            if let result = self.parseResponse(data) {
                completion(result)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func getAnalysisPrompt() -> String {
        return """
        你是一位拥有 10 年经验的情感心理咨询师和"鉴渣"专家，精通依恋理论、PUA 识别。
        你的风格是：毒舌但在理，犀利但不刻薄，像一个懂你的闺蜜。
        
        请分析这张聊天记录截图，从心理学角度评估对方的真实意图和情感投入度。
        
        **分析维度 (0-100 分)**:
        1. 回复速度 (秒回=90+, 几小时才回=30-, 忽冷忽热=40-60)
        2. 关心度 (主动问候/记住细节=80+, 敷衍回复=30-)
        3. 承诺兑现率 (说到做到=90+, 频繁"下次""改天"=20-)
        4. 情绪稳定性 (温和体贴=90+, 有PUA/打压倾向=20-)
        5. 暧昧指数 (专一真诚=90+, 油腻话术/撒网式=20-)
        6. 真诚度 (语言真实=90+, 套路话术=30-)
        7. 时间投入度 (愿意长时间陪伴=90+, 敷衍了事=30-)
        
        **渣男关键词库**:
        - 免责声明: "我不想耽误你"、"我配不上你"、"我现在不想谈恋爱"
        - 推拉话术: "你真的很特别，但是..."
        - 打压 PUA: "你想太多了"、"你怎么这么敏感"
        - 画饼类: "等我忙完这阵子"、"下次一定"
        
        **输出格式 (严格 JSON)**:
        {
          "overallScore": 45,
          "summary": "典型的'回避型依恋'表现...",
          "dimensions": [
            {"name": "回复速度", "score": 80, "comment": "回复及时，但深夜才活跃"},
            {"name": "关心度", "score": 30, "comment": "从不主动问候"},
            {"name": "承诺兑现率", "score": 20, "comment": "频繁画饼"},
            {"name": "情绪稳定性", "score": 60, "comment": "偶尔情绪化"},
            {"name": "暧昧指数", "score": 40, "comment": "话术油腻"},
            {"name": "真诚度", "score": 40, "comment": "套路较多"},
            {"name": "时间投入度", "score": 50, "comment": "时间投入一般"}
          ],
          "flags": [
            {"type": "red", "description": "检测到 PUA 话术：'你能不能别想太多'"},
            {"type": "yellow", "description": "频繁深夜聊天，白天消失"}
          ],
          "advice": "建议：停止自我暴露，不要再主动提供情绪价值。"
        }
        
        请只输出 JSON，不要有其他文字。
        """
    }
    
    private func createRequestBody(base64Image: String, prompt: String) -> [String: Any] {
        return [
            "model": modelID,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ]
        ]
    }
    
    private func parseResponse(_ data: Data) -> AnalysisResult? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                // 解析 JSON 字符串为 AnalysisResult
                if let contentData = content.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    return try decoder.decode(AnalysisResult.self, from: contentData)
                }
            }
        } catch {
            print("Parse Error: \(error)")
        }
        return nil
    }
    
    // Mock 数据（用于开发测试）
    private func getMockResult() -> AnalysisResult {
        return AnalysisResult(
            overallScore: 45,
            summary: "典型的'回避型依恋'表现。他在对话中频繁使用模糊性语言，虽然回复速度尚可，但在关键承诺上一直在'画饼'。注意他对你情绪的忽视，这是一个危险信号。",
            dimensions: [
                DimensionScore(name: "回复速度", score: 80, comment: "回复及时，但深夜才活跃"),
                DimensionScore(name: "关心度", score: 30, comment: "从不主动问候，对你的事漠不关心"),
                DimensionScore(name: "承诺兑现率", score: 20, comment: "频繁说'下次'、'改天'，从不兑现"),
                DimensionScore(name: "情绪稳定性", score: 60, comment: "偶尔情绪化，有轻微打压倾向"),
                DimensionScore(name: "暧昧指数", score: 40, comment: "话术油腻，疑似撒网式聊天"),
                DimensionScore(name: "真诚度", score: 40, comment: "套路话术较多，缺乏真诚"),
                DimensionScore(name: "时间投入度", score: 50, comment: "时间投入一般，不够用心")
            ],
            flags: [
                RiskFlag(type: .red, description: "检测到 PUA 话术：'你能不能别想太多'，这是典型的 Gaslighting（煤气灯效应）"),
                RiskFlag(type: .yellow, description: "频繁深夜聊天，但白天消失，存在鱼塘管理嫌疑"),
                RiskFlag(type: .yellow, description: "多次使用'等我忙完'等画饼词汇，承诺从不兑现")
            ],
            advice: "建议：立刻停止自我暴露，不要再主动提供情绪价值。下次他再这样说，直接回复'哦，那确实挺遗憾的'，然后断联三天观察反应。如果他不主动找你，说明你在他心中的位置并不重要。"
        )
    }
}

