//
//  SettingPageViewModel.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/22.
//

import RxSwift
import RxCocoa

class SettingPageViewModel {
    private(set) var output = Output()
    struct Output {
        fileprivate let _sectionModels = BehaviorRelay<Array<SettingTableViewSectionModel>>(value: [])
        var sectionModels: Driver<Array<SettingTableViewSectionModel>> { _sectionModels.asDriver() }
    }
    
    init() {
        output._sectionModels.accept([
            readingSectionCellModels()
        ])
    }
}

private extension SettingPageViewModel {
    /// 閱讀相關設定
    func readingSectionCellModels() -> SettingTableViewSectionModel {
        let readingModels = [SettingReadingCellModel()]
        let sectionModel = SettingTableViewSectionModel(
            title: NSLocalizedString("SettingPageViewController.section.reading", comment: "阅读"),
            cellModels: readingModels)
        return sectionModel
    }
}
