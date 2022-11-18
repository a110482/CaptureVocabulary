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
        let translateData = BehaviorRelay<StringTranslateAPIResponse?>(value: nil)
    }
    let `inout` = Inout()
    
    struct Output {
        let vocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
        let showEditListNameAlert = PublishRelay<Void>()
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
    
    // 等按 return 再查詢, 不然流量太兇
    func sentQueryRequest() {
        guard let vocabulary = `inout`.vocabulary.value else { return }
        typealias Req = YDTranslateAPI

        let normalized = vocabulary.normalized
        let queryModel = YDTranslateAPIQueryModel(queryString: normalized)
        
        if let saveModel = Req.ResponseModel.load(queryModel: queryModel) {
            updateData(model: saveModel)
        } else {
            let request = Req(queryModel: queryModel)
            let api = RequestBuilder<Req>()
            api.result.subscribe(onNext: { [weak self] res in
                guard let self = self else { return }
                guard let res = res else { return }
                guard res.isWord ?? false else { return }
                res.create(nil)
                self.updateData(model: res)
            }).disposed(by: disposeBag)
            api.send(req: request)
        }

    }
    
    private func updateData(model: StringTranslateAPIResponse) {
        setNormalizedSource(model)
        `inout`.translateData.accept(model)
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
        guard let translate = input.customTranslate.value ?? `inout`.translateData.value?.translation?.first else {
            return
        }
        guard let vocabulary = `inout`.vocabulary.value,
              let cardListId = output.vocabularyListORM.value?.id
        else { return }
        
        var cardObj = VocabularyCardORM.ORM()
        cardObj.normalizedSource = vocabulary
        cardObj.normalizedTarget = translate
        cardObj.cardListId = cardListId
        VocabularyCardORM.create(cardObj)
        guard var listObj = output.vocabularyListORM.value else { return }
        listObj.timestamp = Date().timeIntervalSince1970
        VocabularyCardListORM.update(listObj)
    }
    
    private func setNormalizedSource(_ translateData: StringTranslateAPIResponse) {
        guard let normalizedSource = translateData.returnPhrase?.first else { return }
        `inout`.vocabulary.accept(normalizedSource)
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
