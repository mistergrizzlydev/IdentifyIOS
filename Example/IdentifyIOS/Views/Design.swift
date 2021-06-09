//
//  Design.swift
//  Kimlik
//
//  Created by Emir Beytekin on 3.05.2021.
//

import UIKit
import IdentifyIOS

public var DEFAULT_BACKGROUND_COLOR = UIColor(named: "Dark Blue")
public var DEFAULT_LABEL_COLOR = UIColor(named: "KB White")
public var DEFAULT_LABEL_FAMILY = UIFont(name: "Nunito Sans", size: 12)
var langManager = SDKLanguageManager.shared

public struct DesignConstants {
    // çağrı bekleme ekranı
    public static var waitScrBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var waitScrDesc1FontFamily: UIFont? = DEFAULT_LABEL_FAMILY
    public static var waitScrDesc2FontFamily: UIFont? = DEFAULT_LABEL_FAMILY
    public static var waitScrHiddenBackgroundPhoto: Bool = false
    public static var waitScrBackgroundPhoto: UIImage? = UIImage(named: "waitingBack")
    public static var waitScrDesc1LblText: String? = langManager.translate(key: .waitingDesc1)
    public static var waitScrDesc2LblText: String? = langManager.translate(key: .waitingDesc2)
    public static var waitScrDesc1LblColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var waitScrDesc2LblColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var waitScrThankUText: String? = langManager.translate(key: .thankU)
    public static var waitScrThankULblColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var waitScrThankULblFontFamily: UIFont? = DEFAULT_LABEL_FAMILY
    public static var waitScrCompleteBtnText: String? = langManager.translate(key: .coreSuccess)
    public static var waitScrCompleteBtnTextColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var waitScrCompleteBtnTextFont: UIFont? = DEFAULT_LABEL_FAMILY

    // çağrıyı kabul etme ekranı
    public static var ringScrBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var ringScrBackgroundPhoto: UIImage? = UIImage(named: "SDKCallingBack")
    public static var ringScrAcceptBtnImage: UIImage? = UIImage(named: "greenCall")
    public static var ringScrCallScrTitle: String? = langManager.translate(key: .callTitle)
    public static var ringScrCallScrTitleFont: UIFont? = DEFAULT_LABEL_FAMILY
    public static var ringScrCallScrTitleColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var ringScrCallScrDesc: String? = langManager.translate(key: .callDescription)
    public static var ringScrCallScrDescFont: UIFont? = DEFAULT_LABEL_FAMILY
    public static var ringScrCallScrDescColor: UIColor? = DEFAULT_LABEL_COLOR
     
    // nfc ana ekran
    public static var nfcScrBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var nfcScrBackCenterImg: UIImage? = UIImage(named: "nfcBack")
    
    public static var nfcScrInfoLabelTitle: String? = langManager.translate(key: .scanInfo)
    public static var nfcScrInfoLabelColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var nfcScrInfoLabelFont: UIFont? = DEFAULT_LABEL_FAMILY
    
    public static var nfcScrTryAgainBtnTitle: String? = langManager.translate(key: .scanAgain)
    public static var nfcScrTryAgainBtnBackColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var nfcScrTryAgainBtnLabelColor: UIColor? = .black
    public static var nfcScrTryAgainBtnTitleFont: UIFont? = DEFAULT_LABEL_FAMILY
    public static var nfcScrShowInfoPopup: Bool? = true
    public static var nfcScrInfoText: String? = langManager.translate(key: .popMRZ)
    
    public static var selfieScrBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    public static var selfieScrSubmitBtnColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var selfieScrSubmitBtnBackColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var selfieScrSubmitBtnText: String? = "Gönder"
    public static var selfieScrSubmitBtnFont: UIFont? = DEFAULT_LABEL_FAMILY
    
    public static var selfieScrCancelBtnColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var selfieScrCancelBtnBackColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var selfieScrCancelBtnText: String? = "Tekrar Çek"
    public static var selfieScrCancelBtnFont: UIFont? = DEFAULT_LABEL_FAMILY
    public static var selfieScrCancelDisableAlpha: CGFloat = 0.3
     
    // eski cihazlar için liveness
    public static var selfieScrLivenessShowInfoPopUp = true
    public static var selfieScrLivenessPopUpInfoText = langManager.translate(key: .popSmiley)
    
    public static var selfieScrSelfieShowInfoPopUp = true
    public static var selfieScrSelfiePopUpInfoText: String? = langManager.translate(key: .popSelfie)
    
    public static var selfieScrIdFrontShowInfoPopUp = true
    public static var selfieScrIdFrontPopUpInfoText: String? = langManager.translate(key: .popIdFrontPhoto)
    
    public static var selfieScrIdBackPopUpInfoText: String? = langManager.translate(key: .popIdBackPhoto)
    
    public static var selfieScrVideoShowInfoPopUp = true
    public static var selfieScrVideoPopUpInfoText: String? = langManager.translate(key: .popVideo)
    
    // imza ekranı
    public static var signatureScrBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var signatureScrSubmitBtnColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var signatureScrSubmitBtnBackColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var signatureScrSubmitBtnText: String? = "Gönder"
    public static var signatureScrSubmitBtnFont: UIFont? = DEFAULT_LABEL_FAMILY
    
    public static var signatureScrCancelBtnColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var signatureScrCancelBtnBackColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var signatureScrCancelBtnText: String? = "Tekrar Çek"
    public static var signatureScrCancelBtnFont: UIFont? = DEFAULT_LABEL_FAMILY
    public static var signatureScrCancelDisableAlpha: CGFloat = 0.3
     
    public static var signatureScrDescText: String? = langManager.translate(key: .signatureInfo)
    public static var signatureScrDescTextColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var signatureScrDescTextFont: UIFont? = DEFAULT_LABEL_FAMILY
    
    // ses tanıma
    public static var soundScrBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var soundScrBtnColor: UIColor? = UIColor.blue
    public static var soundScrBtnBackColor: UIColor? = UIColor.white
    public static var soundScrBtnText: String? = "Basılı tutun ve şehir ismini okuyun"
    public static var soundScrBtnFont: UIFont? = DEFAULT_LABEL_FAMILY
    
    // izin ekranları
    public static var permissionScrBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    public static var permissionTitle: String? = "Uygulama İzinleri"
    public static var permissionTitleColor: UIColor? = DEFAULT_LABEL_COLOR
    public static var permissionDesc: String? = "Devam edebilmek için lütfen kamera, mikrofon ve konuşma izinlerine onay veriniz."
    public static var permissionDescColor: UIColor? = DEFAULT_LABEL_COLOR
    
    public static var rejectedBtnBackColor: UIColor? = UIColor.red
    public static var acceptedtedBtnBackColor: UIColor? = UIColor.green
    
    public static var alertTitle: String? = "Hata"
    public static var alertDesc: String? = "Ayarlara gitmek istiyor musunuz?"
    public static var alertPositiveAct: String? = "Ayarlara Git"
    public static var alertNegativeAct: String? = "İptal Et"
    
}
