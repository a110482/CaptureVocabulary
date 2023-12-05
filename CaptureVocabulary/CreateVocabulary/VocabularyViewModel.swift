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
    struct Output {
        fileprivate let _vocabulary = BehaviorRelay<String?>(value: nil)
        fileprivate let _translateData = BehaviorRelay<StarDictORM.ORM?>(value: nil)
        
        let vocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
        let showEditListNameAlert = PublishRelay<Void>()
        let phonetic = BehaviorRelay<String>(value: "")
        var translateData: Driver<StarDictORM.ORM?> { _translateData.asDriver() }
        var vocabulary: Driver<String?> { _vocabulary.asDriver() }
    }
    
    let output = Output()
    
    /// 自訂翻譯預設值, 給用戶編輯
    var customTranslate: String?
    
    private let disposeBag = DisposeBag()
    
    init(vocabulary: String) {
        set(vocabulary: vocabulary)
        sentQueryRequest()
        getVocabularyListObject()
    }
    
    func set(vocabulary: String) {
        output._vocabulary.accept(vocabulary.normalized)
    }
    
    func sentQueryRequest() {
        output.vocabulary.drive(onNext: { [weak self] vocabulary in
            guard let self, let vocabulary else { return }
            // nil 表示查不到資料, 要顯示無資料畫面
            let result = StarDictORM.query(word: vocabulary)
            self.updateData(model: result)
        }).dispose()
    }
    
    private func updateData(model: StarDictORM.ORM?) {
        output._translateData.accept(model)
        guard let model else {
            output.phonetic.accept("")
            return
        }
        set(vocabulary: model.word ?? "")
        output.phonetic.accept(model.phonetic ?? "")
    }
    
    /// 建立新的清單
    func cerateNewListORM() {
        let newORM = VocabularyCardListORM.ORM.newList()
        output.vocabularyListORM.accept(newORM)
        output.showEditListNameAlert.accept(())
    }
    
    /// 建立預設清單
    func createDefaultList() {
        guard let orm = VocabularyCardListORM.ORM.createDefaultList() else { return }
        selected(orm: orm)
    }
    
    /// 刪除當前清單
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
        guard let translate = customTranslate ?? output._translateData.value?.getMainTranslation()?.localized() else {
            return
        }
        guard let vocabulary = output._vocabulary.value,
              let cardListId = output.vocabularyListORM.value?.id
        else { return }
        
        var cardObj = VocabularyCardORM.ORM()
        cardObj.normalizedSource = vocabulary
        cardObj.normalizedTarget = translate
        cardObj.cardListId = cardListId
        cardObj.phonetic = output._translateData.value?.phonetic
        VocabularyCardORM.create(cardObj)
        guard var listObj = output.vocabularyListORM.value else { return }
        listObj.timestamp = Date().timeIntervalSince1970
        VocabularyCardListORM.update(listObj)
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


// MARK: - EditVocabularyViewModel
class EditVocabularyViewModel: VocabularyViewModel {
    
    private var cardModel: VocabularyCardORM.ORM
    
    init(cardModel: VocabularyCardORM.ORM) {
        self.cardModel = cardModel
        super.init(vocabulary: cardModel.normalizedSource ?? "")
        customTranslate = cardModel.normalizedTarget
    }
    
    //@available(*, deprecated, message: "Use init(cardModel: VocabularyCardORM.ORM) instead")
    override init(vocabulary: String) {
        fatalError()
    }
    
    override func saveVocabularyCard() {
        guard let translate = customTranslate ?? output._translateData.value?.getMainTranslation()?.localized() else {
            return
        }
        guard let vocabulary = output._vocabulary.value,
              let cardListId = output.vocabularyListORM.value?.id
        else { return }
        
        var cardObj = cardModel
        cardObj.normalizedSource = vocabulary
        cardObj.normalizedTarget = translate
        cardObj.cardListId = cardListId
        cardObj.phonetic = output._translateData.value?.phonetic
        VocabularyCardORM.update(cardObj)
        guard var listObj = output.vocabularyListORM.value else { return }
        listObj.timestamp = Date().timeIntervalSince1970
        VocabularyCardListORM.update(listObj)
    }
}
