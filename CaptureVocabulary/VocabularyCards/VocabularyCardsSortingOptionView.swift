//
//  VocabularyCardsSortingOptionView.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import UIKit

class VocabularyCardsSortingOptionView: SegmentedOptionView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func updateUI() {
        super.updateUI()
        titleLabel.textColor = isSelected ? "353535".uicolor : "C4C9D3".uicolor
        updateIcon()
    }
    
    private let mainStackView = UIStackView()
    private let titleLabel = UILabel()
    private let icon = UIImageView()
    private var filterOption: VocabularyCardsSortingOption?
}

extension VocabularyCardsSortingOptionView {
    func config(filterOption: VocabularyCardsSortingOption) {
        titleLabel.text = filterOption.title
        self.filterOption = filterOption
    }
}

private extension VocabularyCardsSortingOptionView {
    func configUI () {
        backgroundColor = .clear
        addSubview(mainStackView)
        mainStackView.axis = .horizontal
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        mainStackView.addArrangedSubviews([
            titleLabel,
            icon
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        titleLabel.textAlignment = .center
        
        icon.snp.makeConstraints { make in
            make.size.equalTo(14)
        }
    }
    
    func updateIcon() {
        guard let filterOption else { return }
        if isSelected {
            icon.image = filterOption.image?.withRenderingMode(.alwaysOriginal)
        } else {
            icon.image = filterOption.image?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = "C4C9D3".uicolor
        }
        if case .time(let sortingType) = filterOption {
            icon.isHidden = false
            switch sortingType {
            case .ascending:
                icon.transform = .identity
            case .descending:
                icon.transform = CGAffineTransform(rotationAngle: .pi)
            }
        } else {
            icon.isHidden = true
        }
    }
}

/// 過濾器選項
enum VocabularyCardsSortingOption: FuzzyEquatable {
    enum SortingType {
        case ascending
        case descending
    }
    case star
    case time(sortingType: SortingType)
    case prefixLetter(sortingType: SortingType)
    
    var title: String {
        switch self {
        case .star:
            return NSLocalizedString("VocabularyCardsSortingOptionView.star", comment: "星號")
        case .time(_):
            return NSLocalizedString("VocabularyCardsSortingOptionView.time", comment: "時間")
        case .prefixLetter(let sortingType):
            if sortingType == .ascending {
                return "A-Z"
            } else {
                return "Z-A"
            }
        }
    }
    
    var image: UIImage? {
        switch self {
        case .time(_) :
            return UIImage(named: "arrow-up-down")
        default:
            return nil
        }
    }
    
    mutating func toggleSortingType() {
        switch self {
        case .star:
            return
        case .time(let sortingType):
            self = .time(sortingType: sortingType == .ascending ? .descending : .ascending)
        case .prefixLetter(let sortingType):
            self = .prefixLetter(sortingType: sortingType == .ascending ? .descending : .ascending)
        }
    }
}
