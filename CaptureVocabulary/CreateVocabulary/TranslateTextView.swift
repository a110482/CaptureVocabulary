//
//  ExplainsTextView.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2023/4/29.
//

import UIKit

class TranslateTextView: UITextView {
    private let shapeLayer = CAShapeLayer()
    
    private var isHiddenTranslate = false
    
    private var model: StarDictORM.ORM?
    
    private var sentences: [SimpleSentencesORM.ORM]?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(model: StarDictORM.ORM?,
                sentences: [SimpleSentencesORM.ORM]? = nil,
                isHiddenTranslateSwitchOn: Bool = false,
                pressTipVocabulary: String? = nil) {
        self.model = model
        self.sentences = sentences
        
        update(isHiddenTranslateSwitchOn: isHiddenTranslateSwitchOn, pressTipVocabulary: pressTipVocabulary)
    }
    
    func update(isHiddenTranslateSwitchOn: Bool,
                pressTipVocabulary: String?) {
        guard isHiddenTranslateSwitchOn else {
            self.isHiddenTranslate = false
            layoutText()
            return
        }
        
        self.isHiddenTranslate = model?.word != pressTipVocabulary
        layoutText()
    }
    
    private func layoutText() {
        guard let explains = model?.translation else {
            text = nil
            return
        }
        
        Task {
            // 組裝顯示文字的同時, 把複習模式時需要隱藏的中文位置記錄下來
            var textStartLocation = 0
            var chineseRanges: [NSRange] = []
            var text = ""
            func append(text input: String, isChinese: Bool = false) {
                text += input
                if isChinese {
                    chineseRanges.append(NSRange(location: textStartLocation, length: input.count))
                }
                textStartLocation += input.count
            }
            
            // 開始組裝文字
            let explainsLocalized = await explains.localized()
            append(text: explainsLocalized, isChinese: true)
            append(text: "\n\n")
            if let sentences = sentences {
                for model in sentences {
                    if let sentence = model.sentence, let translate = model.translate {
                        append(text: sentence + "\n")
                        append(text: translate + "\n", isChinese: true)
                    }
                    
                }
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            // 设置行高（行距），例如设置为1.5倍行高
            paragraphStyle.lineSpacing = 10 // 按需调整行高

            // 创建一个属性字典来应用段落样式
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16), // 设置字体大小
                .paragraphStyle: paragraphStyle // 设置段落样式
            ]

            // 创建一个NSAttributedString并将其应用到UITextView
            let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
            // 需要隱藏解釋
            if isHiddenTranslate {
                for range in chineseRanges {
                    attributedText.addAttribute(.foregroundColor,
                                                value: UIColor.clear,
                                                range: range)
                }
            }
            
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
        
        while currentX < self.bounds.width {
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
