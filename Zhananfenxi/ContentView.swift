//
//  ContentView.swift
//  Zhananfenxi
//
//  恋爱军师 - 主界面
//

import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
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
        .accentColor(Color(red: 0.8, green: 0.2, blue: 0.4))
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading) {
                        Text("上传聊天记录")
                            .font(.title2).bold()
                        Text("AI 帮你识别潜台词，以此'鉴'人")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Image Upload Area
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
                    .padding(.horizontal)
                    
                    // Analyze Button
                    Button(action: analyzeImage) {
                        HStack {
                            if service.isAnalyzing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("AI 正在分析中...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("开始深度分析")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedImage == nil ? Color.gray : Color(red: 0.8, green: 0.2, blue: 0.4))
                        .cornerRadius(30)
                        .shadow(radius: 5)
                    }
                    .disabled(selectedImage == nil || service.isAnalyzing)
                    .padding(.horizontal)
                    
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
                    Text("Love Strategy")
                        .font(.custom("Didot", size: 20))
                        .bold()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert("分析失败", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage else { return }
        
        Task {
            do {
                let result = try await service.analyzeImages([image])
                await MainActor.run {
                    self.analysisResult = result
                    
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
            Text("⚠️ 本分析由 AI 生成，仅供参考。感情是复杂的，请结合实际情况理性判断。")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .padding()
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("截图六爻起卦")
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                Text("上传聊天记录，AI 将根据对话能量场为你排盘")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black.opacity(0.1))
                        .frame(width: 200, height: 200)
                    
                    Image(systemName: "yin.yang")
                        .font(.system(size: 80))
                        .rotationEffect(.degrees(isCalculating ? 360 : 0))
                        .animation(isCalculating ? Animation.linear(duration: 2).repeatForever(autoreverses: false) : .default, value: isCalculating)
                }
                .padding()
                
                TextField("心中默念你的问题 (选填)", text: $question)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: { showImagePicker = true }) {
                    HStack {
                        Image(systemName: selectedImage == nil ? "photo.on.rectangle.angled" : "checkmark.circle.fill")
                        Text(selectedImage == nil ? "上传聊天截图" : "已选择图片")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Button("感知能量并起卦") {
                    performOracle()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedImage == nil ? Color.gray : Color.black)
                .cornerRadius(30)
                .disabled(selectedImage == nil || isCalculating)
                .padding(.horizontal)
                
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
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.4))
                        VStack(alignment: .leading) {
                            Text("恋爱军师用户")
                                .font(.headline)
                            Text("免费版")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading)
                    }
                    .padding(.vertical)
                }
                
                Section("功能") {
                    NavigationLink {
                        HistoryView(modelContext: modelContext)
                    } label: {
                        Label("历史记录", systemImage: "clock.fill")
                    }
                    
                    Label("使用说明", systemImage: "book.fill")
                }
                
                Section("关于") {
                    Label("用户协议", systemImage: "doc.text")
                    Label("隐私政策", systemImage: "lock.shield")
                    Label("关于我们", systemImage: "info.circle")
                }
            }
            .navigationTitle("我的")
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

