//
//  AdsManager.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/26.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import RxSwift
import RxCocoa

/// 顯示橫幅廣告的 ViewController 需要遵循這個協議
protocol AdSimpleBannerPowered: UIViewController {
    var placeholder: UIView? { get }
    func addBannerToAdsPlaceholder(_ banner: UIView)
}

extension AdSimpleBannerPowered {
    func addBannerToAdsPlaceholder(_ banner: UIView) {
        placeholder?.addSubview(banner)
    }
}

protocol AdInterstitialPresentable: UIViewController {
    func presentInterstitialAdIfPossible()
}

final class AdsManager : NSObject {
    static let shared = AdsManager()
    private(set) lazy var output = Output(self)
    weak var bottomBannerRootViewController: (any AdSimpleBannerPowered)? {
        didSet {
            setupSimpleBannerAdsIfPossible()
        }
    }
    weak var middleBannerRootViewController: (any AdSimpleBannerPowered)?

    private override init() {
        super.init()
        GADMobileAds.sharedInstance().start()
        configureBottomBanner()
        configureMiddleBanner()
        // (暫時停用全頁廣告)
//        prepareLoadedInterstitialAdIfNeeded()
//        observeSystemEvents()
    }
    
    private var isLoadedSimpleBannerAd = false
    /// 底部橫幅廣告
    private var bottomBannerView: GADBannerView?
    private var middleBannerView: GADBannerView?
    private var interstitial: GADInterstitialAd?
    private var reloadInterstitialAdTimer: Timer?
    /// 是否已經看完廣告 (第一版先不要放廣告)
    private let isPresentInterstitialAd = BehaviorRelay(value: true)
    /// 廣告剛剛關閉
    private let adDidDismissFullScreenContent = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
}

private extension AdsManager {
    /// 設定底部橫幅廣告
    func configureBottomBanner() {
        bottomBannerView = GADBannerView(adSize: bottomBannerAdSize)
        bottomBannerView?.delegate = self
        bottomBannerView?.adUnitID = AppParameters.shared.model.adUnitID
    }
    
    /// 設定中等橫幅廣告
    func configureMiddleBanner() {
        middleBannerView = GADBannerView(adSize: middleBannerAdSize)
        middleBannerView?.delegate = self
        middleBannerView?.adUnitID = AppParameters.shared.model.adMiddenUnitID
    }
    
    /// 呈現橫幅廣告
    func setupSimpleBannerAdsIfPossible() {
        if ATTrackingManager.trackingAuthorizationStatus != .authorized {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
        }
        assert(self.bottomBannerView != nil, "WTF: simple banner has not been configured (call Ads.configure() before any usage)!")
        guard let root = bottomBannerRootViewController else { return }
        guard let banner = self.bottomBannerView else { return }
        banner.rootViewController = root
        if !isLoadedSimpleBannerAd {
            banner.load(GADRequest())
        } else {
            root.addBannerToAdsPlaceholder(banner)
        }
    }
    
    /// 準備插頁廣告(暫時停用全頁廣告)
//    func prepareLoadedInterstitialAdIfNeeded() {
//        resetAutoReloadTimer()
//        interstitial = nil
//        Task {
//            do {
//                interstitial = try await GADInterstitialAd.load(
//                    withAdUnitID: AppParameters.shared.model.adPageUnitID,
//                    request: GADRequest())
//                
//                interstitial?.fullScreenContentDelegate = self
//            } catch {
//                let errorMessage = "Failed to load interstitial ad with error: \(error.localizedDescription)"
//                assertionFailure(errorMessage)
//            }
//        }
//    }
    
    /// 重設自動重載廣告的 timer (暫時停用全頁廣告)
//    func resetAutoReloadTimer() {
//        reloadInterstitialAdTimer?.invalidate()
//        // google 插頁廣告一小時後到期，設定 50 分鐘刷新
//        let timeInterval: TimeInterval = 50 * 60
//        reloadInterstitialAdTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { _ in
//            self.prepareLoadedInterstitialAdIfNeeded()
//        })
//    }
    
    /// 進入前景就重新獲取廣告(暫時停用全頁廣告)
//    func observeSystemEvents() {
//        UIApplication.rx.didBecomeActive.subscribe(onNext: { _ in
//            self.prepareLoadedInterstitialAdIfNeeded()
//        }).disposed(by: disposeBag)
//    }
}

extension AdsManager {
    class Output: RxOutput<AdsManager> {
        var isPresentInterstitialAd: Observable<Bool> {
            target.isPresentInterstitialAd.asObservable()
        }
        
        var isPresentInterstitialAdValue: Bool {
            target.isPresentInterstitialAd.value
        }
        
        var adDidDismissFullScreenContent: Observable<Void> {
            target.adDidDismissFullScreenContent.asObservable()
        }
    }
    
    var bottomBannerAdSize: GADAdSize {
        let width = UIScreen.main.bounds.width
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        return adSize
    }
    
    var middleBannerAdSize: GADAdSize {
        let width = UIScreen.main.bounds.width
        let adSize = GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(width, 400)
        return adSize
    }
    
    // (暫時停用全頁廣告)
//    func present(vc: UIViewController) {
//        // 檢查是否有還沒有的廣告獎勵
//        guard !isPresentInterstitialAd.value else { return }
//        // 檢查是否廣告已下載完成
//        guard let interstitial else { return }
//        interstitial.present(fromRootViewController: vc)
//    }
    
    /// 廣告獎勵已使用(暫時停用全頁廣告)
//    func interstitialAdRewardUsed() {
//        isPresentInterstitialAd.accept(false)
//    }
}

// MARK: - 橫幅廣告 delegate
extension AdsManager: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if bannerView === bottomBannerView {
            isLoadedSimpleBannerAd = true
            guard let root = bottomBannerRootViewController else { return }
            root.addBannerToAdsPlaceholder(bannerView)
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        Log.debug(error.localizedDescription)
    }
}

// MARK: - 插頁廣告 delegate(暫時停用全頁廣告)
//extension AdsManager: GADFullScreenContentDelegate {
//    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
//        // 讀取廣告錯誤
//    }
//    
//    /// 廣告已經顯示
//    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        isPresentInterstitialAd.accept(true)
//        prepareLoadedInterstitialAdIfNeeded()
//    }
//    
//    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        adDidDismissFullScreenContent.accept(())
//    }
//}
