//
//  ExplainsTextView.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2023/4/29.
//

import UIKit

class ExplainsTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        cornerRadius = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(model: StringTranslateAPIResponse?) {
        if let explains = model?.basic?.explains {
            let partOfSpeech = explains.map { $0.halfWidth.split(separator: ";") }
            var text = ""
            for speech in partOfSpeech {
                text = speech.reduce(text, {
                    $0 + ($0.isEmpty ? "" : "\n") + String($1).trimmed
                })
                text = (text) + "\n\n"
            }
            Task {
                self.text = await text.localized()
            }
        }
    }
}
