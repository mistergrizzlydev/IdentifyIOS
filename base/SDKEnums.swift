//
//  SDKEnums.swift
//  Kimlik
//
//  Created by Emir Beytekin on 20.04.2021.
//

public enum AppType: String, Codable {
    case onlySDK = "SDK"
    case demoApp = "Demo App"
}

public enum SDKType: Int, Codable {
    case fullProcess    = 0
    case withoutCall    = 1
    case onlyCall       = 2
}

public enum HostType: String, Codable {
    case kimlikBasit = "Kimlik Basit"
    case identifyTr = "Identify Tr"
    case custom = "Custom"
}

public enum SdkModules: String, Codable {
    case login          = "Login Screen"
    case nfc            = "Mrz & Nfc Screen"
    case livenessDetection       = "Liveness Detection"
    case waitScreen     = "Call Wait Screen"
    case selfie         = "Selfie"
    case videoRecord    = "Video Recorder"
    case idCard         = "Id Card"
    case signature      = "Signature"
    case speech         = "Speech Recognition"
    case liveView       = "Live View"
    case addressConf    = "Address Confirm"
}

public enum SelfieTypes: String, Codable {
    case selfie         = "selfie"
    case oldPhoneFace   = "oldPhoneFace"
    case video          = "video"
    case backId         = "idBack"
    case frontId        = "idFront"
    case signature      = "signature"
}

public enum AppQuitType: String {
    case restartModules
    case onlyCall
}

public enum LogLevel: String, Codable {
    case none = "None"
    case all = "All"
}

public enum VerificationCardType: String {
    case onlyIdCard
    case all
}
