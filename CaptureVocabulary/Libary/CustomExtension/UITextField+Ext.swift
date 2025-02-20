//
//  UITextField+Ext.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/28.
//

import UIKit
import RxSwift

private let closeGestureView = CloseGestureView()

extension UITextFieldDelegate where Self: UIViewController {
    /// 新增手勢, 點背景收鍵盤
    func addBackgroundCloseView(_ textField: UITextField,
                                disposeBag: DisposeBag,
                                action: (() -> Void)? = nil) {
        closeGestureView.backgroundColor = .clear
        closeGestureView.textField = textField
        view.addSubview(closeGestureView)
        closeGestureView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        let gesture = UITapGestureRecognizer()
        closeGestureView.addGestureRecognizer(gesture)
        gesture.rx.event.subscribe(onNext: { event in
            guard event.state == .ended else { return }
            closeGestureView.removeFromSuperview()
            textField.resignFirstResponder()
            action?()
        }).disposed(by: disposeBag)
    }
    
    func removeBackgroundCloseView() {
        closeGestureView.removeFromSuperview()
    }
}

private class CloseGestureView: UIView {
    weak var textField: UITextField?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let defaultResult = super.hitTest(point, with: event)
        guard let textField = textField else { return defaultResult }
        let convertTextFieldPoint = textField.convert(point, from: self)
        if textField.bounds.contains(convertTextFieldPoint) {
            return nil
        }
        return defaultResult
    }
}
