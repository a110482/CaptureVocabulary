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
//        testCapture()
        test()
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
    
    // SQLite
    private func sql() {
//        SQLCore.shared.dropTables()
        SQLCore.shared.createTables()
        #if DEBUG
//        let _ = VocabularyCardListORM.ORM.newList()
//
//        var orm = VocabularyCardORM.ORM()
//        orm.groupId = 1
//        for index in 0 ..< 10 {
//            orm.normalizedSource = "hello_\(index)"
//            orm.normalizedTarget = "哈樓_\(index)"
//
//            VocabularyCardORM.create(orm)
//        }
//        VocabularyCardORM.ORM.get(by: 3)
        #endif
        
        
        
    }
    
    // test
    private func test() {
//        coor = TabBarCoordinator(rootViewController: self)
//        coor.start()
        
        typealias Req = StringTranslateAPI
        let request = Req()
        let api = RequestBuilder<Req>()
        api.send(req: request)
    }
}


