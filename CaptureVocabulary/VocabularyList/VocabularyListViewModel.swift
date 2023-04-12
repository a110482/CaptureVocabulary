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
    struct Output {
        let cardListModels = BehaviorRelay<[VocabularyCardListORM.ORM]>(value: [])
        let newVocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
        let showEditListNameAlert = PublishRelay<Void>()
        let needReloadTableview = PublishRelay<Void>()
    }
    
    let output = Output()
    
    init() {
        loadList()
    }
    
    func loadList() {
        let allList = VocabularyCardListORM.ORM.allList() ?? []
        output.cardListModels.accept(allList)
    }
    
    func setListORMName(_ name: String) {
        guard var orm = output.newVocabularyListORM.value else { return }
        orm.name = name
        VocabularyCardListORM.update(orm)
        output.newVocabularyListORM.accept(orm)
        loadList()
    }
    
    func cancelNewListORM() {
        output.newVocabularyListORM.value?.delete()
        output.newVocabularyListORM.accept(nil)
        loadList()
    }
    
    func cerateNewListORM() {
        let newORM = VocabularyCardListORM.ORM.newList()
        output.newVocabularyListORM.accept(newORM)
        output.showEditListNameAlert.accept(())
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
