//
//  AccessibilityViewController.swift
//  IdentifyIOS_Example
//
//  Created by Emir Beytekin on 20.10.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IdentifyIOS

class SDKAccessibilityViewController: SDKBaseViewController {

    @IBOutlet weak var signSwitch: UISwitch!
    @IBOutlet weak var appLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        appLogo.image = GlobalConstants.appLogo
    }
    
    @IBAction func startCallAct(_ sender: Any) {
        self.dismiss(animated: true) {
            self.manager.connectToSignLang = self.signSwitch.isOn
            self.manager.sendStep()
        }
    }
}
