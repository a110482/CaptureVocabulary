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
        #if DEBUG
//        SQLCore.shared.dropTables()
        #endif
        sql()
        mainCoordinator()
    }
    
    // SQLite
    private func sql() {
        SQLCore.shared.createTables()
    }
    
    private func mainCoordinator() {
        coor = TabBarCoordinator(rootViewController: self)
        coor.start()
    }
}


public func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    let output = items.map { "*\($0)" }.joined(separator: separator)
    if output.contains("CREATE TABLE IF NOT EXISTS") {
        print("stop")
    }
    Swift.print(output, terminator: terminator)
}

