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
        test()
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
        SQLCore.shared.createTables()
    }
    
    // test
    private func test() {
        coor = TabBarCoordinator(rootViewController: self)
        coor.start()
    }
}


