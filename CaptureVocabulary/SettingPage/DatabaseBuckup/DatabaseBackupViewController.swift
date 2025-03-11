//
//  DatabaseBackupViewController.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/26.
//

import UIKit
import RxSwift
import RxCocoa

class DatabaseBackupViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    private var viewModel: DatabaseBackupViewModel!
    private let warningIcon = UIImageView()
    private let infoLabel = UILabel()
    private let exportButton = UIButton()
    private let importButton = UIButton()
    private let disposeBag = DisposeBag()
}

// MARK: - public functions
extension DatabaseBackupViewController {
    func bind(viewModel: DatabaseBackupViewModel) {
        self.viewModel = viewModel
        viewModel.output.importDatabaseStatus.subscribe(onNext: { [weak self] status in
            guard let self else { return }
            handleImportDatabase(status: status)
        }).disposed(by: disposeBag)
    }
}

// MARK: - private functions
private extension DatabaseBackupViewController {
    func configUI() {
        view.backgroundColor = UIColor(hexString: "F8F7F7")
        configWarningIcon()
        configInfoLabel()
        configImportButton()
        configExportButton()
    }
    
    func configWarningIcon() {
        warningIcon.image = UIImage(systemName: "exclamationmark.triangle")?.withRenderingMode(.alwaysTemplate)
        warningIcon.tintColor = .red
        warningIcon.contentMode = .scaleAspectFit
        
        view.addSubview(warningIcon)
        warningIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.size.equalTo(100)
        }
    }
    
    func configInfoLabel() {
        view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(warningIcon.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(50)
        }
        infoLabel.numberOfLines = 0
        infoLabel.text = NSLocalizedString("DatabaseBackupViewController.warningMessage",
                                           comment: "備份檔案警告內容")
        infoLabel.textAlignment = .center
    }
    
    func configImportButton() {
        view.addSubview(importButton)
        importButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-150)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
        }
        let title = NSLocalizedString("DatabaseBackupViewController.importDatabase", comment: "導入資料庫")
        importButton.setTitle(title, for: .normal)
        importButton.backgroundColor = .red.withAlphaComponent(0.7)
        importButton.layer.cornerRadius = 12
        importButton.addTarget(self, action: #selector(tapImportButton), for: .touchUpInside)
    }
    
    func configExportButton() {
        view.addSubview(exportButton)
        exportButton.snp.makeConstraints { make in
            make.bottom.equalTo(importButton.snp.top).offset(-30)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
        }
        exportButton.backgroundColor = UIColor(hexString: "3D5CFF")
        exportButton.setTitleColor(.white, for: .normal)
        exportButton.layer.cornerRadius = 12
        let title = NSLocalizedString("DatabaseBackupViewController.exportDatabase", comment: "導出資料庫")
        exportButton.setTitle(title, for: .normal)
        exportButton.addTarget(self, action: #selector(tapExportButton), for: .touchUpInside)
    }
    
    @objc func tapExportButton() {
        let fileURL = SQLCore.groupDatabaseURL
        
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        // 避免在 iPad 上崩潰，設置 popoverPresentationController
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = exportButton
            popoverController.sourceRect = exportButton.bounds
        }
        
        // 顯示 UIActivityViewController
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func tapImportButton() {
        viewModel.didTapImportDatabaseButton()
    }
}

/// 處理導入資料庫相關畫面
private extension DatabaseBackupViewController {
    func handleImportDatabase(status: DatabaseBackupViewModel.ImportDatabaseStatus) {
        switch status {
        case.none:
            break
        case .popWarning(let confirmCode):
            let text = NSLocalizedString("DatabaseBackupViewController.confirmWarningTitle", comment: "警告，即将覆盖目前的资料")
            popConfirmAlert(code: confirmCode, titleText: text)
        case .popConfirmCodeError(let confirmCode):
            let text = NSLocalizedString("DatabaseBackupViewController.confirmCodeError", comment: "验证码错误，请输入验证码")
            popConfirmAlert(code: confirmCode, titleText: text)
        case .selectFile:
            presentDocumentPicker()
        case .complete:
            popCompleteAlert()
        case .failure:
            popFailureAlert()
        }
    }
    
    /// 輸入驗證碼確認複寫資料庫
    func popConfirmAlert(code: String ,titleText: String) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertVC.title = String(format: titleText, code)
        alertVC.addTextField()
        
        let cancel = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.cancel",
                                                            comment: "取消"), style: .default) { [weak self] _ in
            guard let self else { return }
            viewModel.cancelConfirmAlert()
        }
        
        let ok = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.confirm", comment: "確認"),
                               style: .default) { [weak self] _ in
            guard let self else { return }
            let code = alertVC.textFields?.first?.text ?? ""
            viewModel.verifyConfirmCode(code: code)
        }
        ok.setValue(UIColor.red, forKey: "titleTextColor")
        
        alertVC.addAction(cancel)
        alertVC.addAction(ok)
        present(alertVC, animated: true)
    }
    
    /// 資料庫複寫完成
    func popCompleteAlert() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let text = NSLocalizedString("DatabaseBackupViewController.writeDatabaseSuccess", comment: "资料库覆盖完成")
        alertVC.title = text
        
        let ok = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.confirm", comment: "確認"),
                               style: .default) { [weak self] _ in
            guard let self else { return }
            viewModel.cancelConfirmAlert()
        }
        alertVC.addAction(ok)
        present(alertVC, animated: true)
    }
    
    func popFailureAlert() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let text = NSLocalizedString("DatabaseBackupViewController.writeDatabaseFailure", comment: "资料库覆盖失敗")
        alertVC.title = text
        
        let ok = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.confirm", comment: "確認"),
                               style: .default) { [weak self] _ in
            guard let self else { return }
            viewModel.cancelConfirmAlert()
        }
        alertVC.addAction(ok)
        present(alertVC, animated: true)
    }
    
    /// 呼叫此方法開啟檔案選擇器
    func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = viewModel
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }
}
