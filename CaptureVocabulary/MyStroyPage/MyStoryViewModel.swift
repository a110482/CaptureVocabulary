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
    private var cellModels :[MyStoryTableViewCellModel] = []
    private let needReloadTable = PublishRelay<Void>()
}

extension MyStoryViewModel {
    class Output: RxOutput<MyStoryViewModel> {
        var action: Observable<Action> {
            target.action.asObservable()
        }
        
        var cellModels: [MyStoryTableViewCellModel] {
            target.cellModels
        }
        
        var needReloadTable: Observable<Void> {
            target.needReloadTable.asObservable()
        }
    }
    
    enum Action {
        case newStory
        case selected(cellModel: MyStoryTableViewCellModel)
    }
    
    /// 點擊 "新故事" 按鈕
    func tapNewStory() {
        action.accept(.newStory)
    }
    
    /// 刷新資料
    func loadStories() {
        guard let stories = StoryORM.ORM.getAllStory() else { return }
        cellModels = stories.compactMap({ MyStoryTableViewCellModel(orm: $0) })
        needReloadTable.accept(())
    }
    
    func didSelectedCell(in index: Int) {
        action.accept(.selected(cellModel: cellModels[index]))
    }
}

private extension MyStoryViewModel {
    
}

