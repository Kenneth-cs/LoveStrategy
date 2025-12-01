# 恋爱军师 - 下一步开发节奏规划

## 📍 当前进度
- ✅ 项目基础架构搭建完成
- ✅ 火山引擎 API 对接完成
- ✅ 核心 UI 界面完成（鉴渣雷达 + 截图起卦）
- ✅ 图片上传功能完成
- ⏳ API 响应解析（待优化）
- ⏳ 本地数据存储（待开发）
- ⏳ 支付系统（待开发）

---

## 🎯 Week 1-2: 核心功能优化与完善

### Day 1-3: API 响应解析优化 ⭐⭐⭐ (最优先)
**目标**: 让 AI 返回结构化的 JSON，而不是纯文本

#### 任务清单
- [ ] **优化 Prompt**，要求 AI 严格按照 JSON 格式返回
- [ ] **完善解析逻辑**，从 AI 返回的文本中提取 JSON
- [ ] **错误处理**，如果解析失败，显示友好的错误提示
- [ ] **测试 20+ 真实聊天截图**，确保分析准确

#### 具体实现
```swift
// 在 VolcengineService.swift 中优化 Prompt
private func getAnalysisPrompt() -> String {
    return """
    你是一位拥有 10 年经验的情感心理咨询师...
    
    请严格按照以下 JSON 格式返回分析结果（不要添加任何其他文字）：
    
    {
      "overall_score": 45,
      "summary": "你的分析...",
      "dimensions": [
        {"name": "回复速度", "score": 80, "comment": "..."},
        ...
      ],
      "flags": [
        {"type": "red", "description": "..."}
      ],
      "advice": "你的建议..."
    }
    """
}
```

---

### Day 4-5: UI 细节优化
**目标**: 让界面更精美，用户体验更流畅

#### 任务清单
- [ ] **添加加载动画**（上传图片时的进度提示）
- [ ] **优化雷达图**（使用真正的雷达图，而不是条形图）
- [ ] **添加分享功能**（生成精美的分析结果卡片）
- [ ] **适配不同屏幕尺寸**（iPhone SE 到 iPhone 15 Pro Max）
- [ ] **添加夜间模式支持**

#### 重点：真正的雷达图
使用 SwiftUI Charts 绘制六边形雷达图：
```swift
import Charts

struct RadarChartView: View {
    let dimensions: [DimensionScore]
    
    var body: some View {
        // 使用 Chart + AreaMark 绘制雷达图
    }
}
```

---

### Day 6-7: 本地历史记录功能
**目标**: 用户可以查看历史分析记录

#### 任务清单
- [ ] **使用 SwiftData 创建数据模型**
- [ ] **实现历史记录列表**
- [ ] **支持查看历史报告**
- [ ] **支持删除记录**
- [ ] **添加搜索功能**

#### 数据模型
```swift
import SwiftData

@Model
class AnalysisHistory {
    var id: UUID
    var createdAt: Date
    var imageData: Data?
    var result: AnalysisResult
    
    init(result: AnalysisResult, imageData: Data?) {
        self.id = UUID()
        self.createdAt = Date()
        self.result = result
        self.imageData = imageData
    }
}
```

---

## 🎯 Week 3-4: 增值功能与玄学模块

### Day 8-10: 高情商回复助手 ⭐⭐
**目标**: 开发"拿捏工具"，生成三种风格的回复

#### 任务清单
- [ ] **创建 ReplyAssistantView**
- [ ] **用户输入对方的一句话**
- [ ] **AI 生成三种风格回复**：
  - 高冷御姐风
  - 绿茶撒娇风
  - Drama发疯风
- [ ] **一键复制功能**
- [ ] **场景模拟器**（用户与 AI 模拟对话）

---

### Day 11-13: 玄学模块扩展
**目标**: 增加更多玄学功能，提高用户留存

#### 任务清单
- [ ] **AI 塔罗牌抽取**（精美的翻牌动画）
- [ ] **MBTI 人格分析**（基于聊天记录推测对方 MBTI）
- [ ] **星座合盘**（输入双方生日，分析适配度）

---

### Day 14: 测试与优化
- [ ] 完整功能测试
- [ ] 修复已知 Bug
- [ ] 优化性能（减少内存占用）

---

## 🎯 Week 5-6: 商业化与支付

### Day 15-17: Apple IAP 集成 ⭐⭐⭐
**目标**: 接入苹果内购，实现变现

#### 任务清单
- [ ] **在 App Store Connect 创建内购项目**：
  - 消耗型：单次深度报告 (¥9.9)
  - 消耗型：AI 塔罗牌 (¥6.6)
  - 订阅型：周会员 (¥9.9/周)
  - 订阅型：月会员 (¥29.9/月)
- [ ] **集成 StoreKit 2**
- [ ] **实现购买流程**
- [ ] **设计 Paywall（付费墙）**
- [ ] **实现订阅状态管理**
- [ ] **添加恢复购买功能**

#### 核心代码
```swift
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: [
                "com.lovestrategy.weekly",
                "com.lovestrategy.monthly"
            ])
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        // 处理购买结果
    }
}
```

---

### Day 18-20: Freemium 模式实现
**目标**: 设计免费额度，引导用户付费

#### 任务清单
- [ ] **实现每日免费额度**（3次分析）
- [ ] **新用户福利**（注册送 1 次完整分析）
- [ ] **付费墙设计**（在查看详细报告前弹出）
- [ ] **会员权益展示**
- [ ] **限时优惠倒计时**

#### 免费额度管理
```swift
class QuotaManager: ObservableObject {
    @Published var dailyQuota = 3
    @Published var usedToday = 0
    
    var canAnalyze: Bool {
        return usedToday < dailyQuota || isPremiumUser
    }
    
    func useQuota() {
        usedToday += 1
        UserDefaults.standard.set(usedToday, forKey: "usedToday")
    }
}
```

---

### Day 21: PDF 报告生成
**目标**: 生成精美的 PDF 报告供用户下载

#### 任务清单
- [ ] **使用 PDFKit 生成 PDF**
- [ ] **设计 PDF 模板**（包含雷达图、分析结果）
- [ ] **添加分享功能**（保存到相册/分享到微信）

---

## 🎯 Week 7-8: 合规与上线

### Day 22-24: 合规准备 ⭐⭐⭐
**目标**: 确保能通过 App Store 审核

#### 任务清单
- [ ] **编写用户协议**
- [ ] **编写隐私政策**
- [ ] **实现图片打码功能**（自动高斯模糊头像）
- [ ] **添加内容审核**（敏感词过滤）
- [ ] **添加免责声明**（每个分析结果底部）
- [ ] **准备审核说明文档**

#### 话术包装（重要！）
- ❌ 不要用："算命"、"渣男"、"鉴渣"
- ✅ 改用："心理投射测试"、"依恋人格分析"、"情感质检"

---

### Day 25-27: App Store 素材制作
**目标**: 制作高质量的上架素材

#### 任务清单
- [ ] **设计 App Icon**（1024x1024）
- [ ] **制作 5 张预览图**（使用 Drama 文案）
- [ ] **录制演示视频**（30秒）
- [ ] **撰写 App 描述文案**
- [ ] **关键词优化（ASO）**

#### 预览图文案建议
1. "他说'我现在不想谈恋爱'是什么意思？"
2. "AI 帮你识破情感套路"
3. 雷达图展示 + "你的恋爱军师已上线"
4. "截图起卦，看这段关系有没有结果"
5. 用户好评截图墙

---

### Day 28-30: TestFlight 内测
**目标**: 邀请种子用户测试

#### 任务清单
- [ ] **上传到 TestFlight**
- [ ] **邀请 20-50 位种子用户**
- [ ] **收集用户反馈**
- [ ] **修复 Bug**
- [ ] **优化用户体验**

---

### Day 31-35: 正式提审与上线
**目标**: 提交 App Store 审核

#### 任务清单
- [ ] **最终测试**（确保无崩溃）
- [ ] **提交审核**
- [ ] **准备审核问答**（如被拒绝，快速响应）
- [ ] **同步准备小红书引流内容**

---

## 🎯 Post-Launch: 运营与迭代

### Week 9+: 冷启动与增长
- [ ] **小红书发布首篇笔记**（带 #情感分析 #恋爱话术）
- [ ] **建立微信私域群**
- [ ] **联系 KOL 合作**（情感类博主）
- [ ] **监控数据**（下载量、付费转化率、留存率）
- [ ] **A/B 测试**（不同 Paywall 文案）

### 持续优化
- [ ] **收集"渣男语录"语料库**
- [ ] **模型微调**（Fine-tuning）
- [ ] **开发社区板块**（渣男档案馆）
- [ ] **真人咨询引流**（高客单价后端变现）

---

## 📊 关键里程碑

| 时间 | 里程碑 | 成功标准 |
|------|--------|---------|
| Week 2 | 核心功能完善 | API 稳定，分析准确率 >80% |
| Week 4 | 增值功能上线 | 完成 3 大核心功能模块 |
| Week 6 | 支付系统上线 | 内购测试通过 |
| Week 8 | 正式上线 | 通过 App Store 审核 |
| Week 10 | 初步验证 | 1000+ 下载，付费转化率 >5% |

---

## 🎯 本周重点任务（Week 1）

### 立刻开始的 3 件事：

1. **优化 API 响应解析** ⭐⭐⭐
   - 修改 Prompt，要求 AI 返回 JSON
   - 完善解析逻辑
   - 测试 10+ 真实截图

2. **实现真正的雷达图** ⭐⭐
   - 使用 SwiftUI Charts
   - 绘制六边形雷达图
   - 添加动画效果

3. **添加本地历史记录** ⭐⭐
   - 使用 SwiftData
   - 实现历史列表
   - 支持查看和删除

---

## 💡 建议的开发顺序

### 优先级排序
1. **P0（必须做）**: API 解析优化、历史记录、支付系统
2. **P1（应该做）**: 雷达图优化、高情商回复助手、合规准备
3. **P2（可以做）**: 玄学扩展、PDF 报告、社区功能

### 时间分配建议
- **60% 时间**：核心功能优化（确保稳定性和准确性）
- **30% 时间**：商业化功能（支付、Paywall）
- **10% 时间**：增值功能（玄学、社区）

---

## 🚀 行动建议

**今天就开始：**
1. 优化 `getAnalysisPrompt()`，让 AI 返回 JSON
2. 测试 5 张真实聊天截图，看看 AI 的分析质量
3. 如果分析质量好，立刻开始开发历史记录功能

**本周目标：**
- ✅ API 解析稳定
- ✅ 历史记录功能上线
- ✅ 雷达图优化完成

---

需要我帮你立刻开始优化 API 解析逻辑吗？这是当前最重要的任务！🎯

