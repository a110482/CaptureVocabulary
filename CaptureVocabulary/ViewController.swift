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
    private let disposeBag = DisposeBag()
    private let statusLabel = UILabel()
    var coor: Coordinator<UIViewController>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(statusLabel)
        statusLabel.text = "正在初始化"
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
        devPanelButton()
        #endif
        do {
            try SQLCoreMigration.checkVersion(statusLabel: statusLabel) {
                mainCoordinator()
                statusLabel.text = "初始化完成"
                mainCoordinator()
            }
        } catch {
            if let error = error as? SQLCoreMigrationError {
                statusLabel.text = "初始化錯誤: \(error.localizedDescription)"
                #if DEBUG
                showStartManuallyButton()
                #else
                mainCoordinator()
                #endif
            }
        }
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
    
    func showStartManuallyButton() {
        let button = UIButton()
        view.addSubview(button)
        button.setTitle("手動載入", for: .normal)
        button.backgroundColor = .lightGray
        button.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(50)
            $0.centerX.equalTo(statusLabel)
        }
        button.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.mainCoordinator()
        }).disposed(by: disposeBag)
    }
}
#endif

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

/// 版本檢查
func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
    guard let info = Bundle.main.infoDictionary,
        let currentVersion = info["CFBundleShortVersionString"] as? String,
        let identifier = info["CFBundleIdentifier"] as? String,
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
    }
    Log.debug(currentVersion)
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        do {
            if let error = error { throw error }
            guard let data = data else { throw VersionError.invalidResponse }
            let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
            guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                throw VersionError.invalidResponse
            }
            completion(version != currentVersion, nil)
        } catch {
            completion(nil, error)
        }
    }
    task.resume()
    return task
}
