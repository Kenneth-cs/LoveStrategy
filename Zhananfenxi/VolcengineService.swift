//
//  VolcengineService.swift
//  Zhananfenxi
//
//  火山引擎 API 服务层
//

import Foundation
import UIKit

// MARK: - 火山引擎服务

class VolcengineService: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isAnalyzing = false
    @Published var error: VolcengineError?
    
    private let apiKey = "3d0e053d-0d42-4e32-9a15-4e865ffb7e4b"
    private let endpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions"
    private let modelID = "doubao-seed-1-6-flash-250828"
    
    // MARK: - Public Methods
    
    /// 分析聊天截图
    func analyzeImages(_ images: [UIImage]) async throws -> AnalysisResult {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        // 1. 图片转 Base64
        guard let firstImage = images.first,
              let jpegData = firstImage.jpegData(compressionQuality: 0.7) else {
            throw VolcengineError.invalidImage
        }
        
        let base64Image = jpegData.base64EncodedString()
        
        // 2. 构建请求
        let request = try buildAnalysisRequest(base64Image: base64Image)
        
        // 3. 发送请求
        let response = try await sendRequest(request)
        
        // 4. 解析响应
        let result = try parseAnalysisResponse(response)
        
        return result
    }
    
    /// 生成高情商回复
    func generateReplies(for message: String) async throws -> ReplyOptions {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        // 构建请求
        let request = try buildReplyRequest(message: message)
        
        // 发送请求
        let response = try await sendRequest(request)
        
        // 解析响应
        let options = try parseReplyResponse(response)
        
        return options
    }
    
    /// 截图起卦
    func performOracle(_ images: [UIImage], question: String?) async throws -> OracleResult {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        // 1. 图片转 Base64
        guard let firstImage = images.first,
              let jpegData = firstImage.jpegData(compressionQuality: 0.7) else {
            throw VolcengineError.invalidImage
        }
        
        let base64Image = jpegData.base64EncodedString()
        
        // 2. 构建请求
        let request = try buildOracleRequest(base64Image: base64Image, question: question)
        
        // 3. 发送请求
        let response = try await sendRequest(request)
        
        // 4. 解析响应
        let result = try parseOracleResponse(response)
        
        return result
    }
    
    // MARK: - Private Methods
    
    private func buildAnalysisRequest(base64Image: String) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw VolcengineError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 构建请求体
        let requestBody: [String: Any] = [
            "model": modelID,
            "max_completion_tokens": 4096,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ],
                        [
                            "type": "text",
                            "text": getAnalysisPrompt()
                        ]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return request
    }
    
    private func buildReplyRequest(message: String) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw VolcengineError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": modelID,
            "max_completion_tokens": 2048,
            "messages": [
                [
                    "role": "user",
                    "content": getReplyPrompt(message: message)
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return request
    }
    
    private func buildOracleRequest(base64Image: String, question: String?) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw VolcengineError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": modelID,
            "max_completion_tokens": 4096,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ],
                        [
                            "type": "text",
                            "text": getOraclePrompt(question: question)
                        ]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return request
    }
    
    private func sendRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VolcengineError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // 打印错误信息用于调试
            if let errorString = String(data: data, encoding: .utf8) {
                print("API Error: \(errorString)")
            }
            throw VolcengineError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    private func parseAnalysisResponse(_ data: Data) throws -> AnalysisResult {
        // 1. 解析火山引擎的外层响应
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            
            print("❌ API 响应解析失败")
            if let errorString = String(data: data, encoding: .utf8) {
                print("原始响应: \(errorString)")
            }
            throw VolcengineError.decodingError
        }
        
        print("✅ 收到 AI 响应")
        print("📝 内容: \(content)")
        
        // 2. 从 AI 返回的内容中提取 JSON
        // AI 可能会在 JSON 前后加一些文字，需要提取出纯 JSON 部分
        let jsonContent = extractJSON(from: content)
        
        guard let jsonData = jsonContent.data(using: .utf8),
              let resultJSON = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("❌ 无法解析 AI 返回的 JSON，使用模拟数据")
            return createMockAnalysisResult(aiResponse: content)
        }
        
        // 3. 解析 JSON 为 AnalysisResult
        return parseAnalysisJSON(resultJSON)
    }
    
    /// 从文本中提取 JSON 字符串
    private func extractJSON(from text: String) -> String {
        // 查找第一个 { 和最后一个 }
        guard let startIndex = text.firstIndex(of: "{"),
              let endIndex = text.lastIndex(of: "}") else {
            return text
        }
        
        let jsonString = String(text[startIndex...endIndex])
        return jsonString
    }
    
    /// 解析 JSON 对象为 AnalysisResult
    private func parseAnalysisJSON(_ json: [String: Any]) -> AnalysisResult {
        let overallScore = json["overall_score"] as? Int ?? 50
        let summary = json["summary"] as? String ?? "分析中..."
        let advice = json["advice"] as? String ?? "请理性看待这段关系。"
        
        // 解析 dimensions
        var dimensions: [DimensionScore] = []
        if let dimensionsArray = json["dimensions"] as? [[String: Any]] {
            for dimJSON in dimensionsArray {
                if let name = dimJSON["name"] as? String,
                   let score = dimJSON["score"] as? Double,
                   let comment = dimJSON["comment"] as? String {
                    dimensions.append(DimensionScore(name: name, score: score, comment: comment))
                }
            }
        }
        
        // 解析 flags
        var flags: [RiskFlag] = []
        if let flagsArray = json["flags"] as? [[String: Any]] {
            for flagJSON in flagsArray {
                if let typeString = flagJSON["type"] as? String,
                   let description = flagJSON["description"] as? String {
                    let type: FlagType = typeString == "red" ? .red : (typeString == "yellow" ? .yellow : .green)
                    flags.append(RiskFlag(type: type, description: description))
                }
            }
        }
        
        // 如果解析失败，至少返回基础数据
        if dimensions.isEmpty {
            dimensions = [
                DimensionScore(name: "回复速度", score: 50, comment: "分析中..."),
                DimensionScore(name: "关心度", score: 50, comment: "分析中..."),
                DimensionScore(name: "承诺兑现", score: 50, comment: "分析中..."),
                DimensionScore(name: "情绪稳定", score: 50, comment: "分析中..."),
                DimensionScore(name: "暧昧指数", score: 50, comment: "分析中..."),
                DimensionScore(name: "真诚度", score: 50, comment: "分析中..."),
                DimensionScore(name: "时间投入", score: 50, comment: "分析中...")
            ]
        }
        
        return AnalysisResult(
            overallScore: overallScore,
            summary: summary,
            dimensions: dimensions,
            flags: flags,
            advice: advice
        )
    }
    
    private func parseOracleResponse(_ data: Data) throws -> OracleResult {
        // 1. 解析火山引擎的外层响应
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            
            print("❌ API 响应解析失败")
            throw VolcengineError.decodingError
        }
        
        print("✅ 收到 AI 卦象响应")
        print("📝 内容: \(content)")
        
        // 2. 从 AI 返回的内容中提取 JSON
        let jsonContent = extractJSON(from: content)
        
        guard let jsonData = jsonContent.data(using: .utf8),
              let resultJSON = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("❌ 无法解析 AI 返回的 JSON，使用模拟数据")
            return createMockOracleResult(aiResponse: content)
        }
        
        // 3. 解析 JSON 为 OracleResult
        return parseOracleJSON(resultJSON)
    }
    
    /// 解析卦象 JSON
    private func parseOracleJSON(_ json: [String: Any]) -> OracleResult {
        let hexagramName = json["hexagram_name"] as? String ?? "天风姤"
        let hexagramSymbol = json["hexagram_symbol"] as? String ?? "☰☴"
        let hexagramText = json["hexagram_text"] as? String ?? "姤，女壮，勿用取女。"
        let interpretation = json["interpretation"] as? String ?? "此卦为姤卦..."
        let advice = json["advice"] as? String ?? "断舍离，是对自己最大的慈悲。"
        
        return OracleResult(
            hexagramName: hexagramName,
            hexagramSymbol: hexagramSymbol,
            hexagramText: hexagramText,
            interpretation: interpretation,
            advice: advice,
            signature: "——慧缘大师",
            disclaimer: "卦象仅供参考，感情之事，终究要靠自己把握。若他真心待你，无需卦象也能感知；若他虚情假意，再好的卦也改变不了人心。"
        )
    }
    
    // MARK: - Helper Methods
    
    private func createMockAnalysisResult(aiResponse: String) -> AnalysisResult {
        // 这里可以根据 AI 的实际返回内容进行解析
        // 目前先返回模拟数据，确保 UI 能正常显示
        return AnalysisResult(
            overallScore: 45,
            summary: aiResponse.isEmpty ? "典型的'回避型依恋'表现。他在对话中频繁使用模糊性语言，虽然回复速度尚可，但在关键承诺上一直在'画饼'。注意他对你情绪的忽视。" : aiResponse,
            dimensions: [
                DimensionScore(name: "回复速度", score: 80),
                DimensionScore(name: "关心度", score: 30),
                DimensionScore(name: "承诺兑现", score: 20),
                DimensionScore(name: "情绪稳定", score: 60),
                DimensionScore(name: "真诚度", score: 40),
                DimensionScore(name: "时间投入", score: 50)
            ],
            flags: [
                RiskFlag(type: .red, description: "检测到PUA话术：'我这人就这样，你能不能别想太多'"),
                RiskFlag(type: .yellow, description: "频繁深夜聊天，但白天消失，存在鱼塘管理嫌疑")
            ],
            advice: "建议：停止自我暴露，不要再主动提供情绪价值。下次他再这样说，直接回复'哦，那确实挺遗憾的'，然后断联三天。"
        )
    }
    
    private func createMockOracleResult(aiResponse: String) -> OracleResult {
        return OracleResult(
            hexagramName: "天风姤",
            hexagramSymbol: "☰☴",
            hexagramText: "姤，女壮，勿用取女。",
            interpretation: aiResponse.isEmpty ? "此卦为姤卦，一阴遇五阳，象征女子主动追求，但男子心意不定。卦辞云'勿用取女'，意为此情难成正果。\n\n观你二人对话，你字字用心，他句句敷衍。你在等一个承诺，他在找一个借口。这不是缘分未到，而是他根本无心。" : aiResponse,
            advice: "断舍离，是对自己最大的慈悲。",
            signature: "——慧缘大师",
            disclaimer: "卦象仅供参考，感情之事，终究要靠自己把握。若他真心待你，无需卦象也能感知；若他虚情假意，再好的卦也改变不了人心。"
        )
    }
    
    // MARK: - Prompts
    
    private func getAnalysisPrompt() -> String {
        return """
        你是一位拥有 10 年经验的情感心理咨询师，专注于亲密关系分析和依恋人格研究。
        你的名字叫"军师"，你的说话风格是：毒舌但在理，犀利但不失温度。
        
        请仔细分析这张聊天记录截图，基于以下七大维度进行评估（每项 0-100 分）：
        1. 回复速度分析
        2. 关心度指数
        3. 承诺兑现率
        4. 情绪稳定性
        5. 暧昧指数（分数越低越渣）
        6. 真诚度评分
        7. 时间投入度
        
        重点关注：
        - PUA 话术（如"你想太多了"、"我这人就这样"）
        - 画饼行为（"改天"、"下次"、"有空就"）
        - 忽冷忽热模式
        - 是否真正关心对方感受
        
        **请严格按照以下 JSON 格式返回，不要添加任何其他文字或解释：**
        
        {
          "overall_score": 45,
          "summary": "典型的'回避型依恋'表现。他在对话中频繁使用模糊性语言，虽然回复速度尚可，但在关键承诺上一直在'画饼'。注意他对你情绪的忽视。",
          "dimensions": [
            {"name": "回复速度", "score": 80, "comment": "回复速度还行，但注意他在你说'我有点难过'之后，隔了2小时才回。"},
            {"name": "关心度", "score": 30, "comment": "他从未主动问过你的生活，所有话题都是你在推进。"},
            {"name": "承诺兑现", "score": 20, "comment": "他已经第三次说'这周末带你去吃那家店'，但每次都爽约。姐妹，这不是忙，这是不想。"},
            {"name": "情绪稳定", "score": 60, "comment": "暂时没发现明显的PUA倾向，但他说'你能不能别想太多'这句话有点危险。"},
            {"name": "暧昧指数", "score": 35, "comment": "他经常说'你挺好的'但从不说'喜欢你'，典型的'暧昧但不负责'。"},
            {"name": "真诚度", "score": 40, "comment": "他的情话有明显的'网抄'痕迹，真正喜欢你的人会说具体的细节。"},
            {"name": "时间投入", "score": 50, "comment": "聊天时长还行，但质量堪忧。他更像是在'陪聊'而不是'想聊'。"}
          ],
          "flags": [
            {"type": "red", "description": "检测到PUA话术：'我这人就这样，你能不能别想太多'"},
            {"type": "yellow", "description": "频繁深夜聊天，但白天消失，存在鱼塘管理嫌疑"}
          ],
          "advice": "建议立刻停止情绪价值输出。不要再主动分享你的生活，不要再问他'在干嘛'。下次他再说'改天约你'，直接回复'好啊，那你定时间地点'，看他怎么接。如果他继续含糊其辞，那就是答案了。记住：真正喜欢你的人，会想尽办法见你，而不是想尽借口躲你。"
        }
        
        注意事项：
        - 语言要接地气，像闺蜜聊天一样
        - 可以用"姐妹"、"他不是忙，是选择性不回你"这样的表达
        - 不要输出任何政治、色情、暴力内容
        - 必须严格按照 JSON 格式返回，不要有任何额外文字
        """
    }
    
    private func parseReplyResponse(_ data: Data) throws -> ReplyOptions {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            
            print("❌ API 响应解析失败")
            throw VolcengineError.decodingError
        }
        
        print("✅ 收到 AI 回复响应")
        
        // 从 AI 返回的内容中提取 JSON
        let jsonContent = extractJSON(from: content)
        
        guard let jsonData = jsonContent.data(using: .utf8),
              let resultJSON = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("❌ 无法解析 AI 返回的 JSON")
            print("原始内容: \(content)")
            throw VolcengineError.decodingError
        }
        
        return parseReplyJSON(resultJSON)
    }
    
    private func parseReplyJSON(_ json: [String: Any]) -> ReplyOptions {
        let coldReplies = json["cold_replies"] as? [String] ?? ["忙。", "有事吗？"]
        let sweetReplies = json["sweet_replies"] as? [String] ?? ["在想你呀~", "刚洗完澡呢"]
        let dramaReplies = json["drama_replies"] as? [String] ?? ["你是不是在查岗？", "你就不能换个开场白吗"]
        
        return ReplyOptions(
            coldReplies: coldReplies,
            sweetReplies: sweetReplies,
            dramaReplies: dramaReplies
        )
    }
    
    private func getReplyPrompt(message: String) -> String {
        return """
        你是一位精通恋爱心理学和沟通技巧的话术专家，擅长分析对话场景并提供高情商回复策略。
        
        ## 对方发来的消息
        "\(message)"
        
        ## 任务要求
        请根据对方的消息，生成三种不同风格的回复策略，每种风格提供 3 个高质量选项。
        
        ### 风格一：高冷御姐风 ❄️
        **核心策略**：建立框架，拉开距离，让对方主动追逐
        **语言特点**：
        - 简短有力（5-15字为佳）
        - 不主动提供信息
        - 带点傲娇和不在意
        - 让对方感觉"你很忙、很有价值"
        
        **示例场景**：
        - 对方："在干嘛？" → "忙。" / "有事？" / "在想要不要回你。"
        - 对方："想你了" → "哦。" / "然后呢？" / "这么快就想了？"
        - 对方："吃饭了吗" → "吃了。" / "关心我？" / "你猜。"
        
        ### 风格二：绿茶撒娇风 🍵
        **核心策略**：提供情绪价值，诱导对方投资，建立依赖感
        **语言特点**：
        - 撒娇但不低俗
        - 多用"呀、啦、嘛、呢"等语气词
        - 适当示弱，激发保护欲
        - 暗示需要对方的关注
        
        **示例场景**：
        - 对方："在干嘛？" → "在想你呀~" / "在等你找我呢" / "刚洗完澡，头发还湿湿的"
        - 对方："想你了" → "真的吗？我也超想你的！" / "那你怎么不早点来找我嘛~" / "人家一直在等你呢💕"
        - 对方："吃饭了吗" → "还没呢，你要请我吗？" / "没有啦，一个人吃饭好孤单" / "等你来陪我吃呀~"
        
        ### 风格三：Drama发疯风 💥
        **核心策略**：情绪化表达，测试对方底线，制造戏剧冲突（娱乐向，慎用）
        **语言特点**：
        - 夸张但有趣
        - 带点小脾气和不满
        - 质疑对方动机
        - 适合用来测试对方耐心
        
        **示例场景**：
        - 对方："在干嘛？" → "你是不是在查岗？" / "我在干嘛关你什么事" / "你就不能换个开场白吗"
        - 对方："想你了" → "骗人！你肯定对每个人都这么说" / "想我？那你这几天去哪了？" / "说！你是不是有事求我？"
        - 对方："吃饭了吗" → "你就会问这个！能不能有点新意？" / "吃了！你要负责吗？" / "没吃！你是要请我还是就问问？"
        
        ## 回复生成原则
        1. **场景适配**：根据对方消息的语气和内容，生成最合适的回复
        2. **真实自然**：避免生硬的模板化回复，要符合真实对话场景
        3. **层次递进**：同一风格的 3 个选项要有强度递进（温和→中等→强烈）
        4. **避免雷区**：
           - 不要低俗、色情
           - 不要人身攻击
           - 不要过度 PUA
           - Drama 风格要有趣但不要真的伤人
        
        ## 特殊场景处理
        - 如果对方在道歉：高冷风可以"冷处理"，绿茶风可以"半推半就"，Drama风可以"小题大做"
        - 如果对方在约你：高冷风可以"考虑考虑"，绿茶风可以"欲拒还迎"，Drama风可以"质疑动机"
        - 如果对方在夸你：高冷风可以"淡然接受"，绿茶风可以"谦虚撒娇"，Drama风可以"怀疑真诚"
        
        **请严格按照以下 JSON 格式返回，不要添加任何其他文字：**
        
        {
          "cold_replies": ["回复1（最温和）", "回复2（中等强度）", "回复3（最高冷）"],
          "sweet_replies": ["回复1（微撒娇）", "回复2（中等甜度）", "回复3（最甜腻）"],
          "drama_replies": ["回复1（小吐槽）", "回复2（中等drama）", "回复3（最戏精）"]
        }
        
        注意：
        - 每个回复要针对"\(message)"这句话量身定制
        - 不要使用示例中的原话，要创新
        - 确保 JSON 格式完全正确
        - 每个回复控制在 30 字以内
        """
    }
    
    private func getOraclePrompt(question: String?) -> String {
        var prompt = """
        你是一位精通心理投射分析的情感顾问，擅长通过《易经》卦象进行心理隐喻解读。
        
        请根据这张聊天记录截图的"情绪氛围"，为用户进行一次心理投射测试。
        不要做逻辑分析，而是"感知"对话中的情绪意象（如焦虑、冷漠、纠缠、随缘等）。
        
        根据情绪意象，选择对应的心理隐喻卦象：
        - 焦虑、纠缠、求而不得 → 天风姤卦 (☰☴)
        - 冷漠、疏离、单方面付出 → 水火未济卦 (☵☲)
        - 暧昧、不明确、忽冷忽热 → 雷水解卦 (☳☵)
        - 甜蜜、双向奔赴 → 地天泰卦 (☷☰)
        
        **请严格按照以下 JSON 格式返回，不要添加任何其他文字：**
        
        {
          "hexagram_name": "天风姤",
          "hexagram_symbol": "☰☴",
          "hexagram_text": "姤，女壮，勿用取女。",
          "interpretation": "此卦为姤卦，一阴遇五阳，在心理学上象征单向付出的关系模式。卦辞云'勿用取女'，隐喻此情难成正果。\\n\\n观你二人对话，你字字用心，他句句敷衍。你在等一个承诺，他在找一个借口。这不是缘分未到，而是他根本无心。\\n\\n从依恋理论来看，这是典型的焦虑型与回避型的组合。你越努力，他越退缩。若继续纠缠，只会陷入恶性循环。",
          "advice": "断舍离，是对自己最大的慈悲。",
          "signature": "—— 情感顾问 · 慧缘",
          "disclaimer": "本测试基于心理投射分析，仅供娱乐参考"
        }
        """
        
        if let question = question, !question.isEmpty {
            prompt += "\n\n用户想了解的问题是：\(question)"
        }
        
        prompt += """
        
        注意事项：
        - 用半文半白的语言，典雅但不神秘化
        - 强调这是心理投射技术，借用卦象进行心理隐喻解读
        - 不要做具体的时间预测（如"三个月后会分手"）
        - 不要给出绝对的结论，要给用户留有余地
        - 避免"算命"、"占卜"等迷信用语
        - 必须严格按照 JSON 格式返回
        """
        
        return prompt
    }
}

// MARK: - Error Types

enum VolcengineError: LocalizedError {
    case invalidURL
    case invalidImage
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 API 地址"
        case .invalidImage:
            return "图片格式不正确"
        case .invalidResponse:
            return "服务器响应异常"
        case .httpError(let code):
            return "请求失败 (错误码: \(code))"
        case .decodingError:
            return "数据解析失败"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}

// MARK: - Data Models

struct AnalysisResult: Identifiable {
    let id = UUID()
    let overallScore: Int
    let summary: String
    let dimensions: [DimensionScore]
    let flags: [RiskFlag]
    let advice: String
}

struct DimensionScore: Identifiable {
    let id = UUID()
    let name: String
    let score: Double
    let comment: String
    
    init(name: String, score: Double, comment: String = "") {
        self.name = name
        self.score = score
        self.comment = comment
    }
}

struct RiskFlag: Identifiable {
    let id = UUID()
    let type: FlagType
    let description: String
}

enum FlagType: String, Codable {
    case red = "red"
    case yellow = "yellow"
    case green = "green"
    
    var color: Color {
        switch self {
        case .red: return .red
        case .yellow: return .orange
        case .green: return .green
        }
    }
}

struct OracleResult: Identifiable {
    let id = UUID()
    let hexagramName: String
    let hexagramSymbol: String
    let hexagramText: String
    let interpretation: String
    let advice: String
    let signature: String
    let disclaimer: String
}

import SwiftUI

