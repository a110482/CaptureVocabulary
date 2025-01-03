//
//  StoryGeneratorOptionView.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import UIKit

class StoryGeneratorOptionView: SegmentedOptionView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func updateUI() {
        super.updateUI()
    }
    
    private let titleLabel = UILabel()
}

extension StoryGeneratorOptionView {
    func config(title: String, isSelected: Bool) {
        titleLabel.text = title
        backgroundColor = isSelected ? .yellow : .gray
    }
}

private extension StoryGeneratorOptionView {
    func configUI () {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(40)
        }
    }
}
