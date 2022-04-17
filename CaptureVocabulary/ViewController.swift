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
    var createVocabularyCoordinator: CreateVocabularyCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createVocabularyCoordinator = CreateVocabularyCoordinator(rootViewController: self)
        createVocabularyCoordinator.start()
    }
}

