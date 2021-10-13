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
    public var sign_language: String? = ""
    
    init(nfc: Bool, liveness: Bool, idFront:Bool, idBack: Bool, video: Bool, signature: Bool, speech: Bool, selfie: Bool, language: String, sign_language: String) {
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
    }
    
    init() {}
}
