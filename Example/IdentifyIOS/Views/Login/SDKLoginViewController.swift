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
    
//    let manager = IdentifyManager.shared
    
    var deepLinkId = ""
    
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var appLogo: UIImageView!
    
    @IBOutlet weak var identTxtField: UITextField!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var inputHolderView: UIView!
    @IBOutlet weak var submitHolderView: UIView!
    @IBOutlet weak var submitLabel: GradientLabel!
    @IBOutlet weak var connectInfoLabel: UILabel!
    
    public init(deepLinkIds: String, hostType: HostType?) {
        self.deepLinkId = deepLinkIds
//        manager.selectedHost = hostType
        super.init(nibName: nil, bundle: nil)
        manager.setupUrls()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your App"
        identTxtField.text = deepLinkId
        translate()
        addGradientBackground(view: rootView)
        setupViews()
        manager.loadingDelegate = self
        listenNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideLoader()
    }
    
    @objc func listenNotification() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("UserLoggedIn"), object: nil)
    }
    
    @objc func userLoggedIn() {
        let controller = SDKCallWaitScreenController.instantiate()
        if #available(iOS 13.0, *) {
            controller.isModalInPresentation = true
        }
        controller.manager = self.manager
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if #available(iOS 13, *) {
                UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: false, completion: nil)
            } else {
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.present(controller, animated: false, completion: nil)
            }
        }
    }
    
    func setupViews() {
        appLogo.image = GlobalConstants.appLogo
        inputHolderView.layer.borderWidth = 1
        inputHolderView.layer.borderColor = #colorLiteral(red: 0.94, green: 0.8, blue: 0.09, alpha: 1)
        inputHolderView.layer.cornerRadius = 8
        
        submitHolderView.layer.cornerRadius = 12
        helpBtn.layer.cornerRadius = 12
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
    
    func checkNFC() {
        let nfcAvailable = NFCReaderSession.readingAvailable
        manager.nfcEnabled = nfcAvailable
        let next = SDKCallWaitScreenController.instantiate()
        next.manager = manager
        navigationController?.pushViewController(next, animated: true)
    }
}

extension SDKLoginViewController: LoadingViewDelegate {
    func hideAllLoaders() {
        self.hideLoader()
    }
    
}
