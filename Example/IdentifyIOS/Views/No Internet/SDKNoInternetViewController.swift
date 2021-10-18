//
//  SDKNoInternetViewController.swift
//  IdentifyIOS_Example
//
//  Created by Emir Beytekin on 18.10.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class SDKNoInternetViewController: SDKBaseViewController {

    @IBOutlet weak var connectBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectBtn.addTarget(self, action: #selector(connectToSocket), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listenNotification()
    }
    
    @objc func listenNotification() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("UserLoggedIn"), object: nil)
    }
    
    @objc func userLoggedIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismissThisController()
        }
    }
    
    @objc func connectToSocket() {
        self.manager.connectToRoom()
        connectBtn.setTitle("Lütfen bekleyin..", for: .normal)
    }
    
    @objc func dismissThisController() {
        self.dismiss(animated: true, completion: nil)
    }

}
