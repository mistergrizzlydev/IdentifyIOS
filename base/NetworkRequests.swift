//
//  NetworkRequests.swift
//  identSDK
//
//  Created by MacBookPro on 16.01.2021.
//  Copyright © 2021 Emir Beytekin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class SDKNetwork: NSObject {
    
    public var BASE_URL = ""
    public var timeoutIntervalForRequest = 30
    public var timeoutIntervalForResource = 30
    
    private lazy var alamoFireManager: Session? = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(self.timeoutIntervalForRequest)
        configuration.timeoutIntervalForResource = TimeInterval(self.timeoutIntervalForResource)
//        let evaluator: [String: ServerTrustEvaluating] = [
//            "api.identifytr.com": PublicKeysTrustEvaluator()
//        ]
//        let alamoFireManager = Alamofire.Session(configuration: configuration, serverTrustManager: ServerTrustManager(evaluators: evaluator))
        let alamoFireManager = Alamofire.Session(configuration: configuration)

        return alamoFireManager

   }()

    public func connectToRoom(identId: String, callback: @escaping((_ results: RoomResponse) -> Void)) {
        let urlStr = BASE_URL + "mobile/getIdentDetails/" + IdentifyManager.shared.userToken
        
        let headers : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        alamoFireManager?.request(urlStr, method: .get, encoding: URLEncoding.default , headers:headers).validate(contentType: ["application/json"]).responseJSON { response in
            guard let data = response.data else { return }
            self.webLogger(url: urlStr, log: data)
            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(RoomResponse.self, from: data)
                if forceResp.messages?.count ?? 0 > 0 {
                    self.showAlert(msg: forceResp.messages?[0] ?? "Hata var!")
                } else {
                    DispatchQueue.main.async {
                        callback(forceResp)
                    }
                }
            } catch let error {
                self.showAlert(msg: error.localizedDescription)
                
            }
        }
    }
    
    public func verifySms(tid: String, tan: String, callback: @escaping ((_ results: EmptyResponse) -> Void)) {
        let urlStr = BASE_URL + "mobile/verifyTan"
        let headers : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        let papara = SmsJson.init(tid: tid, tan: tan)
        alamoFireManager?.request(urlStr, method: .post, parameters:papara.asDictionary(), encoding: JSONEncoding.default , headers:headers).responseJSON { response in

            guard let data = response.data else { return }
            self.webLogger(url: urlStr, log: data)

            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(EmptyResponse.self, from: data)
                if forceResp.messages?.count ?? 0 > 0 {
                    self.showAlert(msg: forceResp.messages?[0] ?? "Hata var!")
                }
                DispatchQueue.main.async {
                    callback(forceResp)
                }
                
            } catch let error {
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    public func verifyNFC(model: IdentifyCard, callback: @escaping ((_ results: BoolResponse) -> Void)) {
        let urlStr = BASE_URL + "mobile/nfc_verify"
        let headers : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        
        alamoFireManager?.request(urlStr, method: .post, parameters:model.asDictionary(), encoding: JSONEncoding.default , headers:headers).responseJSON { response in

//            if let  JSON = response.result.value,
//                let JSONData = try? JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted),
//                let prettyString = NSString(data: JSONData, encoding: String.Encoding.utf8.rawValue) {
//            }
            
            guard let data = response.data else { return }
            self.webLogger(url: urlStr, log: data)
            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(BoolResponse.self, from: data)
                
                DispatchQueue.main.async {
                    callback(forceResp)
                }
                
            } catch let error {
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    public func uploadAddressInfo(image: String, addressText: String, callback: @escaping ((_ results: BoolResponse) -> Void)) {
        let urlStr = BASE_URL + "mobile/upload"
        var params = [String : String]()
        params["type"] = "address"
        params["address"] = addressText
        params["ident_id"] = IdentifyManager.shared.userToken
        params["image"] = image
        let headers : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        alamoFireManager?.request(urlStr, method: .post, parameters:params, encoding: JSONEncoding.default , headers:headers).responseJSON { response in
            
            guard let data = response.data else { return }
            self.webLogger(url: urlStr, log: data)
            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(BoolResponse.self, from: data)
                DispatchQueue.main.async {
                    callback(forceResp)
                }
            } catch let error {
                DispatchQueue.main.async {
                    callback(BoolResponse.init(result: false))
                }
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    public func uploadSelfieImage(image: String, selfieType: SelfieTypes, callback: @escaping ((_ results: BoolResponse) -> Void)) {
        let urlStr = BASE_URL + "mobile/upload"
        var params = [String : String]()
        params["type"] = selfieType.rawValue
        params["ident_id"] = IdentifyManager.shared.userToken
        params["image"] = image
        let headers : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        alamoFireManager?.request(urlStr, method: .post, parameters:params, encoding: JSONEncoding.default , headers:headers).responseJSON { response in
            guard let data = response.data else { return }
            self.webLogger(url: urlStr, log: data)
            do {
                let decoder = JSONDecoder()
                let forceResp = try decoder.decode(BoolResponse.self, from: data)
                DispatchQueue.main.async {
                    callback(forceResp)
                }
            } catch let error {
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    public func uploadVideo(videoData: Data, callback: @escaping ((_ results: BoolResponse) -> Void)) {
        let urlStr = BASE_URL + "mobile/uploadVideo5Sec"
        var params = [String : String]()
        params["type"] = "video5Sec"
        params["ident_id"] = IdentifyManager.shared.userToken
        
        alamoFireManager?.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            multipartFormData.append(videoData, withName: "video5Sec", fileName: "video5Sec.mp4", mimeType: "mp4")
            
                },
                 to:urlStr,
                 method:.post, headers:["Content-Type": "application/json"]).responseData(completionHandler:  { resp in
                    if let error = resp.error {
                        print(error)
                    }

                    if let xx = resp.data {
                        self.webLogger(url: urlStr, log: xx)

                    }
                    guard let data = resp.value else {
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let forceResp = try decoder.decode(BoolResponse.self, from: data)
                        DispatchQueue.main.async {
                            callback(forceResp)
                        }
                    } catch let error {
                        self.showAlert(msg: error.localizedDescription)
                    }
            })
        
    }
    
    public func showAlert(msg: String) {
        AlertViewManager.defaultManager.showOkAlert("Hata", message: msg) { (action) in
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("hideLoader"), object: nil)
        }
    }
    
    private func webLogger(url: String, log: Data) {
        let xx = String(data: log, encoding: .utf8)
        print("URL : \(url) \nData : \(xx ?? "not found")")
    }
}

extension DataRequest {

    @discardableResult
    func prettyPrintedJsonResponse() -> Self {
        return responseJSON { (response) in
            switch response.result {
            case .success(let result):
                if let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted),
                    let text = String(data: data, encoding: .utf8) {
                    print("📗 prettyPrinted JSON response: \n \(text)")
                }
            case .failure: break
            }
        }
    }
}
