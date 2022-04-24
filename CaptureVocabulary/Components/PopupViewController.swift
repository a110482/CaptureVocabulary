//
//  PopupViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

protocol PopupViewControllerDelegate: AnyObject {
    func tapBackground()
}

class PopupViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    weak var delegate: PopupViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        addBackgroundGesture()
    }
    
    func pop(view v: UIView, constrains: ((ConstraintMaker) -> Void)? = nil) {
        view.addSubview(v)
        if let constrains = constrains {
            v.snp.makeConstraints(constrains)
        } else {
            v.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.8)
                $0.center.equalToSuperview()
            }
        }
    }
    
    private func addBackgroundGesture() {
        let ges = UITapGestureRecognizer()
        view.addGestureRecognizer(ges)
        ges.rx.event.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            if event.state == .recognized {
                if let delegate = self.delegate {
                    delegate.tapBackground()
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }).disposed(by: disposeBag)
    }
}
