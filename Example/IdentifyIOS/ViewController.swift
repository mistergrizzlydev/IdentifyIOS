//
//  ViewController.swift
//  IdentifyIOS
//
//  Created by emir@beytekin.net on 06/08/2021.
//  Copyright (c) 2021 emir@beytekin.net. All rights reserved.
//

import UIKit
import IdentifyIOS

class ViewController: SDKBaseViewController {
    
//    let manager = IdentifyManager.shared
    
    var quitType: AppQuitType {
        return manager.appQuitType ?? .restartModules
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        listenNotification()
        setupSDK()
        checkAppQuitType()
        checkPermissions()
        self.setupUI() // ister kodla, isterseniz views klasöründen tasarımı değiştirebilirsiniz
    }
    
    func setupSDK() {
        manager.appQuitType = .restartModules
        manager.selectedHost = .identifyTr
        manager.addModules(module: [.nfc, .livenessDetection, .selfie, .videoRecord, .idCard, .signature, .speech]) // app içindeki mevcut modüller, sadece çağrı ekranı için boş bırakabilirsiniz

        manager.userToken = "6e676552-9dc4-11eb-99a4-0acde28968be" // size verilecek olan token
        manager.netw.timeoutIntervalForRequest = 35
        manager.netw.timeoutIntervalForResource = 15
        
        manager.baseAPIUrl = "https://api.identifytr.com/"
        manager.webSocketUrl = "wss://ws.identifytr.com:8888/"
        manager.stunServers = ["stun:stun.l.google.com:19302", "turn:3.64.99.127:3478"]
        manager.stunUsername = "test"
        manager.stunPassword = "test"
        manager.setupUrls()
        // KPS sisteminiz varsa kullanıcıya ait verileri eklediğiniz takdirde MRZ tarama ekranı açılmayıp NFC ekranı açılacaktır
//        manager.mrzBirthDate = "01.12.1950"
//        manager.mrzValidDate = "03.05.2029"
//        manager.mrzDocumentNo = "B26C75239"
    }
    
    func checkAppQuitType() { // geliştirilmesi devam ediyor.
        if userDefaults.getBool(key: "modulesCompleted") == true {
            switch quitType {
            case .onlyCall:
                self.skipAllModules()
            default:
                return
            }
        }
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
    
    func setupUI() {
        GlobalConstants.appLogo = UIImage(named: "greenCall")! // tüm controllerlarda geçerli logo değişimini bu şekilde de yapabilirsiniz
                
        // Çağrı Bekleme Ekranı
        DesignConstants.waitScrBackgroundColor = .red
        DesignConstants.waitScrHiddenBackgroundPhoto = false // arkaplanda ortada yer alan görseli gizler
        DesignConstants.waitScrBackgroundPhoto = #imageLiteral(resourceName: "ob3") // arkaplanda ortada yer alan görseli değiştirir
        DesignConstants.waitScrDesc1LblText = "Merhaba"
        DesignConstants.waitScrDesc2LblText = "Lütfen kimliğinizi yanınızda tutun"
        DesignConstants.waitScrDesc1FontFamily = .systemFont(ofSize: 12)
        DesignConstants.waitScrDesc2FontFamily = .systemFont(ofSize: 24)
        DesignConstants.waitScrDesc1LblColor = UIColor.yellow
        DesignConstants.waitScrDesc2LblColor = UIColor.blue
        
        DesignConstants.waitScrThankUText = "Teşekkürler"
        DesignConstants.waitScrThankULblColor = .black
        DesignConstants.waitScrThankULblFontFamily = .systemFont(ofSize: 12)
        DesignConstants.waitScrCompleteBtnText = "Ekranı Kapat"
        DesignConstants.waitScrCompleteBtnTextFont = .systemFont(ofSize: 34)
        DesignConstants.waitScrCompleteBtnTextColor = .brown
        
        // Çağrı geldiğinde açılan ekran
        DesignConstants.ringScrBackgroundColor = .blue
        DesignConstants.ringScrBackgroundPhoto = UIImage() // bunu boş vererek imajı yok edebiliriz
        DesignConstants.ringScrAcceptBtnImage = UIImage(named: "greenCall")!
        DesignConstants.ringScrCallScrTitle = "Temsilci Arıyor"
        DesignConstants.ringScrCallScrTitleFont = .systemFont(ofSize: 12)
        DesignConstants.ringScrCallScrTitleColor = .yellow
        
        DesignConstants.ringScrCallScrDesc = "Lütfen telefonunuzu açın"
        DesignConstants.ringScrCallScrDescFont = .systemFont(ofSize: 12)
        DesignConstants.ringScrCallScrDescColor = .white
        
        // NFC Ekranı
        DesignConstants.nfcScrBackgroundColor = .blue
        DesignConstants.nfcScrBackCenterImg = UIImage(named: "nfcBack")
        
        DesignConstants.nfcScrInfoLabelTitle = "Kimliğinizi hazırlayın ve arkasını çevirin"
        DesignConstants.nfcScrInfoLabelColor = .green
        DesignConstants.nfcScrInfoLabelFont = .boldSystemFont(ofSize: 12)
        
        DesignConstants.nfcScrTryAgainBtnTitle = "Taramaya Başla"
        DesignConstants.nfcScrTryAgainBtnBackColor = .red
        DesignConstants.nfcScrTryAgainBtnLabelColor = .white
        DesignConstants.nfcScrTryAgainBtnTitleFont = .systemFont(ofSize: 12)
        DesignConstants.nfcScrShowInfoPopup = true
        DesignConstants.nfcScrInfoText = "Kimliğinizin arkasında bulunana barkodu kameraya tutun"
        
        // Kamera Ekranı
        DesignConstants.selfieScrBackgroundColor = .red
        DesignConstants.selfieScrLivenessShowInfoPopUp = true
        DesignConstants.selfieScrLivenessPopUpInfoText = "Eski cihazlar için canlılık popup metni \nLütfen gülümsediğiniz bir fotoğraf çekin"
        
        DesignConstants.selfieScrSelfieShowInfoPopUp = true
        DesignConstants.selfieScrSelfiePopUpInfoText = "Yüzünüzün göründüğü bir fotoğraf çekin"
        
        DesignConstants.selfieScrIdFrontShowInfoPopUp = true
        DesignConstants.selfieScrIdFrontPopUpInfoText = "Kimlik önü fotoğrafını çekin"
        
        DesignConstants.selfieScrIdBackPopUpInfoText = "Kimlik arkası fotoğrafını çekin"
        
        DesignConstants.selfieScrVideoShowInfoPopUp = true
        DesignConstants.selfieScrVideoPopUpInfoText = "5 saniyelik video çekin"
        
        
        DesignConstants.selfieScrCancelDisableAlpha = 0.3
        DesignConstants.selfieScrSubmitBtnBackColor = .green
        DesignConstants.selfieScrSubmitBtnColor = .red
        DesignConstants.selfieScrSubmitBtnText = "Yolla"
        DesignConstants.selfieScrSubmitBtnFont = .boldSystemFont(ofSize: 22)
        
        DesignConstants.selfieScrCancelBtnBackColor = .yellow
        DesignConstants.selfieScrCancelBtnColor = .blue
        DesignConstants.selfieScrCancelBtnText = "Tekrar Çek"
        DesignConstants.selfieScrCancelBtnFont = .boldSystemFont(ofSize: 12)
        
        // imza ekranı
        DesignConstants.signatureScrCancelDisableAlpha = 0.3
        DesignConstants.signatureScrSubmitBtnBackColor = .green
        DesignConstants.signatureScrSubmitBtnColor = .red
        DesignConstants.signatureScrSubmitBtnText = "Gönder"
        DesignConstants.signatureScrSubmitBtnFont = .boldSystemFont(ofSize: 22)
        
        DesignConstants.signatureScrCancelBtnBackColor = .yellow
        DesignConstants.signatureScrCancelBtnColor = .blue
        DesignConstants.signatureScrCancelBtnText = "İmzayı Sil"
        DesignConstants.signatureScrCancelBtnFont = .boldSystemFont(ofSize: 12)
        DesignConstants.signatureScrBackgroundColor = .blue
        
        DesignConstants.signatureScrDescText = "Beyaz alana imza atabilirsiniz"
        DesignConstants.signatureScrDescTextColor = .red
        DesignConstants.signatureScrDescTextFont = .boldSystemFont(ofSize: 32)
        
        // ses tanıma
        DesignConstants.soundScrBackgroundColor = .red
        DesignConstants.soundScrBtnColor = .white
        DesignConstants.soundScrBtnBackColor = .green
        DesignConstants.soundScrBtnText = "Basılı Tut & Kelimeyi Söyle & Elini Çek"
        DesignConstants.soundScrBtnFont = .boldSystemFont(ofSize: 32)
        
        // izinler ekranı
        DesignConstants.permissionScrBackgroundColor = DEFAULT_BACKGROUND_COLOR
        DesignConstants.permissionTitle = "Uygulama İzinleri"
        DesignConstants.permissionTitleColor = DEFAULT_LABEL_COLOR
        DesignConstants.permissionDesc = "Devam edebilmek için lütfen kamera, mikrafon ve konuşma izinlerine onay veriniz."
        DesignConstants.permissionDescColor = DEFAULT_LABEL_COLOR
        
        DesignConstants.rejectedBtnBackColor = .red
        DesignConstants.acceptedtedBtnBackColor = .green
        DesignConstants.permissionAlertTitle = "Hata"
        DesignConstants.permissionAlertDesc = "Gerekli izinler verilmedi, ayarlara gitmek ister misin?"
        DesignConstants.permissionAlertPositiveAct = "Ayarlara Git"
        DesignConstants.permissionAlertNegativeAct = "İptal Et"
        
    }
    
    @IBAction func connect(_ sender: Any) {
        if manager.socket != nil {
            manager.connectToRoom()
        } else {
            setupSDK()
            manager.connectToRoom()
        }
        
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
                self.present(controller, animated: true, completion: nil)
            } else {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController: PermissionViewDelegate {
    
    func permissionCompleted() {
        debugPrint("permission delegate ok")
    }
    
}

extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}
