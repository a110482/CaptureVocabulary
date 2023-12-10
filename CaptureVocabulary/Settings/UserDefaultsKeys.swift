//
//  UserDefaultsKeys.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/15.
//

import Foundation

enum UserDefaultsKeys {
    // 目前看到第幾張單字卡
    static let vocabularyCardReadId = UserDefaults.Key<Int>(
        rawValue: "vocabularyCardReadId")
    // 資料庫版本
    static let currentDatabaseVersion = UserDefaults.Key<Int>(
        rawValue: "currentDatabaseVersion")
    // 單字例句下載序列
    static let sentencesDownloadQueue = UserDefaults.Key<Array<String>>(
    rawValue: "sentencesDownloadQueue")
    // 是否在複習模式要顯示中文部分
    static let isHiddenTranslateSwitchOn = UserDefaults.Key<Bool>(
        rawValue: "isHiddenTranslateSwitchOn")
}
