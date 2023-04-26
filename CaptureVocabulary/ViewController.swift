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
        SQLCoreMigration.checkVersion()
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
