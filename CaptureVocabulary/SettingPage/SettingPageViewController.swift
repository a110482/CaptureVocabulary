//
//  SettingPageViewController.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/22.
//

import UIKit
import RxSwift
import RxCocoa

class SettingPageViewController: UIViewController {
    private let tableView = UITableView()
    private var viewModel: SettingPageViewModel?
    private var sectionModels: Array<SettingTableViewSectionModel> = []
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func bind(viewModel: SettingPageViewModel) {
        self.viewModel = viewModel
        viewModel.output.sectionModels.drive(onNext: {[weak self] value in
            guard let self else { return }
            self.sectionModels = value
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}

// UI
private extension SettingPageViewController {
    func configUI() {
        view.addSubview(tableView)
        configTableView()
        
    }
    
    func configTableView() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.register(SettingReadingCell.self, forCellReuseIdentifier: SettingReadingCell.type.rawValue)
        tableView.register(headerFooterViewClassWith: SettingSectionHeader.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }
}

extension SettingPageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].cellModels.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withClass: SettingSectionHeader.self)
        sectionHeader.titleLabel.text = sectionModels[section].title
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = sectionModels[indexPath.section].cellModels[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.type.rawValue) as? SettingPageCellProtocol else {
            assert(false)
            return UITableViewCell()
        }
        cell.config(cellModel: cellModel)
        return cell
    }
}
