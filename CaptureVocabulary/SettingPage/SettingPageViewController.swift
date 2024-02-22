//
//  SettingPageViewController.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/22.
//

import UIKit

class SettingPageViewController: UIViewController {
    private let tableView = UITableView()
    
    private var viewModel: SettingPageViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func bind(viewModel: SettingPageViewModel) {
        self.viewModel = viewModel
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
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SettingPageViewController: UITableViewDelegate, UITableViewDataSource {
    private var cellModels: Array<String> {
        viewModel?.output.cellModels.value ?? []
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = cellModels[indexPath.row]
        return cell
    }
}
