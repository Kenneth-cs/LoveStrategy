//
//  QRCodeView.swift
//  恋爱军师
//
//  加入组织二维码视图
//

import SwiftUI

struct QRCodeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // 标题
                VStack(spacing: 10) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppTheme.iconGradient)
                    
                    Text("加入组织")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("扫描二维码添加微信")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 二维码区域
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 20) {
                        // 这里放置微信二维码图片
                        // 用户需要将二维码图片添加到 Assets.xcassets 中
                        // 命名为 "wechat_qrcode"
                        if let _ = UIImage(named: "wechat_qrcode") {
                            Image("wechat_qrcode")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .cornerRadius(12)
                        } else {
                            // 占位符
                            VStack(spacing: 15) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 100))
                                    .foregroundColor(AppTheme.accentPink.opacity(0.3))
                                
                                Text("请添加二维码图片")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("命名为：wechat_qrcode")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 250, height: 250)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // 提示文字
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "wechat")
                                    .font(.caption)
                                Text("微信扫一扫")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                            
                            Text("加入我们一起交流")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(30)
                }
                .frame(width: 320, height: 380)
                
                Spacer()
                
                // 提示信息（已隐藏）
                // HStack(spacing: 8) {
                //     Image(systemName: "info.circle.fill")
                //         .foregroundColor(AppTheme.accentPink)
                //     
                //     Text("长按二维码可保存到相册")
                //         .font(.caption)
                //         .foregroundColor(.secondary)
                // }
                // .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

