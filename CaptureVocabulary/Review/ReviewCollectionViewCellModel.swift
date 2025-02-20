//
//  ReviewCollectionViewCellModel.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/1/15.
//

import Foundation

struct ReviewCollectionViewCellModel {
    /// 字典的 orm
    var orm: VocabularyCardORM.ORM
    /// 顯示翻譯的 switch on/off 狀態
    var isHiddenTranslateSwitchOn: Bool
    /// 目前已點選提示的單字
    var pressTipVocabulary: String?
    /// 播放模式是否正在播放中
    var isAudioModeOn: Bool
}
