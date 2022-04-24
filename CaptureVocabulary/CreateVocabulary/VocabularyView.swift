//
//  VocabularyView.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

struct VocabularyViewModel {
    struct Inout {
        let vocabulary = BehaviorRelay<String?>(value: nil)
        let translate = BehaviorRelay<String?>(value: nil)
    }
    let `inout` = Inout()
    
    init(vocabulary: String) {
        `inout`.vocabulary.accept(vocabulary)
    }
    
    // 等按 return 再查詢, 不然流量太兇～
    func sentQueryRequest() {
        
    }
}

class VocabularyView: UIView {
    private let mainStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 10
    }
    private let sourceTextField = UITextField()
    private let translateTextField = UITextField()
    
    private let disposeBag = DisposeBag()
    init() {
        super.init(frame: .zero)
        let emptyGesture = UITapGestureRecognizer()
        addGestureRecognizer(emptyGesture)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: VocabularyViewModel) {
        sourceTextField.text = viewModel.inout.vocabulary.value
        sourceTextField.rx.text.bind(to: viewModel.inout.vocabulary).disposed(by: disposeBag)
        
        viewModel.inout.translate.bind(to: translateTextField.rx.text).disposed(by: disposeBag)
        translateTextField.rx.text.bind(to: viewModel.inout.translate).disposed(by: disposeBag)
    }
    
    private func configUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = true
        addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview()
            $0.top.equalTo(10)
        }
        
        let separateLine = UIView().then {
            $0.backgroundColor = .black
        }
        
        mainStack.addArrangedSubviews([
            sourceTextField,
            separateLine,
            translateTextField
        ])
        
        separateLine.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(1)
        }
        [sourceTextField, translateTextField].forEach {
            $0.snp.makeConstraints { view in
                view.width.equalToSuperview()
            }
            $0.backgroundColor = .random
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 25)
        }
    }
}
