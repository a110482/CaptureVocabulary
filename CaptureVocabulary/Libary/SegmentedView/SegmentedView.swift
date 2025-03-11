//
//  SegmentedView.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/2.
//

import UIKit
import RxSwift
import RxCocoa

protocol SegmentedViewDelegate: AnyObject {
    /// 當使用者選擇了 `SegmentedView` 中的某個選項時會被呼叫。
    /// - Parameters:
    ///   - view: `SegmentedView` 的實例。
    ///   - index: 被選取的選項索引。
    func segmentedView(_ view: SegmentedView, didSelectOptionAt index: Int)
    
    
    /// 是否允許用戶選擇某個選項
    /// - Parameters:
    ///   - view: `SegmentedView` 的實例。
    ///   - index: 被選取的選項索引。
    /// - Returns: 允許或不允許
    func shouldSegmentedView(_ view: SegmentedView, selectOptionAt index: Int) -> Bool
    
    /// 該方法用於詢問代理某個索引處的選項的寬度。
    /// - Parameters:
    ///   - view: `SegmentedView` 的實例。
    ///   - index: 選項的索引。
    /// - Returns: 該索引處選項的寬度，以 `CGFloat` 表示。
    func segmentedView(_ view: SegmentedView, optionWidthAt index: Int) -> CGFloat
}

extension SegmentedViewDelegate {
    func segmentedView(_ view: SegmentedView, didSelectOptionAt index: Int) {}
    
    func segmentedView(_ view: SegmentedView, optionWidthAt index: Int) -> CGFloat {
        return SegmentedViewConfiguration.automaticWidth
    }
    
    func shouldSegmentedView(_ view: SegmentedView, selectOptionAt index: Int) -> Bool {
        return true
    }
}

protocol SegmentedViewDataSource: AnyObject {
    /// 該方法用於詢問數據源 `SegmentedView` 中選項的總數。
    /// - Parameter view: `SegmentedView` 的實例。
    /// - Returns: `SegmentedView` 中的選項總數。
    func numberOfOptions(in view: SegmentedView) -> Int
    
    /// 該方法用於詢問某個索引處的選項的標題。
    /// - Parameters:
    ///   - view: `SegmentedView` 的實例。
    ///   - index: 選項的索引。
    /// - Returns: 該索引處選項的標題 View
    func segmentedView(_ view: SegmentedView, titleForOptionAt index: Int) -> SegmentedOptionView
}

class SegmentedView: UIView {
    weak var delegate: SegmentedViewDelegate?
    weak var dataSource: SegmentedViewDataSource? {
        didSet { reloadData() }
    }
    private(set) var selectedIndex: Int = 0
    
    override init(frame: CGRect) {
        _configuration = SegmentedViewConfiguration()
        super.init(frame: frame)
        bindConfiguration()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var configurationDisposeBag = DisposeBag()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let optionBottomBar = UIView()
    private var _configuration: SegmentedViewConfiguration
}

// MARK: - Public functions
extension SegmentedView {
    var configuration: SegmentedViewConfiguration {
        get { _configuration }
        set {
            _configuration = newValue
            bindConfiguration()
            updateUI()
        }
    }
    
    func reloadData() {
        resetStackView()
        layoutOptions()
        updateOptionBottomBarPosition()
    }
    
    func setSelected(index: Int) {
        let options = stackView.arrangedSubviews.compactMap { $0 as? SegmentedOptionView }
        selectedIndex = index
        guard let selectedView = options[safe: index] else { return }
        options.forEach { $0.isSelected = $0 == selectedView }
        updateOptionBottomBarPosition()
    }
}

// MARK: - Private functions
private extension SegmentedView {
    // UI
    func setupUI() {
        setupScrollView()
        setupStackView()
        setupOptionBottomBar()
        updateUI()
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalToSuperview()
        }
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .center
    }
    
    func resetStackView() {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    func setupOptionBottomBar() {
        stackView.addSubview(optionBottomBar)
    }
    
    /// 根據數據源配置選項視圖，並將其添加到堆疊視圖中。
    func layoutOptions() {
        // 生成選項
        var subViews: [UIView] = []
        let totalOptionNumber = dataSource?.numberOfOptions(in: self) ?? 0
        for index in 0 ..< totalOptionNumber {
            let option = dataSource?.segmentedView(self, titleForOptionAt: index) ?? SegmentedOptionView()
            option.isSelected = index == selectedIndex
            option.configuration = configuration
            option.delegate = self
            subViews.append(option)
            
            if configuration.isNeedDisplayDivider, index < totalOptionNumber - 1 {
                // 加入分隔線
                let divider = UIView()
                divider.backgroundColor = configuration.dividerColor
                divider.snp.makeConstraints({
                    $0.width.equalTo(1)
                    $0.height.equalTo(configuration.dividerHeight)
                })
                subViews.append(divider)
            }
        }
        
        stackView.addArrangedSubviews(subViews)
        let options = subViews.filter({ $0 is SegmentedOptionView })
        // 設定寬度
        let automatic = SegmentedViewConfiguration.automaticWidth
        let equalWidth = SegmentedViewConfiguration.equalWidth
        for option in options.enumerated() {
            // 優先讀取 delegate
            var width = delegate?.segmentedView(self, optionWidthAt: option.offset) ?? automatic
            // 第二優先讀取 configuration
            if width == automatic {
                width = configuration.optionWidth
            }
            if width == automatic {
                continue
            } else if width == equalWidth {
                option.element.snp.makeConstraints({ make in
                    let ratio = 1.0 / Float(totalOptionNumber)
                    make.width.equalTo(self.snp.width).multipliedBy(ratio)
                })
            } else {
                option.element.snp.makeConstraints({ $0.width.equalTo(width) })
            }
            option.element.snp.makeConstraints({ $0.height.equalTo(stackView) })
        }
    }
    
    /// 更新 UI，重新載入數據
    func updateUI() {
        stackView.spacing = configuration.optionsSpacing
        optionBottomBar.backgroundColor = configuration.optionBottomBarColor
        optionBottomBar.isHidden = configuration.optionBottomBarIsHidden
        reloadData()
    }
    
    func bindConfiguration() {
        configurationDisposeBag = DisposeBag()
        _configuration.configChanged
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                updateUI()
            })
            .disposed(by: configurationDisposeBag)
    }
    
    /// 更新底部滑棒位置
    func updateOptionBottomBarPosition(isNeedAnimated: Bool = false) {
        let options = stackView.arrangedSubviews.compactMap { $0 as? SegmentedOptionView }
        guard let selectedOption = options[safe: selectedIndex] else { return }
        optionBottomBar.snp.remakeConstraints { make in
            make.width.equalTo(configuration.optionBottomBarWidth)
            make.height.equalTo(2)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(selectedOption)
        }
        guard isNeedAnimated else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.stackView.layoutIfNeeded()
        })
    }
}

// MARK: - SegmentedOptionViewDelegate
extension SegmentedView: SegmentedOptionViewDelegate {
    func selectSegmentedOptionView(_ view: SegmentedOptionView) {
        let options = stackView.arrangedSubviews.compactMap { $0 as? SegmentedOptionView }
        guard let index = options.firstIndex(of: view) else { return }
        if let delegate, !delegate.shouldSegmentedView(self, selectOptionAt: index) {
            return
        }
        options.forEach { $0.isSelected = $0 == view }
        selectedIndex = index
        updateOptionBottomBarPosition(isNeedAnimated: true)
        delegate?.segmentedView(self, didSelectOptionAt: index)
    }
}
