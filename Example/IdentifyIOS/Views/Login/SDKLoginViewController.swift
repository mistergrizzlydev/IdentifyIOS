//
//  SDKLoginViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 1.02.2021.
//

import UIKit
import CoreNFC
import Starscream
import IdentifyIOS

class SDKLoginViewController: SDKBaseViewController {
    
    
    var deepLinkId = ""
    
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var buildNoLbl: UILabel!
    
    @IBOutlet weak var identTxtField: UITextField!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var inputHolderView: UIView!
    @IBOutlet weak var submitHolderView: UIView!
    @IBOutlet weak var submitLabel: GradientLabel!
    @IBOutlet weak var connectInfoLabel: UILabel!
//    var floatingButtonController: FloatingButtonController?

    public init(deepLinkIds: String, hostType: HostType?) {
        self.deepLinkId = deepLinkIds
        let m = IdentifyManager.shared
        m.selectedHost = hostType
        super.init(nibName: nil, bundle: nil)
        m.setupUrls()
        manager = m
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Identify"
        identTxtField.text = deepLinkId
        translate()
        addGradientBackground(view: rootView)
        setupViews()
        setupManager()
        checkPermissions()
        buildNoLbl.text = Bundle.main.buildVersionNumber
//        floatingButtonController = FloatingButtonController()
//        floatingButtonController?.button.addTarget(self, action: #selector(floatingButtonWasTapped), for: .touchUpInside)
    }
    
    func setupManager() {
        manager.loadingDelegate = self
        manager.enableSignLang = true
        manager.verificationCardType = .all
        // KPS sisteminiz varsa kullanıcıya ait verileri eklediğiniz takdirde MRZ tarama ekranı açılmayıp NFC ekranı açılacaktır
        //  manager.mrzBirthDate = "01.12.1950"
        //  manager.mrzValidDate = "13.085.2029"
        //  manager.mrzDocumentNo = "B26C75239"
    }
    
    func checkPermissions() { // kullanıcının kamera - mikrafon ve konuşma iznini kontrol eder, gereksizse kapatabilirsiniz.
        if manager.permissionsAllowed() == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let next = SDKPermissionsViewController.instantiate()
                next.permissionDelegate = self
                next.modalPresentationStyle = .fullScreen
                self.present(next, animated: true, completion: nil)
            }
        } else {
            debugPrint("izinler ok")
        }
    }
    
    @objc func floatingButtonWasTapped() {
        let alert = UIAlertController(title: "Warning", message: "Don't do that!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Sorry…", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listenNotification()
        self.hideLoader()
    }
    
    @objc func listenNotification() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(hideAllLoaders), name: Notification.Name("hideLoader"), object: nil)
        nc.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("UserLoggedIn"), object: nil)
    }
    
    func setupViews() {
        appLogo.image = GlobalConstants.appLogo
        inputHolderView.layer.borderWidth = 1
        inputHolderView.layer.borderColor = #colorLiteral(red: 0.94, green: 0.8, blue: 0.09, alpha: 1)
        inputHolderView.layer.cornerRadius = 8
        
        submitHolderView.layer.cornerRadius = 12
        helpBtn.layer.cornerRadius = 12
//        submitLabel.gradientColors = [UIColor.init(red: 0.15, green: 1, blue: 0.88, alpha: 1).cgColor, UIColor.init(red: 0.31, green: 0.18, blue: 0.85, alpha: 1).cgColor]
        submitHolderView.addShadow()
        identTxtField.attributedPlaceholder = NSAttributedString(string: "Ident-id", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named: "Light Gray") ?? .lightGray])
    }
    
    func translate() {
        submitLabel.text = self.translate(text: .connect)
        connectInfoLabel.text = self.translate(text: .connectInfo)
    }

    @IBAction func onBoardAct(_ sender: Any) {
        let next = SDKOnBoardingViewController()
        let nc = UINavigationController(rootViewController: next)
        nc.modalPresentationStyle = .fullScreen
        nc.setNavigationBarHidden(true, animated: true)
        self.present(nc, animated: true)
    }
    
    @IBAction func submitAct(_ sender: UIButton) {
        if identTxtField.text != "" {
            self.showLoader()
            manager.userToken = identTxtField.text ?? ""
            let _ = manager.connectToRoom()
        }
    }
    
    @IBAction func modulesSettingsAct(_ sender: Any) {
        let controller = SDKModulesListViewController.instantiate()
        controller.manager = self.manager
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func networkSettingsAct(_ sender: Any) {
        let controller = SDKNetworkSettingsViewController.instantiate()
        controller.delegate = self
//        controller.manager = self.manager
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func checkNFC() {
        let nfcAvailable = NFCReaderSession.readingAvailable
        manager.nfcEnabled = nfcAvailable
        let next = SDKCallWaitScreenController.instantiate()
        next.manager = manager
        navigationController?.pushViewController(next, animated: true)
    }
        
    @objc func userLoggedIn() {
        let controller = SDKCallWaitScreenController.instantiate()
        if #available(iOS 13.0, *) {
          controller.isModalInPresentation = true
        }
        controller.manager = self.manager
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if #available(iOS 13, *) {
                self.present(controller, animated: true, completion: nil)
            } else {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

extension SDKLoginViewController: LoadingViewDelegate {
    @objc func hideAllLoaders() {
        self.hideLoader()
    }
    
}

extension SDKLoginViewController: PermissionViewDelegate {
    
    func permissionCompleted() {
        debugPrint("permission delegate ok")
    }
    
}

extension SDKLoginViewController: NetworkUpdateDelegate {
    
    func networkUpdate() {
        let cache = UserDefaultService.shared
        let stun1 = cache.getValue(key: "stunServer")
        let stun2 = cache.getValue(key: "stunServer2")
        URLConstants.baseAPIUrl = cache.getValue(key: "baseAPIUrl")
        URLConstants.webSocketUrl = cache.getValue(key: "socketUrl")
        URLConstants.stunServers = [stun1, stun2]
        URLConstants.stunUsername = cache.getValue(key: "stunUser")
        URLConstants.stunPassword = cache.getValue(key: "stunPass")
        manager.selectedHost = .identifyTr
        manager.setupUrls()
        buildNoLbl.text = manager.baseAPIUrl
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "1.0.0")"
    }
}
