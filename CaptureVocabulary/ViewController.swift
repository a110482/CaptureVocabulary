//
//  ViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/13.
//

import UIKit
import SnapKit
import SwifterSwift
import Vision
import RxCocoa
import RxSwift


class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    var coor: Coordinator<UIViewController>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    // api 測試
    private func demoRequest() {
        typealias Req = AzureDictionary
        let request = Req(queryModel: .init(Text: "immortal"))
        let api = RequestBuilder<Req>()
        api.send(req: request)
        api.result.subscribe(onNext: { res in
            guard let res = res else { return }
            print(res)
        }).disposed(by: disposeBag)
    }
    
    // 相機畫面
    private func testCapture() {
        coor = CaptureVocabularyCoordinator(rootViewController: self)
        coor.start()
    }
    
    // popup 頁面
    private func testPopupPage() {
        coor = CreateVocabularyCoordinator(rootViewController: self, vocabulary: "immortal")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.coor.start()
        }
    }
}

// MARK: -











