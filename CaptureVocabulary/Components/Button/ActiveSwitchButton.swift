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
    private var active = false
    
    private let starFill = UIImage(named: "StarFill")
    
    private let starWire = UIImage(named: "StarWire")
    
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
        setImage(starWire, for: .normal)
    }
    
    func updateUI() {
        if active {
            setImage(starWire, for: .normal)
        } else {
            setImage(starFill, for: .normal)
        }
    }
}
