//
//  SDKNoInternetViewController.swift
//  IdentifyIOS_Example
//
//  Created by Emir Beytekin on 18.10.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
protocol ConnectionListenerDelegate: class {
    func connectedAgain()
}
class SDKNoInternetViewController: SDKBaseViewController {

    @IBOutlet weak var connectBtn: UIButton!
    weak var delegate: ConnectionListenerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectBtn.addTarget(self, action: #selector(connectToSocket), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func connectToSocket() {
        connectBtn.setTitle("Lütfen bekleyin..", for: .normal)
        self.manager.reConnectToRoom { socket in
            if socket.isConnected {
                self.delegate?.connectedAgain()
                self.dismissThisController()
            }
        }
    }
    
    @objc func dismissThisController() {
        self.dismiss(animated: true, completion: {
            self.manager.sendStep()
        })
    }

}
