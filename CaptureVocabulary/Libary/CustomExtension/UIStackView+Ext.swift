//
//  UIStackView+Ext.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/24.
//

import UIKit

extension UIStackView {
    func padding(gap: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints {
            if self.axis == .horizontal {
                $0.width.equalTo(gap)
            } else {
                $0.height.equalTo(gap)
            }
        }
        return v
    }
}
