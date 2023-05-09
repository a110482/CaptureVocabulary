//
//  ExplainsTextView.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2023/4/29.
//

import UIKit

class TranslateTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        cornerRadius = 5
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
            self.text = await explains.localized()
        }
    }
}
