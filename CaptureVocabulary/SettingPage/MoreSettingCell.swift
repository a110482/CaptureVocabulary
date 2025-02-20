//
//  MoreSettingCell.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/26.
//

import UIKit
import RxSwift
import RxCocoa

class MoreSettingCell: UITableViewCell, SettingPageCellProtocol {
    static let type: SettingPageCellType = .moreSetting
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
        addTapEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func config(cellModel: any SettingPageCellModelProtocol) {
        guard let cellModel = cellModel as? MoreSettingCellModel else {
            assertionFailure()
            return
        }
        resettableDisposeBag = DisposeBag()
        bindTapGesture(cellModel: cellModel)
        titleLabel.text = cellModel.moreSettingType.title
    }
    
    private let titleLabel = UILabel()
    private let rightArrowView = UIImageView()
    private var resettableDisposeBag = DisposeBag()
    private let tapGesture = UITapGestureRecognizer()
}

private extension MoreSettingCell {
    func configUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.height.equalTo(40).priority(999)
            make.top.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(rightArrowView)
        rightArrowView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
            make.right.equalToSuperview().offset(-20)
        }
        rightArrowView.image = UIImage(systemName: "chevron.right")?
            .withRenderingMode(.alwaysTemplate)
        rightArrowView.tintColor = .gray
        rightArrowView.contentMode = .scaleAspectFit
    }
    
    func bindTapGesture(cellModel: MoreSettingCellModel) {
        tapGesture.rx.event.subscribe(onNext: { [weak cellModel] _ in
            guard let cellModel else { return }
            cellModel.didTapCell()
        }).disposed(by: resettableDisposeBag)
    }
    
    func addTapEvent() {
        addGestureRecognizer(tapGesture)
    }
}


// MARK: - SettingDatabaseBackupCellModel
class MoreSettingCellModel: SettingPageCellModelProtocol {
    let type: SettingPageCellType = .moreSetting
    
    let moreSettingType: SettingPageViewModel.MoreSettingType
    
    private(set) lazy var output = Output(self)
    
    init(moreSettingType: SettingPageViewModel.MoreSettingType) {
        self.moreSettingType = moreSettingType
    }
    
    func didTapCell() {
        tapCellEvent.accept(())
    }
    
    private let tapCellEvent = PublishRelay<Void>()
}

extension MoreSettingCellModel {
    class Output: RxOutput<MoreSettingCellModel> {
        var tapCellEVent: Observable<Void> { target.tapCellEvent.asObservable() }
    }
}
