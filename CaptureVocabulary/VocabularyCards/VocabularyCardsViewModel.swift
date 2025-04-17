//
//  VocabularyCardsViewModel.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/12.
//

import RxCocoa
import RxSwift

class VocabularyCardsViewModel {
    private(set) lazy var output = Output(self)
    let selectedList: VocabularyCardListORM.ORM
    
    init(selectedList: VocabularyCardListORM.ORM) {
        self.selectedList = selectedList
        let sortingOptionsTuple = Self.defaultSortingOptions()
        sortingOptions = BehaviorRelay<[VocabularyCardsSortingOption]>(value: sortingOptionsTuple.sortingOptions)
        defaultSelectedIndex = sortingOptionsTuple.filterSelectedIndex
        currentSelectedOption = sortingOptionsTuple.currentSelectedOption
        loadCards()
    }
    
    private let cards = BehaviorRelay<[VocabularyCardORM.ORM]>(value: [])
    private var sortingOptions: BehaviorRelay<[VocabularyCardsSortingOption]>
    let defaultSelectedIndex: Int
    private var currentSelectedOption: VocabularyCardsSortingOption {
        didSet { loadCards() }
    }
}

extension VocabularyCardsViewModel: VocabularyCardCellDelegate {
    class Output: RxOutput<VocabularyCardsViewModel> {
        var cards: Observable<[VocabularyCardORM.ORM]> {
            target.cards.asObservable()
        }
        var sortingOptions: Observable<[VocabularyCardsSortingOption]> {
            target.sortingOptions.asObservable()
        }
    }
    
    func loadCards() {
        guard let listId = selectedList.id else { return }
        let cards = VocabularyCardORM.ORM.allList(listId: listId) ?? []
        self.cards.accept(Array(cards.reversed()))
    }
    
    func tapMemorizedSwitchButton(cellModel: VocabularyCardORM.ORM) {
        var cellModel = cellModel
        guard let memorized = cellModel.memorized else { return }
        cellModel.memorized = !memorized
        cellModel.update()
        cellModel.updateVocabularyCardListMemorizedStatus()
        loadCards()
    }
    
    func didSelectFilterOption(at index: Int) {
        let selectedOption = sortingOptions.value[index]
        guard selectedOption.fuzzyEqual(currentSelectedOption) else {
            currentSelectedOption = selectedOption
            return
        }
        // 如果選中的項目跟上次一樣，就變更排序方向
        currentSelectedOption.toggleSortingType()
        let newSortingOptions = sortingOptions.value.map({
            guard $0.fuzzyEqual(currentSelectedOption) else { return $0 }
            return currentSelectedOption
        })
        sortingOptions.accept(newSortingOptions)
    }
}

private extension VocabularyCardsViewModel {
    /// 設定預設的 filter 選項
    class func defaultSortingOptions() -> (sortingOptions: [VocabularyCardsSortingOption],
                                          filterSelectedIndex: Int,
                                          currentSelectedOption: VocabularyCardsSortingOption) {
        let sortingOptions: [VocabularyCardsSortingOption] = [
            .star,
            .time(sortingType: .ascending),
            .prefixLetter(sortingType: .ascending)
        ]
        let filterSelectedIndex = 1
        let currentSelectedOption = sortingOptions[filterSelectedIndex]
        return (sortingOptions, filterSelectedIndex, currentSelectedOption)
    }
    
    func sort(cards: [VocabularyCardORM.ORM], by sortingOptions: VocabularyCardsSortingOption) {
        
    }
}
