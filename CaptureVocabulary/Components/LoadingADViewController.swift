//
//  LoadingADViewController.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/3/6.
//

import UIKit

class LoadingADViewController: UIViewController {
    var placeholder: UIView? = UIView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        stackView.addArrangedSubview(activityIndicator)
        
        stackView.addArrangedSubview(stackView.padding(gap: 30))
        
        guard let placeholder else { return }
        stackView.addArrangedSubview(placeholder)
        placeholder.snp.makeConstraints { make in
            make.size.equalTo(AdsManager.shared.middleBannerAdSize.size)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AdsManager.shared.middleBannerRootViewController = self
    }
    
    private let stackView = UIStackView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
}

extension LoadingADViewController: AdSimpleBannerPowered {
    
}
