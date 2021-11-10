//
//  Constant.swift
//  Kimlik
//
//  Created by MacBookPro on 1.02.2021.
//

import UIKit

public struct URLConstants {
    public static var baseAPIUrl = "https://api.identifytr.com/"
    public static var stunServers = ["stun:stun.l.google.com:19302", "turn:3.64.99.127:3478"]
    public static var stunUsername = "test"
    public static var stunPassword = "test"
    public static var webSocketUrl = "wss://ws.identifytr.com:8888/"
}

public struct KBURLConstants {
    public static let baseAPIUrl = "https://api.kimlikbasit.com/"
    public static var stunServers = ["stun:stun.l.google.com:19302", "turn:18.156.205.32:3478"]
    public static var stunUsername = "test"
    public static var stunPassword = "test"
    public static var webSocketUrl = "wss://ws.identifytr.com:8888/"
}
