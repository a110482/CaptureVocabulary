//
//  UIViewController+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/2/12.
//

import UIKit

private var loadingWindow: UIWindow?

extension UIViewController {
    func startLoadingAnimate() {
        guard loadingWindow == nil else { return }

        let windowScene = view.window?.windowScene
        let window = UIWindow(windowScene: windowScene!)
        window.frame = UIScreen.main.bounds
        
        let loadingViewController = LoadingADViewController()
        
        window.rootViewController = loadingViewController
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        
        loadingWindow = window
    }
    
    func stopLoadingAnimate() {
        loadingWindow?.isHidden = true
        loadingWindow = nil
    }
}
