//
//  ExplainsTextView.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2023/4/29.
//

import UIKit

class TranslateTextView: UITextView {
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        roundCorners(.allCorners, radius: 5)
        textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(model: StarDictORM.ORM?) {
        guard let explains = model?.translation else {
            text = nil
            return
        }
        Task {
            let text = await explains.localized()
            let paragraphStyle = NSMutableParagraphStyle()

            // 设置行高（行距），例如设置为1.5倍行高
            paragraphStyle.lineSpacing = 10 // 按需调整行高

            // 创建一个属性字典来应用段落样式
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16), // 设置字体大小
                .paragraphStyle: paragraphStyle // 设置段落样式
            ]

            // 创建一个NSAttributedString并将其应用到UITextView
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            self.attributedText = attributedText
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addDecorateLayer()
    }
    
    private func addDecorateLayer() {
        // 设置横纹的高度和间隔
        let lineHeight: CGFloat = 0.5 // 调整横纹高度
        let lineSpacing: CGFloat = 20.0 // 调整横纹间隔

        // 创建横纹的路径
        let linePath = UIBezierPath()
        var currentY: CGFloat = 0.0
        var currentX: CGFloat = 0.0

        while currentY < self.bounds.height {
            linePath.move(to: CGPoint(x: 0, y: currentY))
            linePath.addLine(to: CGPoint(x: self.bounds.width, y: currentY))
            currentY += lineHeight + lineSpacing
        }
        
        while currentX < self.bounds.height {
            linePath.move(to: CGPoint(x: currentX, y: 0))
            linePath.addLine(to: CGPoint(x: currentX, y: self.bounds.height))
            currentX += lineHeight + lineSpacing
        }

        // 创建CAShapeLayer来显示横纹路径
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        shapeLayer.lineWidth = lineHeight
        
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
}
