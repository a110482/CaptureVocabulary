//
//  UIButton+Ext.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/5/8.
//

import UIKit

extension UIButton.Configuration {
    static let speakerButtonConfiguration: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "speaker.wave.3")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13)
        config.imagePadding = 0
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 5, leading: 5, bottom: 5, trailing: 5)
        config.baseBackgroundColor = UIColor(hexString: "EBF1FF")
        config.baseForegroundColor = UIColor(hexString: "3D5CFF")
        return config
    }()
}
