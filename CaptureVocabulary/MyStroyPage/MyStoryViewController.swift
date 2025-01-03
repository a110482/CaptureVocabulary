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
    private var viewModel: MyStoryViewModel!
    private let disposeBag = DisposeBag()
}

// MARK: - public functions
extension MyStoryViewController {
    func bind(viewModel: MyStoryViewModel) {
        self.viewModel = viewModel
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
        
        newStoryButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            viewModel.tapNewStory()
        }).disposed(by: disposeBag)
    }

    func configStoryTableview() {
        view.addSubview(storyTableview)
        storyTableview.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

