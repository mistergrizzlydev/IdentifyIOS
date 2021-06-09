//
//  ViewController.swift
//  IdentifyIOS
//
//  Created by emir@beytekin.net on 06/08/2021.
//  Copyright (c) 2021 emir@beytekin.net. All rights reserved.
//

import UIKit
import IdentifyIOS

class ViewController: UIViewController {

    let manager = IdentifyManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenNotification()
        manager.selectedHost = .identifyTr
        manager.addModules(module: [.livenessDetection])
        manager.userToken = "6e676552-9dc4-11eb-99a4-0acde28968be" // size verilecek olan token
        manager.netw.timeoutIntervalForRequest = 35
        manager.netw.timeoutIntervalForResource = 15
        
        manager.baseAPIUrl = "https://api.identifytr.com/"
        manager.webSocketUrl = "wss://ws.identifytr.com:8888/"
        manager.stunServers = ["stun:stun.l.google.com:19302", "turn:3.64.99.127:3478"]
        manager.stunUsername = "test"
        manager.stunPassword = "test"
        manager.setupUrls()
        
        if manager.permissionsAllowed() == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let next = SDKPermissionsViewController.instantiate()
                next.modalPresentationStyle = .fullScreen
                self.present(next, animated: true, completion: nil)
            }
        } else {
            debugPrint("izinler ok")
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connect(_ sender: Any) {
        self.manager.connectToRoom()
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

