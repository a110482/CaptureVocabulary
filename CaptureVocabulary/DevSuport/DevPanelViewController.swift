//
//  DevPanelViewController.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/20.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class DevPanelViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let mainStack = UIStackView().then {
        $0.axis = .vertical
    }
    private let resetDatabase = UIButton().then {
        $0.setTitle("resetDatabase", for: .normal)
    }
    private let mockWords = UIButton().then {
        $0.setTitle("mockVocabularyCard", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mainStack)
        mainStack.spacing = 10
        mainStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainStack.addArrangedSubviews([
            resetDatabase,
            mockWords,
            UIView()
        ])
        mainStack.arrangedSubviews.forEach {
            $0.backgroundColor = .gray
        }
        actions()
    }
    
    private func actions() {
        resetDatabase.rx.tap.subscribe(onNext: {
            SQLCore.shared.dropTables()
            SQLCore.shared.createTables()
            VocabularyCardListORM.ORM.createDefaultList()
            Log.debug("tap resetDatabase")
        }).disposed(by: disposeBag)
        
        mockWords.rx.tap.subscribe(onNext: {
            MockWords.makeDataBaseData()
            Log.debug("tap mockWords")
        }).disposed(by: disposeBag)
    }
}
