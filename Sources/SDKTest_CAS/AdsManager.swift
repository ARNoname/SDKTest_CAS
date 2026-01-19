
import Foundation
import SwiftUI
import Combine

// import AppTrackingTransparency

#if canImport(CleverAdsSolutions)
import CleverAdsSolutions

@MainActor
public class AdsManager: NSObject, ObservableObject {
    
    @MainActor public static let shared = AdsManager()
    public var casID: String
    
    // Internal properites for logic
    private var manager: CASMediationManager? 
    private var interstitial: CASInterstitial?
    private var rewarded: CASRewarded?

    @Published public var isInterstitialReady: Bool = false
    @Published public var isRewardedReady: Bool = false
    
    private var onRewardCompletion: ((Bool) -> Void)?
    
    // For Custom Ad
    private var onCustomAdDismiss: (() -> Void)?
    
    public override init(casID: String) {
        super.init()
        AdsManager.shared.casID = casID
    }
    
    public func configure() {
        CAS.settings.debugMode = true
        
        // Initialize SDK
        self.manager = CAS.buildManager()
#if DEBUG
            .withTestAdMode(true)
#endif
            .withCompletionHandler { config in
                if let error = config.error {
                    print("🔴 CAS Init Error: \(error)")
                } else {
                    print("🟢 CAS Init Success")
                }
            }
            .create(withCasId: AdsManager.shared.casID)
        
        // Initialize Interstitial
        let interstitial = CASInterstitial(casID: AdsManager.shared.casID)
        interstitial.delegate = self
        interstitial.loadAd()
        self.interstitial = interstitial
        
        // Initialize Rewarded
        let rewarded = CASRewarded(casID: AdsManager.shared.casID)
        rewarded.delegate = self
        rewarded.loadAd()
        self.rewarded = rewarded
    }
    
    public func showInterstitial(from viewController: UIViewController) {
        if let interstitial = interstitial, interstitial.isAdLoaded {
            interstitial.present(from: viewController)
        } else {
            print("⚠️ Interstitial not ready")
        }
    }
    
    public func showRewarded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        if let rewarded = rewarded, rewarded.isAdLoaded {
            self.onRewardCompletion = completion
            rewarded.present(from: viewController) { _ in
                // User earned reward
            }
        } else {
            completion(false)
        }
    }
    
    // MARK: - Custom Ad Logic
    
    public func showMyWebAd(from viewController: UIViewController, url: String) {
        guard let validUrl = URL(string: url) else { return }
        
        let webVC = WebViewController(url: validUrl)
        webVC.delegate = self
        webVC.modalPresentationStyle = .fullScreen
        
        viewController.present(webVC, animated: true)
    }
    
    // Hybrid: Try CAS, then fallback to Custom
    public func showInterstitialOrMyAd(from viewController: UIViewController, myAdUrl: String) {
        if let interstitial = interstitial, interstitial.isAdLoaded {
            interstitial.present(from: viewController)
        } else {
            print("⚠️ CAS not ready, displaying custom ad")
            showMyWebAd(from: viewController, url: myAdUrl)
        }
    }
    
    private func checkAdStatus() {
        DispatchQueue.main.async {
            self.isInterstitialReady = self.interstitial?.isAdLoaded ?? false
            self.isRewardedReady = self.rewarded?.isAdLoaded ?? false
        }
    }
}

// MARK: - CAS Delegate
 extension AdsManager: @MainActor CASScreenContentDelegate {
    
      public func screenAdDidLoadContent(_ ad: CASScreenContent) {
        checkAdStatus()
    }
    
       public func screenAd(_ ad: CASScreenContent, didFailToLoadWithError error: CASError) {
        checkAdStatus()
    }
    
       public func screenAdWillPresentContent(_ ad: CASScreenContent) {
        // Ad started showing
    }
    
       public func screenAd(_ ad: CASScreenContent, didFailToPresentWithError error: CASError) {
        if ad is CASRewarded {
             onRewardCompletion?(false)
             onRewardCompletion = nil
        }
        checkAdStatus()
    }
    
      public func screenAdDidDismissContent(_ ad: CASScreenContent) {
        if ad is CASRewarded {
            if onRewardCompletion != nil {
                 onRewardCompletion?(false) 
                 onRewardCompletion = nil
            }
        }
        checkAdStatus()
    }
}

// MARK: - Custom Ad Delegate
 extension AdsManager: WebViewControllerDelegate {
       public func webViewControllerDidLoad(_ controller: WebViewController) {
        print("✅ Custom Ad Loaded")
    }
    
       public func webViewControllerDidFinish(_ controller: WebViewController) {
        print("✅ Custom Ad Closed")
    }
}
#endif
