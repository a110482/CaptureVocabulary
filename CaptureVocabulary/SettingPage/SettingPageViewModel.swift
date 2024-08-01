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
        #if DEBUG
        let readingModels = [SettingReadingCellModel()]
        output._sectionModels.accept([
            SettingTableViewSectionModel(
                title: NSLocalizedString("SettingPageViewController.section.reading", comment: "阅读"),
                cellModels: readingModels)
        ])
        
        
//        output.cellModels.accept(["reading", "autoReview", "debug"])
        #endif
    }
}
