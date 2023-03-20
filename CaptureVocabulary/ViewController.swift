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
        devPanelButton()
        #endif
        createDefaultList()
        mainCoordinator()
    }
    
    // SQLite
    private func createDefaultList() {
        SQLCore.shared.createTables()
        VocabularyCardListORM.ORM.createDefaultList()
    }
    
    private func mainCoordinator() {
        coor = TabBarCoordinator(rootViewController: self)
        coor.start()
    }
}

#if DEBUG
private extension ViewController {
    func devPanelButton() {
        let btn = UIButton()
        view.addSubview(btn)
        btn.snp.makeConstraints {
            $0.size.equalTo(100)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(100)
        }
        btn.backgroundColor = .gray
        btn.setTitle("DevPanel", for: .normal)
        
        btn.rx.tap.subscribe(onNext: {
            let vc = DevPanelViewController()
            self.present(vc, animated: true)
        }).disposed(by: disposeBag)
    }
}
#endif
