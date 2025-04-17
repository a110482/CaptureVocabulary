//
//  SegmentedOptionView.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/2.
//

import UIKit
import RxSwift
import RxCocoa


protocol SegmentedOptionViewDelegate: AnyObject {
    func selectSegmentedOptionView(_ view: SegmentedOptionView)
}

class SegmentedOptionView: UIView {
    weak var delegate: SegmentedOptionViewDelegate?
    var isSelected: Bool = false { didSet { updateUI() }}
    
    override init(frame: CGRect) {
        _configuration = SegmentedViewConfiguration()
        super.init(frame: frame)
        bindConfiguration()
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI() {
        backgroundColor = isSelected ? _configuration.selectedOptionsColor : _configuration.defaultOptionsColor
    }
    
    private var _configuration: SegmentedViewConfiguration
    private var configurationDisposeBag = DisposeBag()
}

extension SegmentedOptionView {
    var configuration: SegmentedViewConfiguration {
        get { _configuration }
        set {
            _configuration = newValue
            bindConfiguration()
            updateUI()
        }
    }
}

private extension SegmentedOptionView {
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }
    
    @objc func didTap() {
        delegate?.selectSegmentedOptionView(self)
    }
    
    func bindConfiguration() {
        configurationDisposeBag = DisposeBag()
        _configuration.configChanged
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                updateUI()
            })
            .disposed(by: configurationDisposeBag)
    }
}


