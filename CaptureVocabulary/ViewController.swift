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
    var createVocabularyCoordinator: CaptureVocabularyCoordinator!
    let disposeBag = DisposeBag()
    var coor: CreateVocabularyCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        createVocabularyCoordinator = CaptureVocabularyCoordinator(rootViewController: self)
//        createVocabularyCoordinator.start()
        coor = CreateVocabularyCoordinator(rootViewController: self, vocabulary: "hello")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.coor.start()
        }
    }
    
    private func demoRequest() {
        typealias Req = AzureDictionary
        let request = Req(queryModel: .init(Text: "fly"))
        let api = RequestBuilder<Req>()
        api.send(req: request)
        api.result.subscribe(onNext: { res in
            guard let res = res else { return }
            print(res)
        }).disposed(by: disposeBag)
    }
}

// MARK: -











