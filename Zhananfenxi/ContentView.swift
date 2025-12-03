//
//  ContentView.swift
//  Zhananfenxi
//
//  恋爱军师 - 主界面
//

import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    @State private var hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
    
    var body: some View {
        Group {
            if hasAgreedToTerms {
                MainTabView()
            } else {
                WelcomeView(hasAgreed: $hasAgreedToTerms)
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeAnalysisView()
                .tabItem {
                    Label("鉴渣雷达", systemImage: "waveform.path.ecg")
                }
            
            ReplyAssistantView()
                .tabItem {
                    Label("拿捏助手", systemImage: "message.fill")
                }
            
            MetaphysicsView()
                .tabItem {
                    Label("截图起卦", systemImage: "star.circle.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.circle.fill")
                }
        }
        .accentColor(AppTheme.darkPink)
        // iPad 适配：禁用侧边栏模式，使用 iPhone 样式的 TabView
        .tabViewStyle(.automatic)
    }
}

// MARK: - Home Analysis View

struct HomeAnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var service = VolcengineService()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showResult = false
    @State private var analysisResult: AnalysisResult?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showLimitAlert = false
    @State private var limitMessage = ""
    @State private var showNewUserWelcome = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("上传聊天记录")
                                    .font(.title2).bold()
                                Text("军师帮你识别潜台词，以此'鉴'人")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // 剩余次数显示
                            VStack(spacing: 2) {
                                Text("\(UsageLimitManager.getRemainingCount())")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(UsageLimitManager.getRemainingCount() > 0 ? AppTheme.accentPink : .red)
                                Text("剩余次数")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.softPink)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Image Upload Area
                    ZStack(alignment: .topTrailing) {
                        Button(action: { showImagePicker = true }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 200)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            .foregroundColor(.gray.opacity(0.5))
                                    )
                                
                                if let img = selectedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 180)
                                        .cornerRadius(12)
                                } else {
                                    VStack {
                                        Image(systemName: "plus.viewfinder")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("点击上传微信截图")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        
                        // 删除按钮
                        if selectedImage != nil {
                            Button {
                                withAnimation {
                                    selectedImage = nil
                                    analysisResult = nil
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white, AppTheme.accentPink)
                                    .shadow(radius: 2)
                            }
                            .padding(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Analyze Button
                    Button(action: analyzeImage) {
                        HStack {
                            if service.isAnalyzing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("军师正在分析中...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("开始深度分析")
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: selectedImage == nil || service.isAnalyzing))
                    .disabled(selectedImage == nil || service.isAnalyzing)
                    .padding(.horizontal)
                    
                    // 加载提示
                    if service.isAnalyzing {
                        Text("预计需要 10-15 秒")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .transition(.opacity)
                    }
                    
                    // Result Area
                    if let result = analysisResult {
                        ResultCardView(result: result)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.iconGradient)
                        
                        Text("Love Strategy")
                            .font(.custom("Didot", size: 20))
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.accentPink, AppTheme.darkPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
            .toolbarBackground(AppTheme.softPink, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert("分析失败", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("使用次数限制", isPresented: $showLimitAlert) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(limitMessage)
            }
            .alert("🎉 新用户福利", isPresented: $showNewUserWelcome) {
                Button("开始体验", role: .cancel) {}
            } message: {
                Text(UsageLimitManager.getNewUserWelcomeMessage())
            }
            .onAppear {
                // 检查是否显示新手福利
                if UsageLimitManager.isNewUser() && !UsageLimitManager.hasReceivedBonus() {
                    showNewUserWelcome = true
                    UsageLimitManager.markBonusReceived()
                }
            }
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage else { return }
        
        // 检查使用次数限制
        if !UsageLimitManager.canUseFeature() {
            limitMessage = UsageLimitManager.getLimitReachedMessage()
            showLimitAlert = true
            return
        }
        
        Task {
            do {
                let result = try await service.analyzeImages([image])
                await MainActor.run {
                    self.analysisResult = result
                    
                    // 增加使用次数
                    UsageLimitManager.incrementUsage()
                    
                    // 保存到历史记录
                    let imageData = image.jpegData(compressionQuality: 0.7)
                    let historyManager = HistoryManager(modelContext: modelContext)
                    historyManager.saveHistory(result, imageData: imageData)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
                print("分析失败: \(error)")
            }
        }
    }
}

// MARK: - Result Card View

struct ResultCardView: View {
    let result: AnalysisResult
    @State private var showRadarChart = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Score Header
            HStack {
                VStack(alignment: .leading) {
                    Text("综合渣男指数")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(100 - result.overallScore)%")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(scoreColor(score: result.overallScore))
                }
                Spacer()
                
                // 风险等级图标
        VStack {
                    Image(systemName: riskIcon(score: result.overallScore))
                        .font(.system(size: 30))
                        .foregroundColor(scoreColor(score: result.overallScore))
                    Text(riskLevel(score: result.overallScore))
                        .font(.caption2)
                        .foregroundColor(scoreColor(score: result.overallScore))
                }
            }
            
            Divider()
            
            // 雷达图
            if showRadarChart && !result.dimensions.isEmpty {
                RadarChartView(dimensions: result.dimensions)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Divider()
            
            // Summary
            VStack(alignment: .leading, spacing: 10) {
                Label("军师点评", systemImage: "quote.bubble.fill")
                    .font(.headline)
                
                Text(result.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(5)
            }
            
            // Flags
            if !result.flags.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Label("红旗预警", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    ForEach(result.flags) { flag in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "flag.fill")
                                .foregroundColor(flag.type.color)
                            Text(flag.description)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(10)
                        .background(flag.type.color.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            
            // Advice
            VStack(alignment: .leading, spacing: 10) {
                Label("后续操盘建议", systemImage: "lightbulb.fill")
                    .font(.headline)
                
                Text(result.advice)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(10)
            }
            
            // 免责声明
            Text(LegalDocuments.shortDisclaimer)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
        }
        .cardStyle(backgroundColor: Color(red: 0.949, green: 0.945, blue: 0.965))
    }
    
    func scoreColor(score: Int) -> Color {
        if score < 50 { return .red }
        if score < 80 { return .orange }
        return .green
    }
    
    func riskLevel(score: Int) -> String {
        if score < 50 { return "高风险" }
        if score < 80 { return "需观察" }
        return "较安全"
    }
    
    func riskIcon(score: Int) -> String {
        if score < 50 { return "xmark.octagon.fill" }
        if score < 80 { return "exclamationmark.triangle.fill" }
        return "checkmark.circle.fill"
    }
}

// MARK: - Metaphysics View

struct MetaphysicsView: View {
    @StateObject var service = VolcengineService()
    @State private var selectedImage: UIImage?
    @State private var question: String = ""
    @State private var showImagePicker = false
    @State private var isCalculating = false
    @State private var showResult = false
    @State private var oracleResult: OracleResult?
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(AppTheme.iconGradient)
                    
                    Text("截图起卦")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.accentPink, AppTheme.darkPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.top)
                
                Text("上传聊天记录，军师将通过卦象隐喻进行心理投射分析")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // 图片预览或占位符
                ZStack(alignment: .topTrailing) {
                    Button(action: { showImagePicker = true }) {
                        ZStack {
                            if let image = selectedImage {
                                // 显示已选择的图片
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(AppTheme.accentPink, lineWidth: 3)
                                    )
                            } else {
                                // 占位符
                                ZStack {
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                        .foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 200, height: 200)
                                    
                                    VStack(spacing: 15) {
                                        Image(systemName: "yin.yang")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                            .rotationEffect(.degrees(isCalculating ? 360 : 0))
                                            .animation(isCalculating ? Animation.linear(duration: 2).repeatForever(autoreverses: false) : .default, value: isCalculating)
                                        
                                        Text("点击上传截图")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 删除按钮
                    if selectedImage != nil {
                        Button {
                            withAnimation {
                                selectedImage = nil
                                oracleResult = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white, AppTheme.accentPink)
                                .shadow(radius: 2)
                        }
                        .offset(x: 15, y: -15)
                    }
                }
                .padding()
                
                TextField("你想了解的问题 (选填)", text: $question)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($isInputFocused)
                
                // 开始测试按钮
                Button {
                    performOracle()
                } label: {
                    HStack(spacing: 10) {
                        if isCalculating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("军师正在感知能量场...")
                        } else {
                            Image(systemName: "sparkles")
                            Text("开始起卦")
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: selectedImage == nil || isCalculating))
                .disabled(selectedImage == nil || isCalculating)
                .padding(.horizontal)
                
                // 加载提示
                if isCalculating {
                    VStack(spacing: 10) {
                        Text("正在通过卦象进行心理投射分析")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("预计需要 10-15 秒")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    .transition(.opacity)
                }
                
                Spacer()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showResult) {
                if let result = oracleResult {
                    OracleResultView(result: result)
                }
            }
        }
    }
    
    private func performOracle() {
        guard let image = selectedImage else { return }
        
        // 收起键盘
        isInputFocused = false
        
        isCalculating = true
        
        Task {
            do {
                let result = try await service.performOracle([image], question: question)
                await MainActor.run {
                    self.oracleResult = result
                    self.isCalculating = false
                    self.showResult = true
                }
            } catch {
                await MainActor.run {
                    self.isCalculating = false
                }
                print("起卦失败: \(error)")
            }
        }
    }
}

// MARK: - Oracle Result View

struct OracleResultView: View {
    let result: OracleResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(result.hexagramSymbol)
                        .font(.system(size: 80))
                        .padding()
                    
                    Text(result.hexagramName)
                        .font(.system(size: 36, weight: .bold))
                    
                    Text(result.hexagramText)
                        .font(.title3)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("卦象解读")
                            .font(.headline)
                        Text(result.interpretation)
                            .font(.body)
                            .lineSpacing(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("大师赠言")
                            .font(.headline)
                        Text(result.advice)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.4))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    Text(result.signature)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                    
                    Text(result.disclaimer)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
        }
        .padding()
            }
            .navigationTitle("卦象")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showUserAgreement = false
    @State private var showPrivacyPolicy = false
    @State private var showUserGuide = false
    @State private var dailyUsageCount = UserDefaults.standard.integer(forKey: "dailyUsageCount")
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(AppTheme.softPink)
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(AppTheme.iconGradient)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("恋爱军师用户")
                                .font(.headline)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.accentPink)
                                Text("免费版")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.leading)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    // 今日使用次数
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(AppTheme.accentPink)
                        Text("今日已使用")
                        Spacer()
                        Text("\(dailyUsageCount)/3 次")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("功能") {
                    NavigationLink {
                        HistoryView(modelContext: modelContext)
                    } label: {
                        Label("历史记录", systemImage: "clock.fill")
                    }
                    
                    // TODO: 后续恢复使用说明
//                    Button {
//                        showUserGuide = true
//                    } label: {
//                        Label("使用说明", systemImage: "book.fill")
//                            .foregroundColor(.primary)
//                    }
                }
                
                Section("法律与隐私") {
                    Button {
                        showUserAgreement = true
                    } label: {
                        Label("用户协议", systemImage: "doc.text")
                            .foregroundColor(.primary)
                    }
                    
                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        Label("隐私政策", systemImage: "lock.shield")
                            .foregroundColor(.primary)
                    }
                }
                
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showUserAgreement) {
                UserAgreementView()
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showUserGuide) {
                UserGuideView()
            }
            .onAppear {
                dailyUsageCount = UserDefaults.standard.integer(forKey: "dailyUsageCount")
            }
        }
    }
}

// MARK: - Image Picker

import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ContentView()
}

