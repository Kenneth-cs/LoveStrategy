# Phase 1: 桃花签付费功能开发计划

> **开发周期**: 2-3周  
> **目标版本**: v1.2.0  
> **核心功能**: 虚拟货币体系 + StoreKit 2 内购

---

## 📅 开发时间线

### Week 1: 基础货币体系 (Day 1-7)

#### Day 1-2: PeachBlossomManager 核心开发
- [x] 创建 `PeachBlossomManager.swift`
- [x] 实现 iCloud 同步
- [x] 初始化赠送66签
- [x] 扣费/充值/查询接口
- [x] 单元测试

#### Day 3-4: 功能集成（扣费逻辑）
- [ ] 修改 `VolcengineService.swift`
  - [ ] 在API调用前检查余额
  - [ ] API成功后才扣费
  - [ ] 失败不扣钱提示
- [ ] 修改 `ContentView.swift` (鉴渣雷达)
  - [ ] 按钮显示"消耗8签"
  - [ ] 点击前检查余额
  - [ ] 余额不足弹窗
- [ ] 修改 `ReplyAssistantView.swift`
  - [ ] 按钮显示"消耗3签"
  - [ ] 集成扣费逻辑
- [ ] 修改 `MetaphysicsView.swift` (截图起卦)
  - [ ] 按钮显示"消耗8签"
  - [ ] 集成扣费逻辑

#### Day 5-6: UI 展示优化
- [ ] 主页右上角显示余额："🌸 66"
- [ ] 余额不足弹窗设计
- [ ] 余额变化动画
- [ ] 消费记录页面（可选）

#### Day 7: 测试与调试
- [ ] 功能流程测试
- [ ] 边界情况测试
- [ ] UI/UX 优化

---

### Week 2: 充值中心开发 (Day 8-14)

#### Day 8-9: 充值界面 UI
- [ ] 创建 `RechargeView.swift`
- [ ] 3档价格卡片设计
  - [ ] 尝鲜包 ¥5.8 / 60签
  - [ ] 超值包 ¥17.8 / 200签（推荐标签）
  - [ ] 尊享包 ¥67.8 / 800签
- [ ] 桃花签图标展示
- [ ] 底部提示文案

#### Day 10-11: IAPManager 开发（模拟数据）
- [ ] 创建 `IAPManager.swift`
- [ ] 模拟购买流程
- [ ] 购买成功/失败处理
- [ ] 与 PeachBlossomManager 集成

#### Day 12: App Store Connect 配置
- [ ] 创建3个内购产品
  - [ ] `com.lovestrategy.coins.tier1` - ¥5.8
  - [ ] `com.lovestrategy.coins.tier2` - ¥17.8
  - [ ] `com.lovestrategy.coins.tier3` - ¥67.8
- [ ] 上传产品截图
- [ ] 填写产品描述

#### Day 13-14: StoreKit 2 真实集成
- [ ] 替换模拟数据为真实API
- [ ] 沙盒测试账号测试
- [ ] 购买流程完整测试
- [ ] 恢复购买功能（消耗型商品）

---

### Week 3: 优化与上线 (Day 15-21)

#### Day 15-16: 多图分析功能（V1.2.0新功能）
- [ ] UI支持选择2-5张图片
- [ ] PhotosPicker 限制 `maxSelectionCount: 5`
- [ ] 图片预览界面
- [ ] 多图上传到 API
- [ ] 定价18签

#### Day 17-18: 体验优化
- [ ] 音效设计
  - [ ] 摇签筒音效
  - [ ] 扣费成功音效
  - [ ] 充值成功音效
- [ ] 动效优化
  - [ ] 桃花签图标动画
  - [ ] 余额数字跳动
  - [ ] 花瓣飘落效果（可选）

#### Day 19: 关联销售功能
- [ ] 鉴渣雷达结果页推荐回复助手
- [ ] 回复助手结果页推荐截图起卦
- [ ] 充值成功推荐使用建议

#### Day 20: 全面测试
- [ ] 功能完整性测试
- [ ] 支付流程测试
- [ ] 多设备同步测试（iPhone + iPad）
- [ ] 边界情况测试

#### Day 21: 提交审核
- [ ] 更新版本号 v1.2.0
- [ ] 准备审核材料
- [ ] 填写更新说明
- [ ] 提交 App Store 审核

---

## 🎨 UI 资源需求

### 1. 桃花签图标 (必需)

#### 主图标（用于余额显示、按钮、充值页面）
```
用途：App内各处展示
尺寸需求：
  - @1x:  48 × 48 px  (iPhone标准)
  - @2x:  96 × 96 px  (iPhone Retina)
  - @3x: 144 × 144 px (iPhone Plus/Pro)

格式：PNG (透明背景)
命名：peach_blossom_coin.png
设计要求：
  - 古风木质签牌
  - 隐约桃花纹路
  - 粉色调为主
  - 清晰可辨，缩小后不失真
```

#### 大图标（用于充值页面头部）
```
用途：充值中心顶部展示
尺寸：200 × 200 px @2x (400×400实际)
格式：PNG (透明背景)
命名：peach_blossom_coin_large.png
```

#### 套餐图标（3个档位）
```
用途：尝鲜包/超值包/尊享包的视觉区分

选项A（简单）：用同一个图标，数量不同
  - 小签：1个签牌
  - 中签：3个签牌堆叠
  - 大签：一捆签牌

选项B（精致）：不同颜色/等级
  - 尝鲜包：普通木色签牌
  - 超值包：金色边框签牌（推荐）
  - 尊享包：红色/紫色签牌（尊贵）

尺寸：120 × 120 px @2x
格式：PNG (透明背景)
```

---

### 2. 音效资源 (可选但强烈推荐)

```
摇签筒音效：
  - 文件名：shake_fortune_stick.mp3
  - 时长：1-2秒
  - 音量：适中，不吵闹

扣费成功音效：
  - 文件名：coin_spend.mp3
  - 时长：0.5秒
  - 音量：轻柔提示音

充值成功音效：
  - 文件名：coin_recharge.mp3
  - 时长：1秒
  - 音量：愉悦的提示音
```

**音效来源建议**：
- 免费资源：freesound.org, zapsplat.com
- 付费资源：AudioJungle (高质量)
- AI生成：ElevenLabs Sound Effects

---

### 3. 动效资源 (可选，V2.0 考虑)

```
花瓣飘落序列帧：
  - 格式：PNG序列 或 Lottie JSON
  - 帧数：30-60帧
  - 尺寸：根据屏幕适配

签牌燃烧动画：
  - 格式：Lottie JSON (推荐)
  - 时长：1-2秒
```

---

## 🛠️ 技术实现清单

### Phase 1-A: PeachBlossomManager (今天完成)

**文件**: `Zhananfenxi/PeachBlossomManager.swift`

**功能**：
```swift
class PeachBlossomManager: ObservableObject {
    @Published var balance: Int = 0
    
    // 初始化（新用户赠送66签）
    func initialize()
    
    // 检查余额
    func checkBalance(required: Int) -> Bool
    
    // 扣费
    func deductCoins(_ amount: Int, reason: String) throws
    
    // 充值
    func addCoins(_ amount: Int, source: String)
    
    // 获取余额
    func getBalance() -> Int
    
    // iCloud 同步
    private func syncToCloud()
    private func loadFromCloud()
}
```

**存储方案**：
- iCloud Key-Value Store
- 键名：`peachBlossomBalance`
- 备份：本地 UserDefaults

---

### Phase 1-B: 功能集成改造

#### VolcengineService 改造
```swift
// 在每个 API 方法前添加余额检查
func analyzeImages(...) async throws -> AnalysisResult {
    // 1. 检查余额（不在这里做，在View层做）
    
    // 2. 调用 API
    let result = try await performAPICall()
    
    // 3. 成功后返回（扣费在View层成功后做）
    return result
}
```

#### ContentView 改造（鉴渣雷达）
```swift
Button {
    // 1. 检查余额
    guard coinManager.checkBalance(required: 8) else {
        showRechargeSheet = true
        return
    }
    
    // 2. 开始分析
    Task {
        do {
            let result = try await service.analyzeImages()
            
            // 3. 成功后扣费
            try coinManager.deductCoins(8, reason: "鉴渣雷达分析")
            
            // 4. 展示结果
            self.analysisResult = result
            
        } catch {
            // 失败不扣费
            showError = true
        }
    }
} label: {
    VStack(spacing: 4) {
        Text("开始深度分析")
        Text("消耗 8 签").font(.caption2)
    }
}
```

---

## 📊 开发进度追踪

### 本周目标 (Week 1)
- [x] 开发计划文档创建
- [ ] PeachBlossomManager 完成
- [ ] 三大功能扣费集成
- [ ] 主页余额显示
- [ ] 余额不足弹窗

### 下周目标 (Week 2)
- [ ] 充值界面 UI
- [ ] IAPManager 开发
- [ ] App Store Connect 配置
- [ ] StoreKit 2 集成

### 第三周目标 (Week 3)
- [ ] 多图分析功能
- [ ] 音效/动效
- [ ] 关联销售
- [ ] 提交审核

---

## 🎯 今日任务 (Day 1)

### 优先级 P0（必须完成）
1. ✅ 开发计划文档
2. ⬜ 创建 `PeachBlossomManager.swift`
3. ⬜ 实现基础功能（初始化、扣费、充值、查询）
4. ⬜ 实现 iCloud 同步

### 优先级 P1（尽量完成）
1. ⬜ 集成到 ContentView（鉴渣雷达）
2. ⬜ 主页右上角显示余额

### 优先级 P2（可延后）
1. ⬜ 余额不足弹窗
2. ⬜ 余额变化动画

---

## 🚀 准备开始

**下一步行动**：

1. **你提供图标** 📷
   - 桃花签主图标 (48/96/144 px)
   - 或者先用占位符，后续替换

2. **我开始写代码** 💻
   - 创建 `PeachBlossomManager.swift`
   - 实现所有核心功能
   - 集成到现有项目

3. **实时测试** 🧪
   - 你在 Xcode 中运行
   - 验证功能是否正常
   - 我根据反馈调整

---

**准备好了吗？告诉我：**
1. 图标准备好了（直接提供文件）
2. 先用占位符（emoji 🌸 暂代）
3. 其他问题

我们开始吧！🎉

