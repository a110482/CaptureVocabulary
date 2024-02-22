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
        let cellModels = BehaviorRelay<Array<String>>(value: [])
    }
    
    init() {
        #if DEBUG
        output.cellModels.accept(["reading", "autoReview", "debug"])
        #endif
    }
}
