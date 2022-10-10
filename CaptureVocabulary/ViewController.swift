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
import SQLite

struct User: Codable {
    let name: String?
    let id: Int64
    let email: String
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    var coor: Coordinator<UIViewController>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sql()
        mainCoordinator()
//        test()
    }
    
    // SQLite
    private func sql() {
        SQLCore.shared.createTables()
    }
    
    private func mainCoordinator() {
        coor = TabBarCoordinator(rootViewController: self)
        coor.start()
    }
    
    private func test() {
        let queryModel = YDTranslateAPIQueryModel(queryString: "test")
        let api = YDTranslateAPI(queryModel: queryModel)
        let req = RequestBuilder<YDTranslateAPI>()

        req.result.subscribe(onNext: { [weak self] res in
            guard let self = self else { return }
            res?.create(nil)
            print("save responde")
        }).disposed(by: disposeBag)

        if let res = YDTranslateAPI.ResponseModel.load(queryModel: queryModel) {
            print(res)
        } else {
            req.send(req: api)
        }
    }
}




