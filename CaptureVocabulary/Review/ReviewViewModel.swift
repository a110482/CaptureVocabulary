//
//  ReviewViewModel.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/16.
//

import Foundation
import RxCocoa
import RxSwift
import MediaPlayer

// MARK: -
class ReviewViewModel {
    struct Output {
        let _sentences = BehaviorRelay<[SimpleSentencesORM.ORM]?>(value: nil)
        fileprivate let _dictionaryData = BehaviorRelay<StarDictORM.ORM?>(value: nil)
        let scrollToIndex = PublishRelay<(indexRow: Int, animation: Bool)>()
        var dictionaryData: Driver<StarDictORM.ORM?> { _dictionaryData.asDriver() }
        var sentences: Driver<[SimpleSentencesORM.ORM]?> { _sentences.asDriver() }
        let needReloadDate = PublishRelay<Void>()
    }
    let output = Output()
    let indexCount = 200
    private(set) var isHiddenTranslateSwitchOn: Bool {
        get { UserDefaults.standard[UserDefaultsKeys.isHiddenTranslateSwitchOn] ?? false }
        set { UserDefaults.standard[UserDefaultsKeys.isHiddenTranslateSwitchOn] = newValue }
    }
    private(set) var isAudioModeOn = false
    private lazy var lastReadCardTableIndex = { indexCount / 2 }() // 50
    private var lastReadCardId: Int? {
        get {
            UserDefaults.standard[UserDefaultsKeys.vocabularyCardReadId]
        }
        set {
            UserDefaults.standard[UserDefaultsKeys.vocabularyCardReadId] = newValue
        }
    }
    /// 記錄目前已按下提示的 cell
    private(set) var pressTipVocabulary: String? = nil
    private let disposeBag = DisposeBag()
    
    init() {
        SimpleSentenceService.shared.registerObserver(object: self)
    }
    
    func loadLastReadVocabularyCard() {
        output.scrollToIndex.accept((indexRow: lastReadCardTableIndex,
                                     animation: false))
        queryLocalDictionary()
        querySimpleSentences()
    }
    
    func queryVocabularyCard(index: Int) -> VocabularyCardORM.ORM? {
        let dataBaseIndex = getCardDatabaseIndexBy(tableIndex: index)
        let orm = VocabularyCardORM.ORM.get(by: dataBaseIndex, memorized: false)
        return orm
    }
    
    func updateLastReadCard(index: Int) {
        // 更新 id & index 給無限滾動機制
        guard let orm = queryVocabularyCard(index: index) else { return }
        guard let id = orm.id else { return }
        lastReadCardTableIndex = index
        lastReadCardId = Int(id)
        
        // 更新字典頁面
        queryLocalDictionary()
        querySimpleSentences()
    }
    
    /// 重新校正 index 以維持無線滾動維持在中央
    /// 整個無限滾動原理:
    /// 所有 cell 資料向 database 拿資料時, 都是基於 database 裡的排序
    /// collection index 是會映射到資料庫裡的某段順序
    /// 例如:                                                                ▼ 這就是 lastReadCardTableIndex
    /// collection index:                   [0      1     2     ... 50   ... 99   100 ]
    /// database Index: [0 1 2 ...      107  108 109 ... 157 ... 206 207 108 ... 500]
    /// 然後當 collection 滾動到第 52 筆資料時, 實際是向 database 取用第 52 + 107 = 159 筆資料
    func adjustIndex() {
        let tableIndexDelta = min(
            indexCount - lastReadCardTableIndex,
            lastReadCardTableIndex)
        
        // 位移不大不調整
        guard tableIndexDelta <= indexCount/3 else { return }
        // 重設參考點
        lastReadCardTableIndex = indexCount / 2
        output.scrollToIndex.accept((indexRow: lastReadCardTableIndex,
                                     animation: false))
    }
    
    private func queryLocalDictionary() {
        guard let cellModel = queryVocabularyCard(index: lastReadCardTableIndex) else {
            output._dictionaryData.accept(nil)
            output._sentences.accept(nil)
            return
        }
        guard let vocabulary = cellModel.normalizedSource else {
            output._dictionaryData.accept(nil)
            output._sentences.accept(nil)
            return
        }
        let response = StarDictORM.query(word: vocabulary)
        output._dictionaryData.accept(response)
        if response?.word != output._sentences.value?.first?.normalizedSource {
            output._sentences.accept(nil)
        }
    }
    
    private func querySimpleSentences() {
        guard let cellModel = queryVocabularyCard(index: lastReadCardTableIndex) else {
            return
        }
        guard let vocabulary = cellModel.normalizedSource else {
            return
        }
        guard let sentences = SimpleSentenceService.shared.querySentence(queryWord: vocabulary) else {
            output._sentences.accept(nil)
            return
        }
        output._sentences.accept(sentences)
    }
    
    private func getCardDatabaseIndexBy(tableIndex: Int) -> Int {
        let allVocabularyCount = VocabularyCardORM.ORM.cardNumbers(memorized: false)
        guard allVocabularyCount > 0 else { return 0 }
        let lastReadDataBaseIndex = VocabularyCardORM.ORM.getIndex(by: lastReadCardId, memorized: false)
        let indexDelta = tableIndex - lastReadCardTableIndex
        var databaseIndex = lastReadDataBaseIndex + indexDelta
        while databaseIndex < 0 {
            databaseIndex += allVocabularyCount
        }
        while databaseIndex > (allVocabularyCount - 1) {
            databaseIndex -= allVocabularyCount
        }
        return databaseIndex
    }
    
    #warning("版本檢查函數, 目前沒有使用")
    private func versionCheck() {
        typealias Req = VersionCheck
        let api = Req()
        let request = RequestBuilder<Req>()
        request.result.subscribe(onNext: { model in
            print(model)
        }).disposed(by: disposeBag)
        request.send(req: api)
    }
}

// cell delegate
extension ReviewViewModel: ReviewCollectionViewCellDelegate {
    func tapMemorizedSwitchButton(orm: VocabularyCardORM.ORM) {
        let currentMemorized = orm.memorized ?? false
        var newCellModel = orm
        newCellModel.memorized = !currentMemorized
        newCellModel.update()
        output.scrollToIndex.accept((indexRow: lastReadCardTableIndex + 1,
                                     animation: true))
        output.needReloadDate.accept(())
    }
    
    func hiddenTranslateSwitchDidChanged(isOn: Bool) {
        isHiddenTranslateSwitchOn = isOn
        pressTipVocabulary = nil
        output.needReloadDate.accept(())
    }
    
    func didPressedTipIcon() {
        pressTipVocabulary = output._dictionaryData.value?.word
        output.needReloadDate.accept(())
    }
    
    func didPressedAudioPlayButton() {
        // 撥放背景 mp3 維持背景播放
        applyAudioMode(isEnable: !isAudioModeOn)
    }
}

// 例句服務的 delegate
extension ReviewViewModel: SimpleSentenceServiceDelegate {
    func sentencesDidLoad(normalizedSource: String) {
        querySimpleSentences()
    }
}

// 語音播放相關
private extension ReviewViewModel {
    func applyAudioMode(isEnable: Bool) {
        isAudioModeOn = isEnable
        output.needReloadDate.accept(())
        guard isEnable else {
//            MP3Player.shared.stop()
            return
        }
//        MP3Player.shared.playSound()
        Speaker.shared.delegate = self
        playVocabulary()
        setupNowPlayingInfo()
        setupRemoteTransportControls()
    }
    
    /// 設定歌曲資訊
    func setupNowPlayingInfo() {
        let nowPlayingInfo: [String : Any] = [
            MPMediaItemPropertyTitle: "單字複習",
            MPMediaItemPropertyArtist: "單字屋",
            MPMediaItemPropertyAlbumTitle: "單字複習",
//            MPMediaItemPropertyPlaybackDuration: 300, // 歌曲總時長（以秒為單位）
//            MPNowPlayingInfoPropertyElapsedPlaybackTime: 60, // 目前播放進度（以秒為單位）
        ]
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    /// 設定播放按鈕
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self else { return .success }
            self.applyAudioMode(isEnable: true)
            return .success
        }
        
        // 設定暫停按鈕
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self else { return .success }
            self.applyAudioMode(isEnable: false)
            return .success
        }
        
        // 設定下一首按鈕
        commandCenter.nextTrackCommand.addTarget { event in
            // 按下下一首按鈕時的處理邏輯
            return .success
        }
        
        // 設定上一首按鈕
        commandCenter.previousTrackCommand.addTarget { event in
            // 按下上一首按鈕時的處理邏輯
            return .success
        }
    }
    
    /// 播放單字
    func playVocabulary() {
        guard let data = queryVocabularyCard(index: lastReadCardTableIndex) else {
            applyAudioMode(isEnable: false)
            return
        }
        Speaker.shared.speakSequences(data.normalizedSource ?? "", language: .en_US)
        Speaker.shared.speakSequences("", language: .pause(time: 1))
        Speaker.shared.speakSequences(filterChinese(source: data.normalizedTarget), language: .zh_TW)
    }
    
    func nextVocabulary() {
        updateLastReadCard(index: lastReadCardTableIndex + 1)
        output.scrollToIndex.accept((indexRow: lastReadCardTableIndex, animation: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            guard self.isAudioModeOn else { return }
            self.playVocabulary()
        })
    }
    
    func filterChinese(source: String?) -> String {
        guard let source else { return "" }
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[\\u4e00-\\u9fa5]+$")
        
        // 使用 UnicodeScalar 遍歷源字符串，過濾中文字符
        let filteredCharacters = source.unicodeScalars.filter { predicate.evaluate(with: String($0)) }
        
        // 將 UnicodeScalar 轉換為 String 並連接成最終的字符串
        let result = String(String.UnicodeScalarView(filteredCharacters))
        
        return result
    }
}

extension ReviewViewModel: SpeakerDelegate {
    func sequencesDidFinish() {
        guard isAudioModeOn else { return }
        nextVocabulary()
    }
    
    func sequencesDidInterrupt() {
        isAudioModeOn = false
        output.needReloadDate.accept(())
    }
}
