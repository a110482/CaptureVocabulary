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
        viewModel.loadStories()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AdsManager.shared.bottomBannerRootViewController = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private let mainStackView = UIStackView()
    private let titleView = TitleView()
    private let tableViewContainer = UIView()
    private let storyTableview = UITableView()
    private var viewModel: MyStoryViewModel!
    private let disposeBag = DisposeBag()
    let placeholder: UIView? = UIView()
}

// MARK: - public functions
extension MyStoryViewController {
    func bind(viewModel: MyStoryViewModel) {
        self.viewModel = viewModel
        bind(needReloadTable: viewModel.output.needReloadTable)
    }
}

extension MyStoryViewController: AdSimpleBannerPowered {

    
}

// MARK: - delegate
extension MyStoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.output.cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.output.cellModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: MyStoryTableViewCell.self)
        cell.bind(cellModel: cellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectedCell(in: indexPath.row)
    }
    
}

// MARK: - private functions
private extension MyStoryViewController {
    func configUI() {
        view.backgroundColor = "F8F7F7".color
        configStackView()
        configTitleView()
        configStoryTableview()
        configBottomPlaceHolder()
    }
    
    func configStackView() {
        view.addSubview(mainStackView)
        mainStackView.axis = .vertical
        mainStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configTitleView() {
        mainStackView.addArrangedSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        titleView.rx.newStoryButtonTap.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            viewModel.tapNewStory()
        }).disposed(by: disposeBag)
    }

    func configStoryTableview() {
        mainStackView.addArrangedSubview(tableViewContainer)
        
        tableViewContainer.addSubview(storyTableview)
        storyTableview.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-48)
            make.center.equalToSuperview()
            make.height.equalToSuperview()
        }
        storyTableview.register(cellWithClass: MyStoryTableViewCell.self)
        storyTableview.delegate = self
        storyTableview.dataSource = self
        storyTableview.separatorStyle = .none
        storyTableview.backgroundColor = .clear
        tableViewContainer.layer.shadowColor = "B8B8D2".color.cgColor
        tableViewContainer.layer.shadowOpacity = 0.2
        tableViewContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        tableViewContainer.layer.shadowRadius = 12
    }
    
    func configBottomPlaceHolder() {
        guard let placeholder else { return }
        mainStackView.addArrangedSubview(placeholder)
        placeholder.snp.makeConstraints { make in
            make.height.equalTo(AdsManager.shared.bottomBannerAdSize.size.height)
        }
    }
    
    func bind(needReloadTable: Observable<Void>) {
        needReloadTable.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            storyTableview.reloadData()
        }).disposed(by: disposeBag)
    }
}

// MARK: - TitleView
private class TitleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([titleLabel, newStoryButton])
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleLabel.text = NSLocalizedString("TabBarCoordinator.myStory", comment: "我的故事")
        titleLabel.textColor = "353535".color
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        
        
        newStoryButton.setTitle(NSLocalizedString("MyStoryViewController.newStory", comment: "新故事"), for: .normal)
        newStoryButton.setTitleColor("3D5CFF".color, for: .normal)
        newStoryButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        newStoryButton.snp.makeConstraints { make in
            make.right.equalTo(-20)
        }
        newStoryButton.titleLabel?.snp.makeConstraints({ make in
            make.bottom.equalTo(titleLabel)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    fileprivate let newStoryButton = UIButton()
    private let titleLabel = UILabel()
    
    private func tap() {
        
    }
}

private extension Reactive where Base: TitleView {
    var newStoryButtonTap: ControlEvent<Void> {
        return base.newStoryButton.rx.tap
    }
}
