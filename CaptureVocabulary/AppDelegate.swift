//
//  AppDelegate.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/13.
//

import UIKit
import GoogleMobileAds
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // log 設定
        Log.enabled = true
        Log.minLevel = .debug
        
        // 初始化繁簡翻譯引擎
        let _ = OpenCCConverter.shared.converter
        
        // google 廣告設定
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        })
        #if DEBUG
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
            [ "cb559a1d2a23be3dcf18b870e5ff9c2d" ]
        #endif
        
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

