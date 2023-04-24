//
//  QueryStringTextField.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/24.
//

import UIKit

class QueryStringTextField: UITextField {
    private let textFieldImageView = UIImageView(image: UIImage(named: "textFiledPan"))
    private let underLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(textFieldImageView)
        textFieldImageView.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        addSubview(underLine)
        underLine.snp.makeConstraints {
            $0.width.bottom.left.equalToSuperview()
            $0.height.equalTo(1)
        }
        updateUnderLineColor()
        addTarget(self, action: #selector(updateUnderLineColor), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(
            top: 0, left: 5, bottom: 0, right: 24)
        )
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(
            top: 0, left: 5, bottom: 0, right: 24)
        )
    }

    
    @objc func updateUnderLineColor() {
        let colorString: String
        if let text = text, !text.isEmpty {
            colorString = "#5669FF"
        } else {
            colorString = "#BDBDBD"
        }
        underLine.backgroundColor = UIColor(hexString: colorString)
    }
}
