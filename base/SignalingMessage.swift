//
//  SignalingSDP.swift
//  SimpleWebRTC
//
//  Created by tkmngch on 2019/01/08.
//  Copyright © 2019 tkmngch. All rights reserved.
//

import Foundation

struct CallSocketResp : Codable {
    let action: String
    let room: String
}

struct ConnectSocketResp : Codable {
    let location: String
    let room: String
    let action: String
}

struct FirstSubscribeResp: Codable {
    let location: String
    let room: String
    let action: String
    let deviceInfo: DeviceInfo
}

struct DeviceInfo: Codable {
    let platform: String
    let osVersion: String
    let deviceModel: String
    let deviceBrand: String
    
    init() {
        self.platform = "Apple"
        self.osVersion = UIDevice.current.systemVersion
        self.deviceBrand = UIDevice().localizedModel
        self.deviceModel = UIDevice.current.modelName
    }
}

struct SendStepsResp : Codable {
    let location: String
    let room: String
    let action: String
    let steps: Steps?
}

struct NFCConnectSocketResp : Codable {
    let room: String
    let action: String
    let status: String
}

struct sendSmsStr: Codable {
    let action: String
    let room: String
    let tid: String
    let tan: String
}

struct ToogleCamera: Codable {
    let action: String
    let result: Bool
    let room: String
}

struct ToogleTorch: Codable {
    let action: String
    let result: Bool
    let room: String
}

struct SDPSender: Codable {
    let action: String
    let room: String
    let sdp: SDP2?
}

struct SDP2: Codable {
    let type: String
    let sdp: String
}

struct SendCandidate: Codable {
    let action: String
    let candidate: Candidate?
    let room: String?
    let sessionDescription: SDP?
}

struct SMSCandidate: Codable {
    let action: String
    let room: String?
    let is_admin: Bool?
    let tid: Int?
}

struct QueueList: Codable {
    let action: String?
    let countMember: Int?
    let apprWaitFor: Int?
    let room: String?
}

struct GetCandidate: Codable {
    let action: String?
    let candidate: Candidate?
    let room: String?
}

struct SignalingMessage: Codable {
    let type: String
    let sessionDescription: SDP?
    let candidate: Candidate?
}

struct NewCandidate: Codable {
    let action: String
    let candidate: Candidate?
    let room: String
}

struct SDP: Codable {
    let sdp: String
}

struct Candidate: Codable {
    let candidate: String
    let sdpMLineIndex: Int32
    let sdpMid: String
}

public class Steps: Codable {
    public var nfc: Bool? = false
    public var liveness: Bool? = false
    public var idFront: Bool? = false
    public var idBack: Bool? = false
    public var video: Bool? = false
    public var signature: Bool? = false
    public var speech: Bool? = false
    public var selfie: Bool? = false
    
    public var language: String? = ""
    public var sign_language: Bool? = false
    public var verifyAddress: Bool? = false
    
    init(nfc: Bool, liveness: Bool, idFront:Bool, idBack: Bool, video: Bool, signature: Bool, speech: Bool, selfie: Bool, language: String, sign_language: Bool, verifyAddress: Bool) {
        self.nfc = nfc
        self.liveness = liveness
        self.idFront = idFront
        self.idBack = idBack
        self.video = video
        self.signature = signature
        self.speech = speech
        self.selfie = selfie
        self.language = language
        self.sign_language = sign_language
        self.verifyAddress = verifyAddress
    }
    
    init() {}
}

public extension UIDevice {

    /// pares the deveice name as the standard name
    var modelName: String {

        #if targetEnvironment(simulator)
            let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        #endif

        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPod9,1":                                 return "iPod touch (7th generation)"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPhone12,8":                              return "iPhone SE (2nd generation)"
        case "iPhone13,1":                              return "iPhone 12 mini"
        case "iPhone13,2":                              return "iPhone 12"
        case "iPhone13,3":                              return "iPhone 12 Pro"
        case "iPhone13,4":                              return "iPhone 12 Pro Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        default:                                        return identifier
        }
    }
}
