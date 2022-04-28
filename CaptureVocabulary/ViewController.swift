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
        view.backgroundColor = .orange
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        let db = try! Connection("\(path)/db.sqlite3")
        
        // User table
        let users = Table("users")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String>("email")
        
        try! db.run(users.create(ifNotExists: true) { t in     // CREATE TABLE "users" (
            t.column(id, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
            t.column(email, unique: true)  //     "email" TEXT UNIQUE NOT NULL,
            t.column(name)                 //     "name" TEXT
        })
        
        let loadedUsers: [User] = try! db.prepare(users).map { row in
            return try row.decode()
        }
        print(loadedUsers)
        
        (try? db.prepare(users))?.forEach { print($0) }
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











