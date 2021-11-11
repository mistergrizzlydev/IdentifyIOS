//
//  AppDelegate.swift
//  IdentifyIOS
//
//  Created by emir@beytekin.net on 06/08/2021.
//  Copyright (c) 2021 emir@beytekin.net. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import IdentifyIOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var deeplinkUrl = ""
    
    let userDefaults = UserDefaults.standard
    
    let cacheManager = UserDefaultService.shared
    
    let manager = IdentifyManager.shared
    
    var hostType: HostType? = .identifyTr
    
    var appType: AppType? = .demoApp
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool { // http deep link
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                let url = userActivity.webpageURL!
                let identId = url.absoluteURL.lastPathComponent
                let host = url.absoluteURL.host
                if host == "admin.kimlikbasit.com" {
                    self.hostType = .kimlikBasit
                } else {
                    self.hostType = .identifyTr
                }
                self.deeplinkUrl = identId
                openMainScreen()
            }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool { // hnet:// dlink
        openMainScreen()
        return false
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        IQKeyboardManager.shared.enable = true
        openMainScreen()
        return true
    }
    
    func openMainScreen() {
        UIApplication.shared.isIdleTimerDisabled = true
        window = UIWindow.init(frame: UIScreen.main.bounds)
        var mainViewController = UIViewController()
        
        switch appType {
        case .demoApp:
            GlobalConstants.appLogo = UIImage(named: "identifyTR")!
            GlobalConstants.nfcErrorMaxCount = 3
            manager.addModules(module: [.nfc, .livenessDetection, .selfie, .videoRecord, .idCard, .signature, .speech, .addressConf])
            manager.verificationCardType = .all
            if self.deeplinkUrl != "" {
                mainViewController = SDKLoginViewController(deepLinkIds: deeplinkUrl, hostType: hostType)
            } else {
                mainViewController = SDKLoginViewController(deepLinkIds: "", hostType: hostType)
            }
        case .onlySDK:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
            mainViewController = initialViewController
        default:
            return
        }
        
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.setNavigationBarHidden(true, animated: true)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()

    }


}

