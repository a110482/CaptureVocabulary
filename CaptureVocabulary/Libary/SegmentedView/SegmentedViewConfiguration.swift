//
//  SegmentedViewConfiguration.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/2.
//

import UIKit
import RxSwift
import RxCocoa

/// 分段視圖的配置設定。
class SegmentedViewConfiguration {
    /// 用於分段視圖中文本的字型。預設為系統字型，大小為 12。
    var font: UIFont = .systemFont(ofSize: 12) {
        didSet { _configChanged.accept(()) }
    }
    
    /// 用於分段視圖中預設（未選擇）選項的顏色。預設為淺灰色。
    var defaultOptionsColor: UIColor = .lightGray {
        didSet { _configChanged.accept(()) }
    }
    
    /// 用於分段視圖中選擇（已選擇）選項的顏色。預設為白色。
    var selectedOptionsColor: UIColor = .gray {
        didSet { _configChanged.accept(()) }
    }
    
    /// 分段視圖中選項之間的間距。預設為 12。
    var optionsSpacing: CGFloat = 12 {
        didSet { _configChanged.accept(()) }
    }
    
    /// 分段視圖中選項的寬度。預設為自動調整。
    var optionWidth: CGFloat = SegmentedViewConfiguration.automaticWidth {
        didSet { _configChanged.accept(()) }
    }
    
    var optionBottomBarIsHidden: Bool = true {
        didSet { _configChanged.accept(()) }
    }
    
    /// 底部滑棒的顏色
    var optionBottomBarColor: UIColor = .gray {
        didSet { _configChanged.accept(()) }
    }
    
    /// 底部滑棒的寬度
    var optionBottomBarWidth: CGFloat = 50 {
        didSet { _configChanged.accept(()) }
    }
    
    /// 是否需要顯示分隔線
    var isNeedDisplayDivider: Bool = false {
        didSet { _configChanged.accept(()) }
    }
    
    var dividerColor: UIColor = .gray {
        didSet { _configChanged.accept(()) }
    }
    
    var dividerHeight: CGFloat = 12 {
        didSet { _configChanged.accept(()) }
    }
    
    /// 監聽配置變更的可觀察對象。
    var configChanged: Observable<Void> {
        _configChanged.asObservable()
    }
    
    /// 私有的 `PublishRelay` 用於觸發配置變更事件。
    private let _configChanged = PublishRelay<Void>()
    
    /// 讓文字撐開
    static let automaticWidth: CGFloat = -1
    
    /// 分散對齊
    static let equalWidth: CGFloat = -2
}
