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
    private(set) lazy var output = Output(self)
    
    /// 儲存詞彙卡至資料庫或儲存位置。
    ///
    /// - Returns: 一個布林值，表示儲存是否成功。
    func saveVocabularyCard() -> Bool {
        guard let translate = customTranslate ?? translateData.value?.getMainTranslation()?.localized() else {
            return false
        }
        guard let vocabulary = vocabulary.value,
              let cardListId = vocabularyListORM.value?.id
        else { return false }
        
        var cardObj = VocabularyCardORM.ORM()
        cardObj.normalizedSource = vocabulary
        cardObj.normalizedTarget = translate
        cardObj.cardListId = cardListId
        cardObj.phonetic = translateData.value?.phonetic ?? ""
        VocabularyCardORM.create(cardObj)
        guard var listObj = vocabularyListORM.value else { return false }
        listObj.timestamp = Date().timeIntervalSince1970
        VocabularyCardListORM.update(listObj)
        return true
    }
    
    init(vocabulary: String) {
        set(vocabulary: vocabulary)
        sentQueryRequest()
        getVocabularyListObject()
    }
    
    fileprivate let vocabulary = BehaviorRelay<String?>(value: nil)
    fileprivate let translateData = BehaviorRelay<StarDictORM.ORM?>(value: nil)
    fileprivate let vocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
    fileprivate let showEditListNameAlert = PublishRelay<Void>()
    fileprivate let phonetic = BehaviorRelay<String>(value: "")
    /// 自訂翻譯預設值, 給用戶編輯
    fileprivate(set) var customTranslate: String?
    private let disposeBag = DisposeBag()
}

extension VocabularyViewModel {
    class Output: RxOutput<VocabularyViewModel> {
        var translateData: Driver<StarDictORM.ORM?> { target.translateData.asDriver() }
        var vocabulary: Driver<String?> { target.vocabulary.asDriver() }
        var vocabularyListORM: Observable<VocabularyCardListORM.ORM?> { target.vocabularyListORM.asObservable() }
        var vocabularyListORMValue: VocabularyCardListORM.ORM? { target.vocabularyListORM.value }
        var showEditListNameAlert: Observable<Void> { target.showEditListNameAlert.asObservable() }
        var phonetic: Observable<String> { target.phonetic.asObservable() }
    }
    
    /// 寫入自定義翻譯
    func save(customTranslate: String?) {
        self.customTranslate = customTranslate
    }
    
    /// 建立新的清單
    func cerateNewListORM() {
        let newORM = VocabularyCardListORM.ORM.newList()
        vocabularyListORM.accept(newORM)
        showEditListNameAlert.accept(())
    }
    
    /// 建立預設清單
    func createDefaultList() {
        guard let orm = VocabularyCardListORM.ORM.createDefaultList() else { return }
        selected(orm: orm)
    }
    
    /// 刪除當前清單
    func cancelNewListORM() {
        vocabularyListORM.value?.delete()
        vocabularyListORM.accept(nil)
        getVocabularyListObject()
    }
    
    func setListORMName(_ name: String) {
        guard var orm = vocabularyListORM.value else { return }
        orm.name = name
        VocabularyCardListORM.update(orm)
        vocabularyListORM.accept(orm)
    }
    
    func selected(orm: VocabularyCardListORM.ORM) {
        vocabularyListORM.accept(orm)
    }
    
    func getAllList() -> [VocabularyCardListORM.ORM] {
        return VocabularyCardListORM.ORM.allList() ?? []
    }
    
    func set(vocabulary: String) {
        self.vocabulary.accept(vocabulary.normalized)
    }
    
    func sentQueryRequest() {
        guard let vocabulary = self.vocabulary.value else { return }
        let result = StarDictORM.query(word: vocabulary)
        // nil 表示查不到資料, 要顯示無資料畫面
        self.updateData(model: result)
    }
}

private extension VocabularyViewModel {
    private func updateData(model: StarDictORM.ORM?) {
        translateData.accept(model)
        guard let model else {
            phonetic.accept("")
            return
        }
        set(vocabulary: model.word ?? "")
        phonetic.accept(model.phonetic ?? "")
    }
    
    private func getVocabularyListObject() {
        let lastEditList = VocabularyCardListORM.ORM.lastEditList()
        vocabularyListORM.accept(lastEditList)
    }
}

extension VocabularyCardListORM.ORM: UIPickerViewModelProtocol {
    var title: String {
        return name ?? ""
    }
}


// MARK: - EditVocabularyViewModel (編輯現有單字卡用的 model)
class EditVocabularyViewModel: VocabularyViewModel {
    
    private var cardModel: VocabularyCardORM.ORM
    
    init(cardModel: VocabularyCardORM.ORM) {
        self.cardModel = cardModel
        super.init(vocabulary: cardModel.normalizedSource ?? "")
        customTranslate = cardModel.normalizedTarget
    }
    
    @available(*, deprecated, message: "Use init(cardModel: VocabularyCardORM.ORM) instead")
    override init(vocabulary: String) {
        fatalError()
    }
    
    /// 儲存詞彙卡至資料庫或儲存位置。
    ///
    /// - Returns: 一個布林值，表示儲存是否成功。
    override func saveVocabularyCard() -> Bool {
        guard let translate = customTranslate ?? translateData.value?.getMainTranslation()?.localized() else {
            return false
        }
        guard let vocabulary = vocabulary.value,
              let cardListId = vocabularyListORM.value?.id
        else { return false }
        
        var cardObj = cardModel
        cardObj.normalizedSource = vocabulary
        cardObj.normalizedTarget = translate
        cardObj.cardListId = cardListId
        cardObj.phonetic = translateData.value?.phonetic
        VocabularyCardORM.update(cardObj)
        guard var listObj = vocabularyListORM.value else { return false }
        listObj.timestamp = Date().timeIntervalSince1970
        VocabularyCardListORM.update(listObj)
        return true
    }
}
