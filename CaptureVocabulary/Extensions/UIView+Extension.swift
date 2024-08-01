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
