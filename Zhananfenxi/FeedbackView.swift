//
//  FeedbackView.swift
//  恋爱军师
//
//  建议反馈视图
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var feedbackText: String = ""
    @State private var showMailComposer = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 标题说明
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.title)
                            .foregroundColor(AppTheme.accentPink)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("建议反馈")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("您的意见对我们很重要")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.softPink)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 输入框
                VStack(alignment: .leading, spacing: 8) {
                    Text("请输入您的建议或反馈")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $feedbackText)
                        .frame(height: 200)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    HStack {
                        Spacer()
                        Text("\(feedbackText.count) 字")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // 提示信息
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(AppTheme.accentPink)
                    Text("您的反馈将发送至：youqukeji126@126.com")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 发送按钮
                Button(action: sendFeedback) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("发送反馈")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [AppTheme.accentPink, AppTheme.darkPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showMailComposer) {
            MailComposeView(
                recipients: ["youqukeji126@126.com"],
                subject: "【恋爱军师】用户反馈",
                body: feedbackText
            ) { result in
                handleMailResult(result)
            }
        }
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) {
                if alertMessage.contains("成功") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            showMailComposer = true
        } else {
            // 无法发送邮件，复制到剪贴板
            UIPasteboard.general.string = """
            收件人：youqukeji126@126.com
            主题：【恋爱军师】用户反馈
            
            \(feedbackText)
            """
            alertMessage = "您的设备未配置邮件账户\n\n反馈内容已复制到剪贴板\n请手动发送邮件到：\nyouqukeji126@126.com"
            showAlert = true
        }
    }
    
    private func handleMailResult(_ result: Result<MFMailComposeResult, Error>) {
        switch result {
        case .success(let mailResult):
            switch mailResult {
            case .sent:
                alertMessage = "反馈发送成功！\n感谢您的宝贵意见 💕"
                showAlert = true
            case .saved:
                alertMessage = "反馈已保存为草稿"
                showAlert = true
            case .cancelled:
                break
            case .failed:
                alertMessage = "发送失败，请稍后重试"
                showAlert = true
            @unknown default:
                break
            }
        case .failure:
            alertMessage = "发送失败，请稍后重试"
            showAlert = true
        }
    }
}

// MARK: - Mail Composer Wrapper
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String
    let completion: (Result<MFMailComposeResult, Error>) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let completion: (Result<MFMailComposeResult, Error>) -> Void
        
        init(completion: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
            self.completion = completion
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(result))
            }
            controller.dismiss(animated: true)
        }
    }
}

