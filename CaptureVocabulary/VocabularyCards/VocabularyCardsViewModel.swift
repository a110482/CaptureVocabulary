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
        self.cards.accept(sort(cards: cards, by: currentSelectedOption))
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
    
    func sort(cards: [VocabularyCardORM.ORM], by sortingOptions: VocabularyCardsSortingOption) -> [VocabularyCardORM.ORM] {
        switch sortingOptions {
        case .star:
            return sortingByMemorized(cards: cards)
        case .time(let sortingType):
            if sortingType == .ascending {
                return sortingByTime(cards: cards)
            } else {
                return sortingByTimeRevise(cards: cards)
            }
        case .prefixLetter(let sortingType):
            if sortingType == .ascending {
                return sortingByString(cards: cards)
            } else {
                return sortingByStringRevise(cards: cards)
            }
        }
    }
    
    /// 依靠星號排序 (星號代表未記憶)
    func sortingByMemorized(cards: [VocabularyCardORM.ORM]) -> [VocabularyCardORM.ORM] {
        return cards.sorted(by: {
            // 確保都有星號欄位
            guard $0.memorized != nil, $1.memorized != nil else {
                return $0.id! < $1.id!
            }
            
            if $0.memorized! {
                // $0 已記憶代表無星號，把 $1 往前排
                return false
            } else if $1.memorized! {
                // $1 已記憶代表無星號，把 $0 往前排
                return true
            }
            // 無記憶就靠 id 排
            return $0.id! < $1.id!
        })
    }
    
    func sortingByTime(cards: [VocabularyCardORM.ORM]) -> [VocabularyCardORM.ORM] {
        return cards.sorted(by: { $0.id! < $1.id! })
    }
    
    func sortingByTimeRevise(cards: [VocabularyCardORM.ORM]) -> [VocabularyCardORM.ORM] {
        return cards.sorted(by: { $0.id! > $1.id! })
    }
    
    func sortingByString(cards: [VocabularyCardORM.ORM]) -> [VocabularyCardORM.ORM] {
        return cards.sorted(by: {
            guard  $0.normalizedSource != nil,  $1.normalizedSource != nil else { return true }
            return $0.normalizedSource! < $1.normalizedSource!
        })
    }
    
    func sortingByStringRevise(cards: [VocabularyCardORM.ORM]) -> [VocabularyCardORM.ORM] {
        return cards.sorted(by: {
            guard  $0.normalizedSource != nil,  $1.normalizedSource != nil else { return true }
            return $0.normalizedSource! > $1.normalizedSource!
        })
    }
}
