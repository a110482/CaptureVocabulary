//
//  DatabaseBackupViewModel.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/26.
//

import UIKit
import RxSwift
import RxCocoa

class DatabaseBackupViewModel: NSObject {
    private(set) lazy var output = Output(self)
    
    private let importDatabaseStatus = BehaviorRelay<ImportDatabaseStatus>(value: .none)
    private var confirmImportDatabaseCode: String = ""
}

extension DatabaseBackupViewModel {
    class Output: RxOutput<DatabaseBackupViewModel> {
        var importDatabaseStatus: Observable<ImportDatabaseStatus> {
            target.importDatabaseStatus.asObservable()
        }
    }
    
    func didTapImportDatabaseButton() {
        confirmImportDatabaseCode = generateConfirmCode()
        importDatabaseStatus.accept(.popWarning(confirmCode: confirmImportDatabaseCode))
    }
    
    func cancelConfirmAlert() {
        importDatabaseStatus.accept(.none)
    }
    
    func verifyConfirmCode(code: String) {
        if code.uppercased() == confirmImportDatabaseCode {
            importDatabaseStatus.accept(.selectFile)
        } else {
            importDatabaseStatus.accept(.popConfirmCodeError(confirmCode: confirmImportDatabaseCode))
        }
    }
}

private extension DatabaseBackupViewModel {
    /// 移動檔案
    func moveFile(from sourceURL: URL, to destinationURL: URL) {
        let fileManager = FileManager.default
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                // 若目標檔案已存在，先刪除
                try fileManager.removeItem(at: destinationURL)
            }
            let res = sourceURL.startAccessingSecurityScopedResource()
            Log.debug(res)
            // 將檔案移動到目標位置
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            Log.debug("File moved to: \(destinationURL.path)")
            sourceURL.stopAccessingSecurityScopedResource()
        } catch {
            Log.debug("Error moving file: \(error.localizedDescription)")
        }
    }
    
    /// 產生驗證碼
    func generateConfirmCode() -> String {
        // 去除 i 0 o 等易混淆的文字
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let digits = "23456789"
        let characters = letters + digits
        
        var code = ""
        
        for _ in 0..<4 {
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            let randomCharacter = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            code.append(randomCharacter)
        }
        return code
    }
}

extension DatabaseBackupViewModel: UIDocumentPickerDelegate {
    // UIDocumentPickerDelegate 方法：檔案選取後回調
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        // 目標路徑
        let destinationURL = SQLCore.groupDatabaseURL
        
        // 移動檔案到指定位置
        moveFile(from: selectedFileURL, to: destinationURL)
        
        SQLCore.reconnectSQL()
        
        importDatabaseStatus.accept(.complete)
    }
}

extension DatabaseBackupViewModel {
    enum ImportDatabaseStatus {
        case none
        case popWarning(confirmCode: String)
        case popConfirmCodeError(confirmCode: String)
        case selectFile
        case complete
    }
}
