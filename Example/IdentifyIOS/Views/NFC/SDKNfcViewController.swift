//
//  NFCViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 2.02.2021.
//

import UIKit
import NFCPassportReader
import QKMRZParser
import IdentifyIOS

protocol ScannerStatusDelegate {
    func nfcAvailable(status:Bool)
    func nfcCompleted()
}

protocol ProcessScanResult {
    func processNew(scanResult: PassportModel, barcodeString: String?)
}

@available(iOS 13, *)
class SDKNfcViewController: SDKBaseViewController, PopUpProtocol {
    
    var presentIsOpen = false
    
    var delegate: ScannerStatusDelegate?
    
    var nfcErrorCount = 0
    
    @IBOutlet weak var backGround: UIView!
    @IBOutlet weak var scanHolderView: UIView!
    @IBOutlet weak var scanAgainLabel: GradientLabel!
    @IBOutlet weak var nfcInfoLabel: UILabel!
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var nfcBackImg: UIImageView!
    @IBOutlet weak var scainAgainBtn: UIButton!
    
    
    func goToWaitScreen() {
        self.dismiss(animated: true, completion: {
            self.delegate?.nfcCompleted()
        })
    }

    var manager: IdentifyManager!
    let passportReader = PassportReader.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appLogo.image = GlobalConstants.appLogo
        setupUI()
        if DesignConstants.nfcScrShowInfoPopup == true {
            self.showPopUp(image: UIImage(named: "ob2")!, desc: DesignConstants.nfcScrInfoText!)
        }
        addSkipModulesButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupUI() {
        scanHolderView.layer.cornerRadius = 4
        scanHolderView.addShadow()
        
        self.view.backgroundColor = DesignConstants.nfcScrBackgroundColor
        nfcBackImg.image = DesignConstants.nfcScrBackCenterImg
        
        scainAgainBtn.setTitle(DesignConstants.nfcScrTryAgainBtnTitle, for: .normal)
        scainAgainBtn.setTitleColor(DesignConstants.nfcScrTryAgainBtnLabelColor, for: .normal)
        scainAgainBtn.backgroundColor = DesignConstants.nfcScrTryAgainBtnBackColor
        scainAgainBtn.titleLabel?.font = DesignConstants.nfcScrTryAgainBtnTitleFont
        
        nfcInfoLabel.text = DesignConstants.nfcScrInfoLabelTitle
        nfcInfoLabel.font = DesignConstants.nfcScrInfoLabelFont
        nfcInfoLabel.textColor = DesignConstants.nfcScrInfoLabelColor
        
    }
    
    func startNFC() {
        presentIsOpen = true
        let myBundle = Bundle(for: SDKMrzViewController.self)
        let myStoryboard = UIStoryboard(name: "KYC", bundle: myBundle).instantiateSB() as SDKMrzViewController
        myStoryboard.delegate = self
        myStoryboard.navigationController?.isNavigationBarHidden = true
        DispatchQueue.main.async {
            self.present(myStoryboard, animated: true)
        }
    }
    
    func handlePopUpAction(action: Bool) {
        startNFC()
    }
    
    @IBAction func nfcRepeatAct(_ sender: Any) {
        startNFC()
    }
    
}

@available(iOS 13, *)
extension SDKNfcViewController: ProcessScanResult {
    
    func processNew(scanResult: PassportModel, barcodeString: String?) {
        self.readCard(res: scanResult)
    }
    
    func readCard(res: PassportModel) {
        
        let passportUtil = PassportUtil()
        passportUtil.passportNumber = res.documentNumber
        passportUtil.dateOfBirth = res.birthDate?.toString() ?? ""
        passportUtil.expiryDate = res.expiryDate?.toString() ?? ""
        let mrzKey = passportUtil.getMRZKey()
                
        passportReader.readPassport(mrzKey: mrzKey, customDisplayMessage: { (displayMessage) in
            switch displayMessage {
                case .requestPresentPassport:
                    return self.translate(text: .popNFC)
                case .successfulRead:
                    return "Kimliğiniz başarıyla tanımlandı"
                case .readingDataGroupProgress(let dataGroup, let progress):
                    let progressString = self.handleProgress(percentualProgress: progress)
                    return "Veriler okunuyor \(dataGroup) ...\n\(progressString)"
                default:
                    return nil
            }
        }, completed: { (passport, error) in
            if let passport = passport {
                DispatchQueue.main.async {
                    passportUtil.passport = passport
                    var gender = "N/A"
                    if passportUtil.passport?.gender == "F" {
                        gender = "FEMALE"
                    } else if passportUtil.passport?.gender == "M" {
                        gender = "MALE"
                    }
                    var documentType = "Unknown"
                    if passportUtil.passport?.documentType == "P" {
                        documentType = "Passport"
                    } else if passportUtil.passport?.documentType == "I" {
                        documentType = "ID Card"
                    }
                                        
                    let img = passportUtil.passport?.passportImage?.toBase64()
                    
                    let idInfo = IdentifyCard(ident_id: self.manager.userToken, name: passportUtil.passport?.firstName ?? "", surname: passportUtil.passport?.lastName ?? "", personalNumber: passportUtil.passport?.personalNumber ?? "", birthdate: res.birthDate?.toString(format: "dd.MM.yyyy") ?? "", expireDate: res.expiryDate?.toString(format: "dd.MM.yyyy") ?? "", serialNumber: passportUtil.passport?.documentNumber ?? "", nationality: passportUtil.passport?.nationality ?? "", docType: documentType, authority: passportUtil.passport?.issuingAuthority ?? "", gender: gender, image: img)
                                                            
                    self.manager.netw.verifyNFC(model: idInfo) { (resp) in
                        if resp == true {
                            self.delegate?.nfcAvailable(status: true)
                            self.goToWaitScreen()
                        } else {
                            self.delegate?.nfcAvailable(status: false)
                            self.goToWaitScreen()
                        }
                    }
                    return
                }
            } else {
                AlertViewManager.defaultManager.showOkAlert("Kimlik Basit", message: "error.debugDescription") { (action) in
                    self.delegate?.nfcAvailable(status: false)
                    self.goToWaitScreen()
                }
            }
            if let error = error {
                self.nfcErrorCount = self.nfcErrorCount + 1
                if self.nfcErrorCount == GlobalConstants.nfcErrorMaxCount {
                    DispatchQueue.main.async {
                        self.delegate?.nfcAvailable(status: false)
                        self.goToWaitScreen()
                    }
                }
            }
        })
        return
    }
    
    func handleProgress(percentualProgress: Int) -> String {
        let p = (percentualProgress/10)
        let full = String(repeating: "🔵", count: p)
        let empty = String(repeating: "⚪️", count: 10-p)
        return "\(full)\(empty)"
    }
    
}
