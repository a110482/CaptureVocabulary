//
//  UIView+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/8/1.
//

import UIKit

extension UIView {
    /// Convert UIView to UIImage
    var image: UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return image
    }
}

extension UIButton {
    /// 藍色背景白色字體的確認按鈕樣式
    func applyConfirmStyle() {
        backgroundColor = "3D5CFF".color
        layer.cornerRadius = 5
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
    }
}
