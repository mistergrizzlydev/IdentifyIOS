//
//  BaseViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 13.02.2021.
//

import UIKit
import CoreNFC
import ARKit
import IdentifyIOS
import Lottie

protocol CallCompletedDelegate:class {
    func completed()
}

class SDKBaseViewController: UIViewController {
    
    let languageManager = SDKLanguageManager.shared
    let colorManager = SDKColorManager.shared
    let userDefaults = UserDefaultService.shared
    var manager = IdentifyManager.shared
    var animationView: AnimationView?
    var nfcAvailable: Bool = {
        if #available(iOS 13.0, *) {
            return NFCNDEFReaderSession.readingAvailable && NFCTagReaderSession.readingAvailable
        } else {
            return false
        }
    }()
    
    var arFaceAvailable: Bool = {
        return ARFaceTrackingConfiguration.isSupported
    }()
    
    deinit {
        debugPrint("deinit view controller : \(self)")
    }
    
    var addSkipModules:Bool? = true
    let skipButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("viewDidLoad : \(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func addSkipModulesButton() {
        skipButton.setTitle("Tüm aşamaları atla ve temsilciye bağlan", for: .normal)
        skipButton.frame = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 50)
        skipButton.backgroundColor = .green
        skipButton.addTarget(self, action: #selector(skipAllModules), for: .touchUpInside)
        self.view.addSubview(skipButton)
    }
    
    @objc func skipAllModules() {
        let man = IdentifyManager.shared
        man.identfiyModules.removeAll()
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "skipAllModules"), object: nil, userInfo: nil)
        })
    }
        
    func addGradientBackground(view: UIView) {
        colorManager.backgroundGradient.frame = view.bounds
        colorManager.backgroundGradient.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        colorManager.backgroundGradient.position = view.center
        view.layer.insertSublayer(colorManager.backgroundGradient, at: 0)
    }
    
    func addBlackGradient(view: UIView) {
        let blackView = colorManager.backgroundBlackGradient
        blackView.frame = view.bounds
        blackView.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        blackView.position = view.center
        DispatchQueue.main.async {
            view.layer.insertSublayer(blackView, at: 0)
        }
    }
    
    func translate(text: Keywords) -> String {
        return languageManager.translate(key: text)
    }
    
    func popupAlert(title: String? = "Kimlik Basit", message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?], isRootAlert: Bool? = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        
        if isRootAlert ?? false {
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        } else {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showPopUp(image: UIImage, desc: String) {
        SDKPopUpActionViewController.showPopup(parentVC: self,infoImage: image, infoText: desc)
    }
    
    func showAniPopUp(anim: String, desc: String) {
        SDKPopUpActionViewController.showAnimationPopup(parentVC: self, animation: anim, infoText: desc)
    }
    
    // for lottie
    
    func createAnimationView(animationName: String, loop: Bool) -> AnimationView {
        let animationView = AnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        if !loop {
            animationView.loopMode = .playOnce
        } else {
            animationView.loopMode = .loop
        }
        return animationView
    }
    
    @objc func setAnimation(view: UIView, name: String, loop: Bool) {
        if let animateTag = view.viewWithTag(100) {
            animateTag.removeFromSuperview()
        }
        animationView = self.createAnimationView(animationName: name, loop: loop)
        animationView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        animationView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        animationView?.tag = 100
        self.animationView?.reloadImages()
        view.insertSubview(self.animationView!, at: 0)
        self.animationView?.play()
        self.animationView?.backgroundColor = .clear
        self.animationView?.backgroundBehavior = .pauseAndRestore
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (_) in
            self.animationView?.play()
        }
    }
    
    func openInfoScreen(page: SdkModules?) {
        let nextVC = SDKInformationViewController.instantiate()
        nextVC.activeScreen = page
        nextVC.modalTransitionStyle = .crossDissolve
        nextVC.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            nextVC.isModalInPresentation = true
        }
        DispatchQueue.main.async {
            self.present(nextVC, animated: true, completion: nil)
        }
    }
}

var vSpinner : UIView?

extension UIViewController {
    
    func showLoader() {
        let spinnerView = UIView.init(frame: self.view.frame)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

extension NotificationCenter {
    
    public static func AddNotification(_ observer: Any, name: Notification.Name, selector: Selector, object: Any? = nil) {
        self.default.addObserver(observer, selector: selector, name: name, object: object)
    }
    
    public static func RemoveNotification(_ observer: Any, name: Notification.Name) {
        self.default.removeObserver(observer, name: name, object: nil)
    }
    
    public static func PostNotification(_ name: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
        self.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
}

extension UIApplication {
    public class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}
