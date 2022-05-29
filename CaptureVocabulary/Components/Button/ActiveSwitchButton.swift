//
//  ActiveSwitchButton.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/29.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift

class ActiveSwitchButton: UIButton {
    private var active = true
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configUI()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setActive(_ value: Bool) {
        active = value
        updateUI()
    }
}

private extension ActiveSwitchButton {
    func configUI() {
        
    }
    
    func updateUI() {
        if active {
            layoutActiveStyle()
        } else {
            layoutInactiveStyle()
        }
    }
    
    func layoutActiveStyle() {
        backgroundColor = .white
        setTitleColor(.black, for: .normal)
    }
    
    func layoutInactiveStyle() {
        backgroundColor = .darkGray
        setTitleColor(.gray, for: .normal)
    }
}
