//
//  LanguageManager.swift
//  Kimlik
//
//  Created by MacBookPro on 13.02.2021.
//

import UIKit

public class SDKLanguageManager: NSObject {
    
    override init() {}
    
    public static let shared = SDKLanguageManager.init()
    
    public func translate(key: Keywords) -> String {
        switch key {
        case .connect:
            return NSLocalizedString("Connect", comment: "")
        case .connectInfo:
            return NSLocalizedString("ConnectInfo", comment: "")
        case .scanAgain:
            return NSLocalizedString("ScanAgain", comment: "")
        case .scanInfo:
            return NSLocalizedString("ScanInfo", comment: "")
        case .humanSmile:
            return NSLocalizedString("HumanSmile", comment: "")
        case .humanSmileDescription:
            return NSLocalizedString("HumanSmileDescription", comment: "")
        case .callTitle:
            return NSLocalizedString("CallTitle", comment: "")
        case .callDescription:
            return NSLocalizedString("CallDescription", comment: "")
        case .enterSmsCode:
            return NSLocalizedString("EnterSmsCode", comment: "")
        case .waitingDesc1:
            return NSLocalizedString("WaitingDesc1", comment: "")
        case .waitingDesc2:
            return NSLocalizedString("WaitingDesc2", comment: "")
        case .thankU:
            return NSLocalizedString("ThankU", comment: "")
            
        case .board1:
            return NSLocalizedString("OnPage1", comment: "")
        case .board2:
            return NSLocalizedString("OnPage2", comment: "")
        case .board3:
            return NSLocalizedString("OnPage3", comment: "")
        case .board4:
            return NSLocalizedString("OnPage4", comment: "")
        case .board5:
            return NSLocalizedString("OnPage5", comment: "")
            
        case .nextPage:
            return NSLocalizedString("NextPage", comment: "")
        case .backPage:
            return NSLocalizedString("BackPage", comment: "")
        case .skipPage:
            return NSLocalizedString("SkipPage", comment: "")
        case .continuePage:
            return NSLocalizedString("Continue", comment: "")
            
        case .popSelfie:
            return NSLocalizedString("PopSelfie", comment: "")
        case .popSmiley:
            return NSLocalizedString("PopSmiley", comment: "")
        case .popVideo:
            return NSLocalizedString("PopVideo", comment: "")
        case .popMRZ:
            return NSLocalizedString("PopMRZ", comment: "")
        case .popNFC:
            return NSLocalizedString("PopNFC", comment: "")
        case .popIdBackPhoto:
            return NSLocalizedString("PopIdBackPhoto", comment: "")
        case .popIdFrontPhoto:
            return NSLocalizedString("PopIdFrontPhoto", comment: "")
        case .signatureInfo:
            return NSLocalizedString("SignatureInfo", comment: "")
        case .soundRecognitionInfo:
            return NSLocalizedString("SoundRecognitionInfo", comment: "")
        case .coreError:
            return NSLocalizedString("CoreError", comment: "")
        case .coreSuccess:
            return NSLocalizedString("CoreSuccess", comment: "")
        case .wrongSMSCode:
            return NSLocalizedString("WrongSMSCode", comment: "")
        case .coreOk:
            return NSLocalizedString("CoreOK", comment: "")
        case .newNfcFront:
            return NSLocalizedString("NewNfcFront", comment: "")
        case .newNfcBack:
            return NSLocalizedString("NewNfcBack", comment: "")
        case .newDocumentFront:
            return NSLocalizedString("NewDocumentFront", comment: "")
        case .newDocumentBack:
            return NSLocalizedString("NewDocumentBack", comment: "")
        case .nfcPassportScanInfo:
            return NSLocalizedString("NfcPassportScanInfo", comment: "")
        case .nfcIDScanInfo:
            return NSLocalizedString("NfcIDScanInfo", comment: "")
        case .nfcDocumentScanInfo:
            return NSLocalizedString("NfcDocumentScanInfo", comment: "")
        case .nfcSuccess:
            return NSLocalizedString("NfcSuccess", comment: "")
        case .nfcEditInfoTitle:
            return NSLocalizedString("NfcEditInfoTitle", comment: "")
        case .nfcEditInfoDesc:
            return NSLocalizedString("NfcEditInfoDesc", comment: "")
        case .coreDate:
            return NSLocalizedString("CoreDate", comment: "")
        case .coreScan:
            return NSLocalizedString("CoreScan", comment: "")
        case .coreInputError:
            return NSLocalizedString("CoreInputError", comment: "")
        case .coreNfcDeviceError:
            return NSLocalizedString("CoreNfcDeviceError", comment: "")
        case .soundRecogOk:
            return NSLocalizedString("SoundRecogOk", comment: "")
        case .soundRecogFail:
            return NSLocalizedString("SoundRecogFail", comment: "")
        case .faceNotFound:
            return NSLocalizedString("FaceNotFound", comment: "")
        case .smilingFaceNotFound:
            return NSLocalizedString("SmilingFaceNotFound", comment: "")
        case .coreUploadError:
            return NSLocalizedString("CoreUploadError", comment: "")
        case .nfcInfoTitle:
            return NSLocalizedString("NfcInfoTitle", comment: "")
        case .nfcInfoDesc:
            return NSLocalizedString("NfcInfoDesc", comment: "")
        case .selfieInfoTitle:
            return NSLocalizedString("SelfieInfoTitle", comment: "")
        case .selfieInfoDesc:
            return NSLocalizedString("SelfieInfoDesc", comment: "")
        case .signatureInfoTitle:
            return NSLocalizedString("SignatureInfoTitle", comment: "")
        case .signatureInfoDesc:
            return NSLocalizedString("SignatureInfoDesc", comment: "")
        case .livenessInfoTitle:
            return NSLocalizedString("LivenessInfoTitle", comment: "")
        case .livenessInfoDesc:
            return NSLocalizedString("LivenessInfoDesc", comment: "")
        case .videoRecordInfoTitle:
            return NSLocalizedString("VideoRecordInfoTitle", comment: "")
        case .videoRecordInfoDesc:
            return NSLocalizedString("VideoRecordInfoDesc", comment: "")
        case .idCardInfoTitle:
            return NSLocalizedString("IdCardInfoTitle", comment: "")
        case .idCardInfoDesc:
            return NSLocalizedString("IdCardInfoDesc", comment: "")
        case .speechInfoTitle:
            return NSLocalizedString("SpeechInfoTitle", comment: "")
        case .speechInfoText:
            return NSLocalizedString("SpeechInfoText", comment: "")
        case .newIdCard:
            return NSLocalizedString("NewIdCart", comment: "")
        case .passport:
            return NSLocalizedString("Passport", comment: "")
        case .otherCards:
            return NSLocalizedString("OtherCards", comment: "")
        case .scanType:
            return NSLocalizedString("ScanType", comment: "")

        }
    }
}

public enum Keywords {
    case connect
    case connectInfo
    case scanAgain
    case scanInfo
    case humanSmile
    case humanSmileDescription
    case callTitle
    case callDescription
    case enterSmsCode
    case waitingDesc1
    case waitingDesc2
    case thankU
    case board1
    case board2
    case board3
    case board4
    case board5
    case nextPage
    case backPage
    case skipPage
    case continuePage
    case popSelfie
    case popSmiley
    case popVideo
    case popMRZ
    case popNFC
    case popIdBackPhoto
    case popIdFrontPhoto
    case signatureInfo
    case soundRecognitionInfo
    case coreError
    case coreSuccess
    case wrongSMSCode
    case coreOk
    case newNfcFront
    case newNfcBack
    case newDocumentFront
    case newDocumentBack
    case nfcPassportScanInfo
    case nfcIDScanInfo
    case nfcDocumentScanInfo
    case nfcSuccess
    case nfcEditInfoTitle
    case nfcEditInfoDesc
    case coreDate
    case coreScan
    case coreInputError
    case coreNfcDeviceError
    case soundRecogOk
    case soundRecogFail
    case faceNotFound
    case smilingFaceNotFound
    case coreUploadError
    case nfcInfoTitle
    case nfcInfoDesc
    case selfieInfoTitle
    case selfieInfoDesc
    case signatureInfoTitle
    case signatureInfoDesc
    case livenessInfoTitle
    case livenessInfoDesc
    case videoRecordInfoTitle
    case videoRecordInfoDesc
    case idCardInfoTitle
    case idCardInfoDesc
    case speechInfoTitle
    case speechInfoText
    case newIdCard
    case passport
    case otherCards
    case scanType
}



