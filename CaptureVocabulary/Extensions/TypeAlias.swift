//
//  TypeAlias.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/2/13.
//

import Foundation

/// 有時候 Task 會跟 Moya.Task 衝突命名，所以用 SwiftTask 確保叫到的是對的
typealias SwiftTask = _Concurrency.Task
