//
//  AdsManager.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/26.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency

protocol AdSimpleBannerPowered: UIViewController {
    var placeholder: UIView? { get }
    func addBannerToAdsPlaceholder(_ banner: UIView)
}

extension AdSimpleBannerPowered {
    func addBannerToAdsPlaceholder(_ banner: UIView) {
        placeholder?.addSubview(banner)
    }
}

final class AdsManager : NSObject {
    static let shared = AdsManager()
    
    let adSize: GADAdSize = {
        let width = UIScreen.main.bounds.width
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        return adSize
    }()

    var loadedSimpleBannerAd = false

    private var bannerView: GADBannerView?
    weak var rootViewController: UIViewController? {
        didSet {
            setupSimpleBannerAdsIfPossible()
        }
    }

    private override init() {
        super.init()
        GADMobileAds.sharedInstance().start()
        configureSimpleBanner()
    }

    private func configureSimpleBanner() {
        bannerView = GADBannerView(adSize: adSize)
        bannerView?.delegate = self
        bannerView?.adUnitID = AppParameters.shared.model.adUnitID
    }

    private func setupSimpleBannerAdsIfPossible() {
        if ATTrackingManager.trackingAuthorizationStatus != .authorized {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
        }
        assert(self.bannerView != nil, "WTF: simple banner has not been configured (call Ads.configure() before any usage)!")
        if let root = rootViewController as? AdSimpleBannerPowered {
            if let banner = self.bannerView {
                banner.rootViewController = root
                if !loadedSimpleBannerAd {
                    banner.load(GADRequest())
                } else {
                    root.addBannerToAdsPlaceholder(banner)
                }
            }
        }
    }

}

extension AdsManager: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        loadedSimpleBannerAd = true
        if let root = rootViewController as? AdSimpleBannerPowered {
            root.addBannerToAdsPlaceholder(bannerView)
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        Log.debug(error.localizedDescription)
    }
}
