//
//  MyStoryViewModel.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/31.
//

import Foundation
import RxSwift
import RxCocoa

class MyStoryViewModel {
    private(set) lazy var output = Output(self)
    
    private let action = PublishRelay<Action>()
}

extension MyStoryViewModel {
    class Output: RxOutput<MyStoryViewModel> {
        var action: Observable<Action> {
            target.action.asObservable()
        }
    }
    
    enum Action {
        case newStory
    }
    
    /// 點擊 "新故事" 按鈕
    func tapNewStory() {
        action.accept(.newStory)
    }
}

private extension MyStoryViewModel {
    
}

