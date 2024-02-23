//
//  SettingReadingCell.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/23.
//

import UIKit
import RxSwift
import RxCocoa

class SettingReadingCell: UITableViewCell, SettingPageCellProtocol {
    static let type: SettingPageCellType = .readingSpeed
    
    private let mainStackView = UIStackView()
    private let titleLabel = UILabel()
    private let slider = UISlider()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    func config(cellModel: any SettingPageCellModelProtocol) {
        guard let cellModel = cellModel as? SettingReadingCellModel else {
            return
        }
    }
}

// UI
private extension SettingReadingCell {
    func configUI() {
        contentView.addSubview(mainStackView)
        configStackView()
        mainStackView.addArrangedSubviews([
            mainStackView.padding(gap: 20),
            titleLabel,
            mainStackView.padding(gap: 50),
            slider,
            mainStackView.padding(gap: 20)
        ])
        
        configTitleLabel()
    }
    
    func configStackView() {
        mainStackView.axis = .horizontal
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
    
    func configTitleLabel() {
        titleLabel.text = "閱讀速度"
    }
}

// ==
struct SettingReadingCellModel: SettingPageCellModelProtocol {
    let type: SettingPageCellType = .readingSpeed
    private var _speed = BehaviorRelay(value: 0)
    var speed: Driver<Int> { _speed.asDriver() }
    let maxSpeed = 150
    let minSpeed = 50
    
    init() {
        _speed.accept(50) // read from user default
    }
}
