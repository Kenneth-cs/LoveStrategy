//
//  MultiImagePicker.swift
//  恋爱军师
//
//  多图选择器（支持1-5张图片）- 直接调用系统相册
//

import SwiftUI
import PhotosUI

struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) var dismiss
    let maxSelection: Int
    let isMultiMode: Bool
    
    init(selectedImages: Binding<[UIImage]>, maxSelection: Int = 5, isMultiMode: Bool = false) {
        self._selectedImages = selectedImages
        self.maxSelection = isMultiMode ? maxSelection : 1
        self.isMultiMode = isMultiMode
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = maxSelection
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker
        
        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else {
                return
            }
            
            // 使用索引保持用户选择的顺序
            var images: [UIImage?] = Array(repeating: nil, count: results.count)
            let group = DispatchGroup()
            
            for (index, result) in results.enumerated() {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        images[index] = image
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                // 过滤掉加载失败的图片，保持顺序
                let validImages = images.compactMap { $0 }
                self.parent.selectedImages = validImages
                print("📸 已加载 \(validImages.count) 张图片（按选择顺序）")
            }
        }
    }
}

