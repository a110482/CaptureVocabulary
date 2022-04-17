//
//  CreateVocabularyCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/18.
//

import UIKit
import SnapKit
import SwifterSwift
import Vision
import RxCocoa
import RxSwift

class CreateVocabularyCoordinator: Coordinator<UIViewController> {
    override func start() {
        guard !started else { return }
        super.start()
        let vc = CreateVocabularyViewController()
        present(viewController: vc)
    }
}

class CreateVocabularyViewController: UIViewController {
    let cap = CaptureViewController()
    let capContainerView = UIView()
    private let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(capContainerView)
        capContainerView.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.left.equalTo(20)
            $0.height.equalTo(300)
        }
        
        addChildViewController(cap, toContainerView: capContainerView)
        cap.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        cap.action.subscribe(onNext: { act in
            switch act {
            case .identifyText(let observations):
                break
            }
        }).disposed(by: disposeBag)
    }
}
