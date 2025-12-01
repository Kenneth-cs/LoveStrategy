#!/bin/bash

echo "🚀 正在为你创建 Love Strategy Xcode 项目..."
echo ""

# 项目路径
PROJECT_DIR="/Users/zhangshaocong6/Desktop/cs/AI/Zhananfenxi/LoveStrategyApp"
SOURCE_DIR="/Users/zhangshaocong6/Desktop/cs/AI/Zhananfenxi/LoveStrategy"

# 检查源文件是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ 错误：找不到源文件目录 $SOURCE_DIR"
    exit 1
fi

# 创建项目目录
echo "📁 创建项目目录..."
mkdir -p "$PROJECT_DIR"

# 复制所有源文件
echo "📋 复制源代码文件..."
cp "$SOURCE_DIR/LoveStrategyApp.swift" "$PROJECT_DIR/"
cp "$SOURCE_DIR/ContentView.swift" "$PROJECT_DIR/"
cp "$SOURCE_DIR/Models.swift" "$PROJECT_DIR/"
cp "$SOURCE_DIR/Info.plist" "$PROJECT_DIR/"
cp -r "$SOURCE_DIR/Assets.xcassets" "$PROJECT_DIR/"

echo ""
echo "✅ 文件复制完成！"
echo ""
echo "📱 接下来请按照以下步骤操作："
echo ""
echo "1. 打开 Xcode"
echo "2. File -> New -> Project"
echo "3. 选择 iOS -> App -> Next"
echo "4. 填写信息："
echo "   - Product Name: LoveStrategyApp"
echo "   - Interface: SwiftUI ✅"
echo "   - Language: Swift ✅"
echo "5. 保存位置选择: $PROJECT_DIR"
echo "6. 创建后，将我准备好的文件替换进去"
echo ""
echo "或者，我可以帮你生成一个完整的 Package.swift 文件，用 Swift Package 的方式运行"
echo ""

