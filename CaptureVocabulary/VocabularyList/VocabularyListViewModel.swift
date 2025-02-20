//
//  VocabularyListViewModel.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/10.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift


class VocabularyListViewModel {
    private(set) lazy var output = Output(self)
    
    init() {
        loadList()
    }
    
    private let cardListModels = BehaviorRelay<[VocabularyCardListORM.ORM]>(value: [])
    private let newVocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
    private let showCreateNewListNameAlert = PublishRelay<Void>()
    private let needReloadTableview = PublishRelay<Void>()
}

extension VocabularyListViewModel {
    class Output: RxOutput<VocabularyListViewModel> {
        var cardListModels: Observable<[VocabularyCardListORM.ORM]> {
            target.cardListModels.asObservable()
        }
        
        var cardListModelsValue: [VocabularyCardListORM.ORM] {
            target.cardListModels.value
        }
        
        var newVocabularyListORM: Observable<VocabularyCardListORM.ORM?> {
            target.newVocabularyListORM.asObservable()
        }
        
        var newVocabularyListORMValue: VocabularyCardListORM.ORM? {
            target.newVocabularyListORM.value
        }
        
        var showCreateNewListNameAlert: Observable<Void> {
            target.showCreateNewListNameAlert.asObservable()
        }
        
        var needReloadTableview: Observable<Void> {
            target.needReloadTableview.asObservable()
        }
    }
    
    /// 從資料庫中載入所有的單字卡清單，並更新卡片清單模型。
    func loadList() {
        let allList = VocabularyCardListORM.ORM.allList() ?? []
        cardListModels.accept(allList)
    }
    
    /// 更新當前單字卡清單 ORM 的名稱。
    ///
    /// - Parameter name: 要設定的新名稱。
    func setNewListORMName(_ name: String) {
        guard var orm = newVocabularyListORM.value else { return }
        orm.name = name
        VocabularyCardListORM.update(orm)
        newVocabularyListORM.accept(orm)
        loadList()
    }
    
    /// 取消新單字卡清單 ORM 的建立，並從資料庫中刪除該清單。
    func cancelNewListORM() {
        newVocabularyListORM.value?.delete()
        newVocabularyListORM.accept(nil)
        loadList()
    }
    
    /// 建立新的單字卡清單 ORM，並顯示命名提示框。
    func cerateNewListORM() {
        let newORM = VocabularyCardListORM.ORM.newList()
        newVocabularyListORM.accept(newORM)
        showCreateNewListNameAlert.accept(())
        loadList()
    }
    
    /// 取得當前編輯模型的名稱，根據指定的索引路徑。
    ///
    /// - Parameter indexPath: 指定的索引路徑，用來查找對應的卡片清單模型。
    /// - Returns: 如果索引路徑有效，返回對應模型的名稱，否則返回 `nil`。
    func getCurrentEditModelName(indexPath: IndexPath) -> String? {
        guard indexPath.row < cardListModels.value.count else { return nil }
        let model = cardListModels.value[indexPath.row]
        return model.name
    }
    
    func setCurrentEditModelName(indexPath: IndexPath, newName: String?) {
        guard let newName, !newName.isEmpty else { return }
        guard indexPath.row < cardListModels.value.count else { return }
        var model = cardListModels.value[indexPath.row]
        model.name = newName
        model.update()
        loadList()
    }
}

extension VocabularyListViewModel: VocabularyListCellDelegate {
    func tapMemorizedSwitchButton(cellModel: VocabularyCardListORM.ORM) {
        var cellModel = cellModel
        cellModel.memorized = !(cellModel.memorized ?? true)
        cellModel.update()
        loadList()
        
        guard let cardListId = cellModel.id else  { return }
        guard let cards = VocabularyCardORM.ORM.allList(listId: cardListId) else { return }
        cards.forEach { card in
            var card = card
            card.memorized = cellModel.memorized
            card.update()
        }
    }
}
