//
//  MainViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 24.01.2021.
//

import UIKit
import NFCPassportReader
import QKMRZParser
import IdentifyIOS

protocol CallScreenDelegate:class {
    func acceptCall()
}

protocol SmsScreenDelegate:class {
    func smsTag(tag: String)
}

class SDKCallWaitScreenController: SDKBaseViewController {
    
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var waitScreen: UIView!
    @IBOutlet weak var thankYouLabel: UILabel!
    @IBOutlet weak var confView: UIView!
    @IBOutlet weak var myCam: UIView!
    @IBOutlet weak var customerCam: UIView!
    @IBOutlet weak var shapeLayer: UIView!
    @IBOutlet weak var shape2Layer: UIView!
    
    // waiting outlets
    @IBOutlet weak var waitingBackImg: UIImageView!
    @IBOutlet weak var waitingStackView: UIStackView!
    @IBOutlet weak var waitingDesc1: UILabel!
    @IBOutlet weak var waitingDesc2: UILabel!
    
    var manager = IdentifyManager.shared
    var layerArray = NSMutableArray()
    var alreadySkippedNFC = false
    let modulesEnum: SdkModules? = .waitScreen
    weak var smsStatusDelegate: SmsStatusDelegate?
    @IBOutlet weak var completedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0) {
            self.view.alpha = 0
        }
        backgroundConnectAction()
        self.appLogo.image = GlobalConstants.appLogo
        myCam.isHidden = true
        customerCam.isHidden = true
        translate()
        waitScreen.isHidden = false
        self.managerSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadModules), name: NSNotification.Name(rawValue: "skipAllModules"), object: nil) // tüm modülleri atlaması halinde tetiklenir
    }
    
    @objc func reloadModules() {
        checkModules()
    }
    
    func checkBackgroundMode() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        backgroundConnectAction()
    }
    
    func checkModules() {
        if manager.identfiyModules.count > 0 {
            let firstStack: Modules = manager.identfiyModules.first!
            switch firstStack.mValue {
            case .nfc:
                manager.sendCurrentScreen(screen: .nfc)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.openMrzScreen()
                }
            case .livenessDetection:
                manager.sendCurrentScreen(screen: .livenessDetection)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showHumanVerification()
                }
            case .selfie:
                manager.sendCurrentScreen(screen: .selfie)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showSelfieView()
                }
            case .videoRecord:
                manager.sendCurrentScreen(screen: .videoRecord)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showVideoRecorder()
                }
            case .idCard:
                manager.sendCurrentScreen(screen: .idCard)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showIDCardView()
                }
            case .signature:
                manager.sendCurrentScreen(screen: .signature)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showSignatureView()
                }
            case .speech:
                manager.sendCurrentScreen(screen: .speech)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showSpeechRecognitionView()
                }
            case .waitScreen:
                self.userDefaults.setBool(key: "modulesCompleted", value: true)
                manager.sendCurrentScreen(screen: .waitScreen)
                UIView.animate(withDuration: 0.3) {
                    self.view.alpha = 1
                }
            default:
                return
            }
        } else { // tüm modüller tamamlandı ve çağrı bekleme ekranına düştü
            self.userDefaults.setBool(key: "modulesCompleted", value: true)
            manager.sendCurrentScreen(screen: .waitScreen)
            UIView.animate(withDuration: 0.3) {
                self.view.alpha = 1
            }
        }
        
    }
    
    func backgroundConnectAction() { // arkaplana atıldığı zaman socket bağlantısı kopmaması için gerekli
        manager.connectToServer()
        manager.socket.onConnect = {
            self.manager.sendFirstSubscribe(socket: self.manager.socket!)
            self.setupCameras()
            self.checkModules()
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
    
    func translate() {
        
    }
    
    func showThankYouView() {
        waitingBackImg.isHidden = true
        waitingDesc1.isHidden = true
        waitingDesc2.isHidden = true
        thankYouLabel.isHidden = false
        completedBtn.isHidden = false
    }
    
    func showWaitingArea() {
        myCam.isHidden = true
        customerCam.isHidden = true
        waitScreen.isHidden = false
    }
    
    func managerSetup() {
        manager.delegate = self
    }
    
    func openMrzScreen() {
        if #available(iOS 13, *), self.nfcAvailable {
            let next = SDKNfcViewController.instantiate()
            next.modalPresentationStyle = .fullScreen
            next.delegate = self
            next.manager = manager
            let nextNC = UINavigationController(rootViewController: next)
            nextNC.modalPresentationStyle = .overFullScreen
            self.present(nextNC, animated: true)
        } else {
            print("not supported nfc")
            self.popupAlert(title: self.translate(text: .coreError), message: "Cihazınızda NFC desteği bulunmamaktadır, sıradaki işleme geçiliyor.", actionTitles: ["Tamam"], actions:[{ action1 in
                self.manager.sendNFCStatus(false)
                self.manager.identfiyModules.removeFirst()
                self.checkModules()
            }])
        }
        
    }
    
    func addCardCircle() {
        let cardSize = CGFloat(350)
        let midCardX = (self.myCam.bounds.midX - cardSize / 2)
        let midCardY = (self.myCam.bounds.midY - cardSize / 2) + cardSize / 2
        let cardBizer = UIBezierPath(roundedRect: CGRect(x: midCardX, y: midCardY, width: cardSize, height: 100), cornerRadius: 25)
        let cardShapeLayerPath = CAShapeLayer()
        cardShapeLayerPath.path = cardBizer.cgPath
        cardShapeLayerPath.fillColor = UIColor.clear.cgColor
        cardShapeLayerPath.strokeColor = UIColor.green.cgColor
        cardShapeLayerPath.lineWidth = 5.5
        layerArray.add(cardShapeLayerPath)
        shape2Layer.layer.addSublayer(cardShapeLayerPath)
        shape2Layer.isHidden = false
    }
    
    func addCircleToCenter() {
        let circleSize = CGFloat(350)
        let midX = self.myCam.bounds.midX - circleSize / 2
        let midY = (self.myCam.bounds.midY - circleSize / 2) - 100
        let asd = UIBezierPath(roundedRect: CGRect(x: midX, y: midY, width: circleSize, height: circleSize + 100), cornerRadius: 50)
        let shapeLayerPath = CAShapeLayer()
        shapeLayerPath.path = asd.cgPath
        shapeLayerPath.fillColor = UIColor.clear.cgColor
        shapeLayerPath.strokeColor = UIColor.green.cgColor
        shapeLayerPath.lineWidth = 5.5
        layerArray.add(shapeLayerPath)
        shapeLayer.layer.addSublayer(shapeLayerPath)
        shapeLayer.isHidden = false
    }
    
    func setupUI() {
        shapeLayer.isHidden = true
        self.view.backgroundColor = DesignConstants.waitScrBackgroundColor
        self.waitScreen.backgroundColor = DesignConstants.waitScrBackgroundColor
        self.view.backgroundColor = DesignConstants.waitScrBackgroundColor
        self.waitingBackImg.image = DesignConstants.waitScrBackgroundPhoto
        self.waitingDesc1.text = DesignConstants.waitScrDesc1LblText
        self.waitingDesc2.text = DesignConstants.waitScrDesc2LblText
        self.waitingDesc1.textColor = DesignConstants.waitScrDesc1LblColor
        self.waitingDesc2.textColor = DesignConstants.waitScrDesc2LblColor
        self.waitingDesc1.font = DesignConstants.waitScrDesc1FontFamily
        self.waitingDesc2.font = DesignConstants.waitScrDesc2FontFamily
        
        // thank you view
        self.thankYouLabel.text = DesignConstants.waitScrThankUText
        self.thankYouLabel.textColor = DesignConstants.waitScrThankULblColor
        self.thankYouLabel.font = DesignConstants.waitScrThankULblFontFamily
        self.completedBtn.setTitle(DesignConstants.waitScrCompleteBtnText, for: .normal)
        self.completedBtn.setTitleColor(DesignConstants.waitScrCompleteBtnTextColor, for: .normal)
        self.completedBtn.titleLabel?.font = DesignConstants.waitScrCompleteBtnTextFont
        
    }
    
    @IBAction func acceptAct(_ sender: Any) {
        manager.acceptCall()
    }
    
    func setupCameras() {
        let remoteVideoView = manager.webRTCClient.remoteVideoView()
        manager.webRTCClient.setupRemoteViewFrame(frame: CGRect(x: 0, y: 0, width: customerCam.frame.width, height: customerCam.frame.height))
        self.customerCam.addSubview(remoteVideoView)
        customerCam.layer.masksToBounds = true
        customerCam.layer.borderWidth = 3
        customerCam.layer.borderColor = UIColor.white.cgColor
        customerCam.layer.cornerRadius = 12
        customerCam.addShadow()
        
        let localVideoView = manager.webRTCClient.localVideoView()
        manager.webRTCClient.setupLocalViewFrame(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.myCam.addSubview(localVideoView)
    }
    
    func showHumanVerification() {
        let nextVC = HumanVerificationViewController.instantiate()
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.delegate = self
        self.present(nextVC, animated: false, completion: nil)
        /*
        if self.arFaceAvailable {
            let smiley = SmileViewController.instantiate()
            smiley.modalPresentationStyle = .fullScreen
            smiley.manager = self.manager
            smiley.delegate = self
            self.present(smiley, animated: true, completion: nil)
        } else {
            let oldSmiley = SDKSelfieViewController.instantiate()
            oldSmiley.selfieTypes = .oldPhoneFace
            oldSmiley.modalPresentationStyle = .fullScreen
            oldSmiley.manager = self.manager
            oldSmiley.delegate = self
            oldSmiley.oldDeviceSmileyDelegate = self
            self.present(oldSmiley, animated: true, completion: nil)
        }
        */
    }
    
    func showSelfieView() {
        let controller = SDKSelfieViewController.instantiate()
        controller.modalPresentationStyle = .fullScreen
        controller.selfieTypes = .selfie
        controller.manager = self.manager
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func showVideoRecorder() {
        let oldSmiley = SDKSelfieViewController.instantiate()
        oldSmiley.selfieTypes = .video
        oldSmiley.modalPresentationStyle = .fullScreen
        oldSmiley.manager = self.manager
        oldSmiley.delegate = self
        self.present(oldSmiley, animated: true, completion: nil)
    }
    
    func showIDCardView() {
        let controller = SDKSelfieViewController.instantiate()
        controller.modalPresentationStyle = .fullScreen
        controller.selfieTypes = .frontId
        controller.manager = self.manager
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func showSignatureView() {
        let controller = SDKSignatureViewController.instantiate()
        controller.manager = self.manager
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func showSpeechRecognitionView() {
        let controller = SDKSoundRecognitionViewController.instantiate()
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func removeCurrentModule() {
        if manager.identfiyModules.count > 0 {
            manager.identfiyModules.removeFirst()
            checkModules()
        }
    }

    @IBAction func closeWindowAct(_ sender: Any) {
        manager.socket.disconnect()
        self.dismiss(animated: true, completion: nil)
    }
}

extension SDKCallWaitScreenController: SoundRecognitionDelegate {
    
    func recognitionCompleted() {
        removeCurrentModule()
    }
    
}

extension SDKCallWaitScreenController: SelfieDelegate {
    
    func selfieCompleted() {
        removeCurrentModule()
    }
    
}

extension SDKCallWaitScreenController: SignatureDelegate {
    func signatureCompleted() {
        removeCurrentModule()
        manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadSignature")
    }
}

extension SDKCallWaitScreenController: SmileDelegate {
    
    func smileCompleted() {
        removeCurrentModule()
    }
    
}

extension SDKCallWaitScreenController: ScannerStatusDelegate {
    
    func nfcCompleted() {
        removeCurrentModule()
    }
    
    func nfcAvailable(status: Bool) {
        manager.sendNFCStatus(status)
    }
    
}

extension SDKCallWaitScreenController: CallScreenDelegate {
    
    func acceptCall() {
        myCam.isHidden = false
        customerCam.isHidden = false
        manager.acceptCall()
    }
}

extension SDKCallWaitScreenController: SmsScreenDelegate {
    
    func smsTag(tag: String) {
        manager.sendSmsTan(tan: tag)
    }
    
}


extension SDKCallWaitScreenController: IdentifyListenerDelegate {
    
    func openWarningCircle() {
        addCircleToCenter()
    }
    
    func closeWarningCircle() {
        shapeLayer.isHidden = true
    }
    
    func openCardCircle() {
        addCardCircle()
    }
    
    func closeCardCircle() {
        shape2Layer.isHidden = true
    }
    
    func skipNFC() { // panelden nfc iptal etme talebi
        manager.sendNFCStatus(false)
        if !alreadySkippedNFC {
            self.dismiss(animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.alreadySkippedNFC = true
                    self.removeCurrentModule()
                }
            }
        }
    }
    
    func approvedSms(stats: Bool) { // sms kodu doğrulama
        if stats {
            self.dismiss(animated: false, completion: nil)
        } else {
            smsStatusDelegate?.isCompleted(status: false)
        }
    }
    
    func incomingCall() { // panelden gelen çağrı isteği
        let callScreenVC = CallScreenViewController.instantiate()
        callScreenVC.delegate = self
        callScreenVC.modalPresentationStyle = .overFullScreen
        self.present(callScreenVC, animated: true, completion: nil)
        waitScreen.isHidden = true
    }
    
    func endCall() { // kullanıcı 50 sn boyunca çağrıyı yanıtlamadı
        manager.socket.disconnect()
        self.dismiss(animated: true, completion: nil)
    }
    
    func comingSms() { // sms geldi
        let smsController = SmsScreenViewController.instantiate()
        smsController.delegate = self
        smsStatusDelegate = smsController
        smsController.modalPresentationStyle = .overFullScreen
        self.present(smsController, animated: true, completion: nil)
    }
    
    func openNFC() {
        
    }
    
    func terminateCall() { // görüşme sonlandı
        manager.socket.disconnect()
        self.userDefaults.setBool(key: "modulesCompleted", value: false) // işlemler tamamlanınca cache i temizliyoruz
        showThankYouView()
        showWaitingArea()
    }
    
    func imOffline() { // panelde sayfa yenilendi veya browser kapatıldı
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.manager.socket.connect()
        }
        myCam.isHidden = true
        customerCam.isHidden = true
        translate()
        waitScreen.isHidden = false
    }
}
