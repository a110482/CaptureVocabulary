//
//  MyStoryViewController.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/31.
//

import UIKit
import RxSwift
import RxCocoa

class MyStoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
}

// MARK: - public functions
extension MyStoryViewController {
    func bind(viewModel: MyStoryViewModel) {
        
    }
}

// MARK: - private functions
private extension MyStoryViewController {
    func configUI() {
        view.backgroundColor = .lightGray
    }
}

