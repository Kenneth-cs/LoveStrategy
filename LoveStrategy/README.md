# Love Strategy - 恋爱军师 iOS App

## 项目说明

这是"恋爱军师"iOS App 的完整源代码，基于 SwiftUI 开发。

## 功能特性

### ✅ 已实现功能

1. **鉴渣雷达** (核心功能)
   - 上传聊天截图（支持多张）
   - AI 分析七大维度（回复速度、关心度、承诺兑现率等）
   - 雷达图可视化展示
   - 红绿灯风险预警
   - 详细分析报告

2. **截图起卦** (玄学模块)
   - 根据聊天截图起六爻卦
   - 卦象解读和签文
   - 太极动画效果

3. **拿捏助手** (高情商回复)
   - 输入对方的话
   - 生成三种风格回复（高冷、绿茶、Drama）
   - 每种风格提供多个选项

## 如何运行

### 方法一：使用 Xcode 打开（推荐）

1. 确保你的 Mac 已安装 Xcode 15.0+
2. 双击打开 `LoveStrategy.xcodeproj` 文件
3. 选择模拟器（iPhone 15 Pro 推荐）
4. 点击运行按钮 (⌘R)

### 方法二：手动创建 Xcode 项目

如果没有 `.xcodeproj` 文件，请按以下步骤操作：

1. 打开 Xcode
2. File -> New -> Project
3. 选择 iOS -> App
4. 填写项目信息：
   - Product Name: LoveStrategy
   - Team: 选择你的开发者账号
   - Organization Identifier: com.yourname
   - Interface: SwiftUI
   - Language: Swift
5. 将以下文件复制到项目中：
   - LoveStrategyApp.swift
   - ContentView.swift
   - Models.swift
   - Assets.xcassets/
   - Info.plist

## 配置火山引擎 API

### 当前状态
- 默认使用 **Mock 数据**（模拟数据），可以直接运行查看效果
- 要使用真实 AI 分析，需要配置火山引擎 API

### 配置步骤

1. 注册火山引擎账号: https://www.volcengine.com/
2. 开通 Doubao-Vision-Pro 服务
3. 获取 API Key 和 Endpoint ID
4. 打开 `Models.swift` 文件
5. 修改以下配置：

```swift
class VolcengineService {
    private let apiKey = "YOUR_VOLCENGINE_API_KEY"  // 替换为你的 API Key
    private let modelID = "YOUR_ENDPOINT_ID"        // 替换为你的 Endpoint ID
    private let useMockData = false                 // 改为 false 使用真实 API
}
```

## 项目结构

```
LoveStrategy/
├── LoveStrategyApp.swift      # App 入口
├── ContentView.swift           # 主界面（包含所有 UI 组件）
├── Models.swift                # 数据模型和 API 服务
├── Assets.xcassets/            # 资源文件
└── Info.plist                  # 配置文件
```

## 技术栈

- **语言**: Swift 5.9+
- **UI 框架**: SwiftUI
- **最低支持**: iOS 16.0+
- **AI 服务**: 字节火山引擎 (Doubao-Vision-Pro)

## 开发进度

- [x] 基础 UI 框架
- [x] 图片上传功能
- [x] Mock 数据展示
- [x] 雷达图组件
- [x] 三个主要 Tab（鉴渣、起卦、拿捏）
- [ ] 火山引擎 API 集成（需要你的 API Key）
- [ ] 图片隐私模糊处理
- [ ] 支付系统（IAP）
- [ ] 历史记录本地存储

## 下一步计划

1. **立刻可以做**：
   - 运行项目，查看 Mock 数据效果
   - 申请火山引擎 API Key
   - 测试真实 API 调用

2. **本周完成**：
   - 优化 Prompt，提高分析准确度
   - 实现图片隐私模糊功能
   - 添加分享功能

3. **下周完成**：
   - 接入支付系统
   - 准备 App Store 提交材料
   - TestFlight 内测

## 常见问题

### Q: 为什么运行后看不到真实分析结果？
A: 默认使用 Mock 数据。要使用真实 AI，需要在 `Models.swift` 中配置火山引擎 API Key。

### Q: 如何测试上传图片功能？
A: 在模拟器中，可以拖拽图片到模拟器窗口，然后在相册中选择。

### Q: 可以在真机上运行吗？
A: 可以。需要在 Xcode 中配置你的 Apple ID 作为开发者账号。

## 许可证

本项目仅供学习和开发使用。

## 联系方式

如有问题，请参考项目根目录的完整文档：
- `LoveStrategy_PRD.md` - 产品需求文档
- `LoveStrategy_Roadmap.md` - 开发规划
- `LoveStrategy_Prompts.md` - AI Prompt 模板
