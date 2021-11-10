//
//  SDKNetworkSettingsViewController.swift
//  Kimlik
//
//  Created by Emir Beytekin on 24.09.2021.
//

import UIKit
import IdentifyIOS
protocol NetworkUpdateDelegate: class {
    func networkUpdate()
}

class SDKNetworkSettingsViewController: SDKBaseViewController {
    
    @IBOutlet weak var baseUrl: UITextField!
    @IBOutlet weak var stunServer1: UITextField!
    @IBOutlet weak var stunServer2: UITextField!
    @IBOutlet weak var stunUser: UITextField!
    @IBOutlet weak var stunPass: UITextField!
    @IBOutlet weak var socketUrl: UITextField!
    let cache = UserDefaultService.shared
    weak var delegate: NetworkUpdateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.selectedHost = .custom
        getTexts()
    }
    
    func getTexts() {
        baseUrl.text = cache.getValue(key: "baseAPIUrl")
        stunServer1.text = cache.getValue(key: "stunServer")
        stunServer2.text = cache.getValue(key: "stunServer2")
        stunUser.text = cache.getValue(key: "stunUser")
        stunPass.text = cache.getValue(key: "stunPass")
        socketUrl.text = cache.getValue(key: "socketUrl")
    }
    
    @IBAction func saveSettings(_ sender: Any) {
        if baseUrl.text != "" && stunServer1.text != "" && stunUser.text != "" && stunPass.text != "" && socketUrl.text != "" {
            if baseUrl.text!.last != "/" {
                baseUrl.text = baseUrl.text! + "/"
                manager.baseAPIUrl = baseUrl.text!
            } else {
                manager.baseAPIUrl = baseUrl.text!
            }
            
            if socketUrl.text!.last != "/" {
                socketUrl.text = socketUrl.text! + "/"
                manager.webSocketUrl = socketUrl.text!
            } else {
                manager.webSocketUrl = socketUrl.text!
            }
            
            if stunServer2.text != "" {
                manager.stunServers = [stunServer1.text! , stunServer2.text!]
            } else {
                manager.stunServers = [stunServer1.text!]
            }
            manager.stunUsername = stunUser.text!
            manager.stunPassword = stunPass.text!
            // save to cache
            cache.setValue(key: "baseAPIUrl", value: manager.baseAPIUrl)
            cache.setValue(key: "stunServer", value: manager.stunServers.first ?? "")
            cache.setValue(key: "stunServer2", value: manager.stunServers.last ?? "")
            cache.setValue(key: "stunUser", value: manager.stunUsername)
            cache.setValue(key: "stunPass", value: manager.stunPassword)
            cache.setValue(key: "socketUrl", value: manager.webSocketUrl)
//            manager.selectedHost = .custom
            manager.setupUrls()
            delegate?.networkUpdate()
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.popupAlert(title: self.translate(text: .coreError), message: self.translate(text: .coreInputError), actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
            }])
        }
    }
    
    @IBAction func resetConfig(_ sender: Any) {
        DispatchQueue.main.async {
            self.baseUrl.text = URLConstants.baseAPIUrl
            self.stunServer1.text = URLConstants.stunServers.first
            self.stunServer2.text = URLConstants.stunServers.last
            self.stunUser.text = URLConstants.stunUsername
            self.stunPass.text = URLConstants.stunPassword
            self.socketUrl.text = "wss://ws.identifytr.com:8888/"
        }
    }
    
}
