//
//  VocabularyCardsViewModel.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/12.
//

import RxCocoa
import RxSwift

class VocabularyCardsViewModel {
    struct Output {
        let cards = BehaviorRelay<[VocabularyCardORM.ORM]>(value: [])
    }
    let output = Output()
    
    let selectedList: VocabularyCardListORM.ORM
    
    init(selectedList: VocabularyCardListORM.ORM) {
        self.selectedList = selectedList
        loadCards()
    }
    
    func loadCards() {
        guard let listId = selectedList.id else { return }
        let cards = VocabularyCardORM.ORM.allList(listId: listId) ?? []
        output.cards.accept(Array(cards.reversed()))
    }
}

extension VocabularyCardsViewModel: VocabularyCardCellDelegate {
    func tapMemorizedSwitchButton(cellModel: VocabularyCardORM.ORM) {
        var cellModel = cellModel
        guard let memorized = cellModel.memorized else { return }
        cellModel.memorized = !memorized
        cellModel.update()
        loadCards()
    }
}
