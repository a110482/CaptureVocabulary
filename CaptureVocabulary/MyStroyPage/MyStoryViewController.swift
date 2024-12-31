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
    
    private let newStoryButton = UIButton()
    private let titleLabel = UILabel()
    private let storyTableview = UITableView()
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
        configTitleLabel()
        configNewStoryButton()
        configStoryTableview()
        #if DEBUG
        newStoryButton.backgroundColor = .red
        newStoryButton.setTitle("New Story", for: .normal)
        storyTableview.backgroundColor = .blue
        #endif
    }
    
    func configTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = NSLocalizedString("TabBarCoordinator.myStory", comment: "我的故事")
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    func configNewStoryButton() {
        view.addSubview(newStoryButton)
        newStoryButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.right.equalTo(-20)
        }
    }

    func configStoryTableview() {
        view.addSubview(storyTableview)
        storyTableview.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

