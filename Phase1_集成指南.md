# Phase 1 集成指南

> **目标**: 将桃花签虚拟货币体系集成到现有功能中  
> **预计时间**: 2-3小时  
> **难度**: ⭐️⭐️（中等）

---

## 📋 准备工作

### ✅ 第一步：在 Xcode 中添加新文件

1. **打开 Xcode**，找到项目 `恋爱军师.xcodeproj`

2. **添加以下3个新文件到项目**：
   - `Zhananfenxi/PeachBlossomManager.swift`
   - `Zhananfenxi/RechargeAlertView.swift`
   - `Zhananfenxi/CoinBalanceView.swift`

3. **操作步骤**：
   ```
   右键点击 Zhananfenxi 文件夹 
   → Add Files to "恋爱军师"
   → 选择上述3个文件
   → 确保勾选 "Copy items if needed"
   → 确保 Target 选中 "恋爱军师"
   → 点击 Add
   ```

4. **开启 iCloud 功能**（重要！）：
   ```
   1. 选择项目 → 选择 Target "恋爱军师"
   2. 点击 "Signing & Capabilities" 标签
   3. 点击 "+ Capability"
   4. 搜索并添加 "iCloud"
   5. 勾选 "Key-value storage"
   ```

5. **编译测试**：
   ```
   Cmd + B 编译
   确保无错误
   ```

---

## 🎯 集成步骤

### 步骤1：修改 ContentView.swift（鉴渣雷达）

#### 1.1 添加 CoinManager 引用

在 `ContentView.swift` 文件顶部，找到 `struct ContentView: View {` 这一行，在里面添加：

```swift
struct ContentView: View {
    // ... 现有的 @State 变量 ...
    
    // 🆕 添加桃花签管理器
    @StateObject private var coinManager = PeachBlossomManager.shared
    
    // 🆕 添加余额不足弹窗状态
    @State private var showRechargeAlert = false
    @State private var requiredCoins = 0
    @State private var featureName = ""
    
    // ... 其他代码 ...
}
```

#### 1.2 在导航栏添加余额显示

找到 `HomeAnalysisView` 的 `navigationTitle`，在它上面或下面添加：

```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        CoinBalanceView(
            coinManager: coinManager,
            style: .compact
        ) {
            // 点击余额，打开充值页面（暂时无操作）
            print("点击余额")
        }
    }
}
```

#### 1.3 修改"开始深度分析"按钮

找到 `HomeAnalysisView` 中的"开始深度分析"按钮，修改为：

```swift
Button {
    // 🆕 1. 先检查余额
    guard coinManager.checkBalance(required: 8) else {
        requiredCoins = 8
        featureName = "鉴渣雷达"
        showRechargeAlert = true
        return
    }
    
    // 2. 原有的分析逻辑
    isAnalyzing = true
    focusedField = nil
    
    Task {
        do {
            let result = try await volcengineService.analyzeImages(selectedImages)
            
            // 🆕 3. 分析成功后才扣费
            try? coinManager.deductCoins(8, reason: "鉴渣雷达分析")
            
            // 4. 原有的结果处理
            await MainActor.run {
                self.analysisResult = result
                self.showResult = true
                self.isAnalyzing = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "分析失败：\(error.localizedDescription)"
                self.showError = true
                self.isAnalyzing = false
            }
        }
    }
} label: {
    VStack(spacing: 4) {
        Text("开始深度分析")
            .font(.headline)
        // 🆕 显示消耗金额
        Text("消耗 8 签")
            .font(.caption2)
            .foregroundColor(.white.opacity(0.8))
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(
        LinearGradient(
            colors: [Theme.primaryPink, Theme.accentPink],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
    .foregroundColor(.white)
    .cornerRadius(12)
}
.disabled(selectedImages.isEmpty || isAnalyzing)
```

#### 1.4 添加余额不足弹窗

在 `ContentView` 的最外层（比如 `TabView` 之后）添加：

```swift
.sheet(isPresented: $showRechargeAlert) {
    RechargeAlertView(
        coinManager: coinManager,
        requiredAmount: requiredCoins,
        featureName: featureName
    )
    .presentationDetents([.medium])
    .presentationDragIndicator(.visible)
}
```

---

### 步骤2：修改 ReplyAssistantView.swift（高情商回复）

#### 2.1 添加 CoinManager 引用

```swift
struct ReplyAssistantView: View {
    // ... 现有变量 ...
    
    // 🆕 添加
    @StateObject private var coinManager = PeachBlossomManager.shared
    @State private var showRechargeAlert = false
    
    // ... 其他代码 ...
}
```

#### 2.2 修改"生成回复话术"按钮

找到"生成回复话术"按钮，修改为：

```swift
Button {
    // 🆕 1. 先检查余额
    guard coinManager.checkBalance(required: 3) else {
        showRechargeAlert = true
        return
    }
    
    // 2. 原有的生成逻辑
    isGenerating = true
    focusedField = nil
    errorMessage = nil
    
    Task {
        do {
            let result = try await volcengineService.generateReplies(
                context: contextInput,
                targetMessage: targetMessage
            )
            
            // 🆕 3. 成功后才扣费
            try? coinManager.deductCoins(3, reason: "高情商回复生成")
            
            // 4. 原有的结果处理
            await MainActor.run {
                self.replies = result
                self.isGenerating = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "军师正在忙碌，请点击重试~"
                self.isGenerating = false
            }
        }
    }
} label: {
    if isGenerating {
        ProgressView()
            .tint(.white)
    } else {
        VStack(spacing: 4) {
            Text("生成回复话术")
                .font(.headline)
            // 🆕 显示消耗金额
            Text("消耗 3 签")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
.frame(maxWidth: .infinity)
.frame(height: 50)
.background(
    LinearGradient(
        colors: [Theme.primaryPink, Theme.accentPink],
        startPoint: .leading,
        endPoint: .trailing
    )
)
.foregroundColor(.white)
.cornerRadius(12)
.disabled(targetMessage.isEmpty || isGenerating)
```

#### 2.3 添加余额不足弹窗

在 `ReplyAssistantView` 的最外层添加：

```swift
.sheet(isPresented: $showRechargeAlert) {
    RechargeAlertView(
        coinManager: coinManager,
        requiredAmount: 3,
        featureName: "高情商回复助手"
    )
    .presentationDetents([.medium])
    .presentationDragIndicator(.visible)
}
```

---

### 步骤3：修改 MetaphysicsView.swift（截图起卦）

#### 3.1 添加 CoinManager 引用

```swift
// 在文件中找到 MetaphysicsView 的定义
// 由于 MetaphysicsView 是 ContentView 的内部视图，需要传递 coinManager

// 在 ContentView 中调用 MetaphysicsView 时传入：
MetaphysicsView(
    coinManager: coinManager,  // 🆕 传入
    showRechargeAlert: $showRechargeAlert,
    requiredCoins: $requiredCoins,
    featureName: $featureName
)
```

#### 3.2 修改 MetaphysicsView 的定义

```swift
struct MetaphysicsView: View {
    @ObservedObject var coinManager: PeachBlossomManager  // 🆕 接收
    @Binding var showRechargeAlert: Bool  // 🆕 接收
    @Binding var requiredCoins: Int  // 🆕 接收
    @Binding var featureName: String  // 🆕 接收
    
    // ... 其他现有变量 ...
}
```

#### 3.3 修改"开始起卦"按钮

```swift
Button {
    // 🆕 1. 先检查余额
    guard coinManager.checkBalance(required: 8) else {
        requiredCoins = 8
        featureName = "截图起卦"
        showRechargeAlert = true
        return
    }
    
    // 2. 原有的起卦逻辑
    isAnalyzing = true
    focusedField = nil
    
    Task {
        do {
            let result = try await volcengineService.performOracle(selectedImage)
            
            // 🆕 3. 成功后才扣费
            try? coinManager.deductCoins(8, reason: "截图起卦")
            
            // 4. 原有的结果处理
            await MainActor.run {
                self.oracleResult = result
                self.showResult = true
                self.isAnalyzing = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "起卦失败：\(error.localizedDescription)"
                self.showError = true
                self.isAnalyzing = false
            }
        }
    }
} label: {
    if isAnalyzing {
        ProgressView()
            .tint(.white)
    } else {
        VStack(spacing: 4) {
            Text("开始起卦")
                .font(.headline)
            // 🆕 显示消耗金额
            Text("消耗 8 签")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
.frame(maxWidth: .infinity)
.frame(height: 50)
.background(
    LinearGradient(
        colors: [Theme.primaryPink, Theme.accentPink],
        startPoint: .leading,
        endPoint: .trailing
    )
)
.foregroundColor(.white)
.cornerRadius(12)
.disabled(selectedImage == nil || isAnalyzing)
```

---

## 🎨 UI 资源需求

### 桃花签图标尺寸

目前代码中使用了 emoji 🌸 作为占位符。如果你要提供自定义图标：

#### 主图标（必需）
```
格式：PNG（透明背景）
命名：peach_blossom_coin.png

尺寸：
- peach_blossom_coin@1x.png:  48 × 48 px
- peach_blossom_coin@2x.png:  96 × 96 px
- peach_blossom_coin@3x.png: 144 × 144 px

放置位置：
项目 → Assets.xcassets → 右键 → Import → 选择3个文件

设计要求：
- 古风木质签牌风格
- 粉色调为主
- 隐约桃花纹路
- 清晰可辨，缩小后不失真
```

#### 替换代码中的 emoji

如果提供了自定义图标，需要在代码中替换：

**CoinBalanceView.swift**：
```swift
// 把所有 Text("🌸") 替换为：
Image("peach_blossom_coin")
    .resizable()
    .frame(width: 24, height: 24)
```

**RechargeAlertView.swift**：
```swift
// 把 Text("🌸") 替换为：
Image("peach_blossom_coin")
    .resizable()
    .frame(width: 50, height: 50)
```

---

## ✅ 测试清单

### 基础功能测试

- [ ] 首次启动，余额显示 66 签
- [ ] 导航栏右上角显示余额
- [ ] 点击"开始深度分析"按钮
  - [ ] 余额足够：正常分析，扣除 8 签
  - [ ] 余额不足：弹出充值提示
- [ ] 点击"生成回复话术"按钮
  - [ ] 余额足够：正常生成，扣除 3 签
  - [ ] 余额不足：弹出充值提示
- [ ] 点击"开始起卦"按钮
  - [ ] 余额足够：正常起卦，扣除 8 签
  - [ ] 余额不足：弹出充值提示

### iCloud 同步测试

- [ ] 在设备A使用功能，消耗桃花签
- [ ] 在设备B打开App，余额自动同步
- [ ] 卸载App，重新安装，余额恢复（需同一 Apple ID）

### 边界情况测试

- [ ] 余额刚好等于消耗金额
- [ ] 余额为 0
- [ ] API 调用失败，余额不扣除
- [ ] 飞行模式下使用（本地优先）

---

## 🐛 常见问题

### Q1: 编译错误 "Cannot find 'PeachBlossomManager' in scope"

**解决方案**：
1. 确保 `PeachBlossomManager.swift` 已添加到 Xcode 项目
2. 确保文件在正确的 Target 中（勾选了"恋爱军师"）
3. 清理项目：Cmd + Shift + K，然后重新编译

### Q2: 余额始终为 0

**解决方案**：
1. 检查是否开启了 iCloud Capability
2. 在 Xcode 中：Target → Signing & Capabilities → 添加 iCloud → 勾选 Key-value storage
3. 检查是否登录了 Apple ID（设置 → iCloud）

### Q3: 余额不足弹窗不显示

**解决方案**：
1. 检查是否添加了 `.sheet(isPresented: $showRechargeAlert)` 修饰器
2. 确保 `showRechargeAlert` 状态变量存在
3. 检查逻辑：`showRechargeAlert = true` 是否被正确触发

### Q4: 扣费失败

**解决方案**：
1. 查看控制台日志，寻找错误信息
2. 确保在 API 成功后才调用 `deductCoins`
3. 使用 `try?` 或 `do-catch` 处理扣费异常

---

## 📊 下一步开发

### Phase 1 完成后的任务

✅ 已完成：
- PeachBlossomManager 核心功能
- 余额显示组件
- 余额不足弹窗
- 三大功能集成扣费逻辑

⬜ 待开发（Phase 2）：
- 充值中心 UI（RechargeView.swift）
- StoreKit 2 集成（IAPManager.swift）
- App Store Connect 内购配置
- 真实支付流程

---

## 🎉 集成完成

恭喜！如果以上步骤都完成，你的 App 已经具备了完整的虚拟货币体系！

**现在可以做什么**：
1. ✅ 运行 App，体验扣费流程
2. ✅ 测试余额不足提示
3. ✅ 验证 iCloud 同步
4. ✅ 准备UI资源（图标）
5. ⏭️ 开始 Phase 2 开发（充值中心）

---

**有任何问题，随时告诉我！** 🚀

