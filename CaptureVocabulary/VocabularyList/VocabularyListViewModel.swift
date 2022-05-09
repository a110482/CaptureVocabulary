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
        let allList = BehaviorRelay<[VocabularyCardListORM.ORM]>(value: [])
        let vocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
        let showEditListNameAlert = PublishRelay<Void>()
    }
    
    let output = Output()
    
    init() {
        loadList()
    }
    
    func loadList() {
        let allList = VocabularyCardListORM.ORM.allList() ?? []
        output.allList.accept(allList)
    }
    
    func setListORMName(_ name: String) {
        guard var orm = output.vocabularyListORM.value else { return }
        orm.name = name
        VocabularyCardListORM.update(orm)
        output.vocabularyListORM.accept(orm)
        loadList()
    }
    
    func cancelNewListORM() {
        output.vocabularyListORM.value?.delete()
        output.vocabularyListORM.accept(nil)
        loadList()
    }
    
    func cerateNewListORM() {
        let newORM = VocabularyCardListORM.ORM.newList()
        output.vocabularyListORM.accept(newORM)
        output.showEditListNameAlert.accept(())
        loadList()
    }
}
