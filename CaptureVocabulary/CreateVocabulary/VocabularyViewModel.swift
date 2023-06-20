//
//  VocabularyViewModel.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/10/10.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: - ViewModel
class VocabularyViewModel {
    struct Inout {
        let vocabulary = BehaviorRelay<String?>(value: nil)
    }
    let `inout` = Inout()
    
    struct Output {
        let vocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
        let showEditListNameAlert = PublishRelay<Void>()
        let phonetic = BehaviorRelay<String>(value: "")
        let translateData = BehaviorRelay<StarDictORM.ORM?>(value: nil)
    }
    
    let output = Output()
    
    struct Input {
        let customTranslate = BehaviorRelay<String?>(value: nil)
    }
    
    let input = Input()
    
    private let disposeBag = DisposeBag()
    
    init(vocabulary: String) {
        `inout`.vocabulary.accept(vocabulary)
        sentQueryRequest()
        getVocabularyListObject()
    }
    
    func sentQueryRequest() {
        guard let vocabulary = `inout`.vocabulary.value else { return }
        // nil 表示查不到資料, 要顯示無資料畫面
        let result = StarDictORM.query(word: vocabulary)
        updateData(model: result)
    }
    
    private func updateData(model: StarDictORM.ORM?) {
        output.translateData.accept(model)
        guard let model else {
            output.phonetic.accept("")
            return
        }
        setNormalizedSource(model)
        output.phonetic.accept(model.phonetic ?? "")
    }
    
    // 建立新的清單
    func cerateNewListORM() {
        let newORM = VocabularyCardListORM.ORM.newList()
        output.vocabularyListORM.accept(newORM)
        output.showEditListNameAlert.accept(())
    }
    
    // 建立預設清單
    func createDefaultList() {
        guard let orm = VocabularyCardListORM.ORM.createDefaultList() else { return }
        selected(orm: orm)
    }
    
    // 刪除當前清單
    func cancelNewListORM() {
        output.vocabularyListORM.value?.delete()
        output.vocabularyListORM.accept(nil)
        getVocabularyListObject()
    }
    
    func setListORMName(_ name: String) {
        guard var orm = output.vocabularyListORM.value else { return }
        orm.name = name
        VocabularyCardListORM.update(orm)
        output.vocabularyListORM.accept(orm)
    }
    
    func selected(orm: VocabularyCardListORM.ORM) {
        output.vocabularyListORM.accept(orm)
    }
    
    func getAllList() -> [VocabularyCardListORM.ORM] {
        return VocabularyCardListORM.ORM.allList() ?? []
    }
    
    func saveVocabularyCard() {
        guard let translate = input.customTranslate.value ?? output.translateData.value?.getMainTranslation()?.localized() else {
            return
        }
        guard let vocabulary = `inout`.vocabulary.value,
              let cardListId = output.vocabularyListORM.value?.id
        else { return }
        
        var cardObj = VocabularyCardORM.ORM()
        cardObj.normalizedSource = vocabulary
        cardObj.normalizedTarget = translate
        cardObj.cardListId = cardListId
        cardObj.phonetic = output.translateData.value?.phonetic
        VocabularyCardORM.create(cardObj)
        guard var listObj = output.vocabularyListORM.value else { return }
        listObj.timestamp = Date().timeIntervalSince1970
        VocabularyCardListORM.update(listObj)
    }
    
    private func setNormalizedSource(_ model: StarDictORM.ORM) {
        `inout`.vocabulary.accept(model.word)
    }
    
    private func getVocabularyListObject() {
        let lastEditList = VocabularyCardListORM.ORM.lastEditList()
        output.vocabularyListORM.accept(lastEditList)
    }
}

extension VocabularyCardListORM.ORM: UIPickerViewModelProtocol {
    var title: String {
        return name ?? ""
    }
}
