# Love Strategy - 快速设置指南

## 🚀 5 分钟快速启动

### 第一步：打开 Xcode 创建项目

1. 打开 **Xcode**（如果没有，请从 App Store 下载）

2. 点击 **"Create New Project"** 或 `File -> New -> Project`

3. 选择模板：
   - 平台：**iOS**
   - 模板：**App**
   - 点击 **Next**

4. 填写项目信息：
   ```
   Product Name: LoveStrategy
   Team: (选择你的 Apple ID，如果没有点击 "Add Account" 添加)
   Organization Identifier: com.yourname (随便填)
   Interface: SwiftUI ✅ (重要！)
   Language: Swift ✅
   Storage: None
   ```
   - 取消勾选 "Include Tests"（可选）
   - 点击 **Next**

5. 选择保存位置：
   - 选择 `/Users/zhangshaocong6/Desktop/cs/AI/Zhananfenxi/LoveStrategy` 文件夹
   - 点击 **Create**

### 第二步：替换文件

Xcode 会自动生成一些文件，我们需要替换它们：

1. **删除** Xcode 自动生成的以下文件：
   - `ContentView.swift`（在左侧文件列表中右键 -> Delete -> Move to Trash）
   - `LoveStrategyApp.swift`（同样删除）

2. **添加** 我们的文件：
   - 在 Xcode 左侧文件列表的 `LoveStrategy` 文件夹上右键
   - 选择 **"Add Files to LoveStrategy..."**
   - 选择以下文件（按住 Command 键多选）：
     - `LoveStrategyApp.swift`
     - `ContentView.swift`
     - `Models.swift`
   - 确保勾选 **"Copy items if needed"**
   - 点击 **Add**

3. **添加** Assets 和 Info.plist：
   - 删除自动生成的 `Assets.xcassets` 文件夹
   - 用同样的方法添加我们的 `Assets.xcassets` 文件夹
   - 删除自动生成的 `Info.plist`（如果有）
   - 添加我们的 `Info.plist`

### 第三步：运行项目

1. 在 Xcode 顶部选择模拟器：
   - 点击 "LoveStrategy" 旁边的设备选择器
   - 选择 **iPhone 15 Pro** 或任何你喜欢的模拟器

2. 点击左上角的 **▶️ 播放按钮** 或按 `⌘R`

3. 等待编译完成（第一次可能需要 1-2 分钟）

4. 🎉 App 启动成功！你会看到三个 Tab：
   - 鉴渣雷达
   - 截图起卦
   - 拿捏助手

### 第四步：测试功能

1. **测试图片上传**：
   - 点击"鉴渣雷达" Tab
   - 点击上传区域
   - 在模拟器中选择一张图片（可以拖拽图片到模拟器窗口）
   - 点击"开始深度分析"
   - 等待 2.5 秒，查看 Mock 分析结果

2. **测试起卦功能**：
   - 点击"截图起卦" Tab
   - 输入问题（可选）
   - 点击"感知能量并起卦"
   - 查看卦象结果

3. **测试拿捏助手**：
   - 点击"拿捏助手" Tab
   - 输入对方说的话
   - 点击"生成回复建议"
   - 查看三种风格的回复

---

## 🔧 常见问题排查

### 问题 1: "No such module 'SwiftUI'"
**解决方案**：
- 确保在创建项目时选择了 **SwiftUI** 而不是 Storyboard
- 或者在项目设置中，Target -> General -> Deployment Info -> Interface 选择 SwiftUI

### 问题 2: 编译错误 "Cannot find type 'XXX' in scope"
**解决方案**：
- 确保所有三个 Swift 文件都已正确添加到项目中
- 在左侧文件列表中检查文件是否有 ✓ 标记（表示已包含在 Target 中）
- 如果没有，右键文件 -> Target Membership -> 勾选 LoveStrategy

### 问题 3: 模拟器无法启动
**解决方案**：
- 打开 Xcode -> Settings -> Platforms
- 下载最新的 iOS 模拟器
- 重启 Xcode

### 问题 4: "Signing for LoveStrategy requires a development team"
**解决方案**：
- 点击项目设置 -> Signing & Capabilities
- Team 下拉菜单中选择 "Add Account"
- 登录你的 Apple ID（免费账号即可）
- 选择刚添加的账号

---

## 📱 在真机上运行

1. 用数据线连接你的 iPhone 到 Mac
2. 在 iPhone 上信任这台电脑
3. 在 Xcode 设备选择器中选择你的 iPhone
4. 点击运行
5. 首次运行需要在 iPhone 上：
   - 设置 -> 通用 -> VPN与设备管理
   - 点击你的开发者账号
   - 点击"信任"

---

## 🔑 配置真实 API（可选）

当前使用 Mock 数据，要使用真实 AI 分析：

1. 注册火山引擎：https://www.volcengine.com/
2. 开通 Doubao-Vision-Pro 服务
3. 获取 API Key 和 Endpoint ID
4. 在 Xcode 中打开 `Models.swift`
5. 找到 `VolcengineService` 类
6. 修改：
   ```swift
   private let apiKey = "你的API Key"
   private let modelID = "你的Endpoint ID"
   private let useMockData = false  // 改为 false
   ```
7. 重新运行项目

---

## 📊 项目文件说明

```
LoveStrategy/
├── LoveStrategyApp.swift          # App 入口，定义 App 结构
├── ContentView.swift              # 所有 UI 界面（2000+ 行）
│   ├── HomeAnalysisView          # 鉴渣雷达界面
│   ├── ResultCardView            # 分析结果卡片
│   ├── RadarChartView            # 雷达图组件
│   ├── MetaphysicsView           # 起卦界面
│   ├── ReplyAssistantView        # 拿捏助手界面
│   └── ImagePicker               # 图片选择器
├── Models.swift                   # 数据模型和 API 服务
│   ├── AnalysisResult            # 分析结果数据模型
│   ├── AnalysisService           # 分析服务（调用 API）
│   └── VolcengineService         # 火山引擎 API 封装
├── Assets.xcassets/               # 图片和颜色资源
└── Info.plist                     # App 配置（相册权限等）
```

---

## 🎨 自定义 App 图标（可选）

1. 准备一张 1024x1024 的图片（PNG 格式）
2. 在 Xcode 中打开 `Assets.xcassets`
3. 点击 `AppIcon`
4. 拖拽你的图片到 1024x1024 的格子中
5. Xcode 会自动生成所有尺寸

---

## 🚀 下一步

项目已经可以运行了！接下来你可以：

1. ✅ 查看 Mock 数据效果
2. ✅ 申请火山引擎 API（如果要用真实 AI）
3. ✅ 阅读 `LoveStrategy_Roadmap.md` 了解后续开发计划
4. ✅ 按照 `LoveStrategy_QuickStart.md` 在小红书做 MVP 验证

**有任何问题，请查看项目根目录的完整文档！**
