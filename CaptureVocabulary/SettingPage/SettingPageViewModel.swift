//
//  SettingPageViewModel.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/22.
//

import RxSwift
import RxCocoa

class SettingPageViewModel {
    private(set) lazy var output = Output(self)
    
    init() {
        sectionModels.accept([
            readingSectionCellModels()
        ])
        bindDatabaseBackupModel()
    }
    
    private let databaseBackupModel = MoreSettingCellModel(moreSettingType: .databaseBackup)
    private let sectionModels = BehaviorRelay<Array<SettingTableViewSectionModel>>(value: [])
    private let disposeBag = DisposeBag()
    private let action = PublishRelay<Action>()
}

// MARK: - public functions
extension SettingPageViewModel {
    class Output: RxOutput<SettingPageViewModel> {
        var sectionModels: Driver<Array<SettingTableViewSectionModel>> {
            target.sectionModels.asDriver()
        }
        
        var action: Observable<Action> {
            target.action.asObservable()
        }
    }
    
    enum MoreSettingType {
        case databaseBackup
        
        var title: String {
            switch self {
            case.databaseBackup:
                return NSLocalizedString("SettingPageViewController.cell.databaseBackup",
                                         comment: "備份資料庫")
            }
        }
    }
    
    enum Action {
        case tapMoreSetting(type: MoreSettingType)
    }
}

// MARK: - private functions
private extension SettingPageViewModel {
    /// 閱讀相關設定
    func readingSectionCellModels() -> SettingTableViewSectionModel {
        let readingModels: [SettingPageCellModelProtocol] = [
            SettingReadingCellModel(),
            SettingSwitchSentenceCellModel(),
            databaseBackupModel,
            VersionNumberCellModel()
        ]
        
        let sectionModel = SettingTableViewSectionModel(
            title: NSLocalizedString("SettingPageViewController.section.reading", comment: "阅读"),
            cellModels: readingModels)
        return sectionModel
    }
    
    func bindDatabaseBackupModel() {
        databaseBackupModel.output.tapCellEVent
            .map({ Action.tapMoreSetting(type: .databaseBackup) })
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
