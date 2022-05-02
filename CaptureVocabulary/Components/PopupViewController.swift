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
        addBackgroundGesture()
    }
    
    func pop(viewController vc: UIViewController, constrains: ((ConstraintMaker) -> Void)? = nil) {
        addChildViewController(vc, toContainerView: view)
        guard let v = vc.view else { return }
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
        let back = UIView()
        back.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(back)
        back.snp.makeConstraints { $0.edges.equalToSuperview() }
        back.addGestureRecognizer(ges)
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
