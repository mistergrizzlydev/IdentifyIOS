//
//  CallScreenViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 25.01.2021.
//

import UIKit
import AudioToolbox
import IdentifyIOS

class CallScreenViewController: SDKBaseViewController {
    
    weak var delegate: CallScreenDelegate?
    @IBOutlet weak var callTitleLabel: UILabel!
    @IBOutlet weak var callDescriptionLabel: UILabel!
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appLogo.image = GlobalConstants.appLogo
        setupUI()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(callVibrate), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            timer.invalidate()
        }
    }
    
    @objc func callVibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func setupUI() {
        self.view.backgroundColor = DesignConstants.ringScrBackgroundColor
        backgroundImage.image = DesignConstants.ringScrBackgroundPhoto
        self.acceptBtn.setImage(DesignConstants.ringScrAcceptBtnImage, for: .normal)
        
        self.callTitleLabel.text = DesignConstants.ringScrCallScrTitle
        self.callTitleLabel.textColor = DesignConstants.ringScrCallScrTitleColor
        self.callTitleLabel.font = DesignConstants.ringScrCallScrTitleFont
        
        self.callDescriptionLabel.text = DesignConstants.ringScrCallScrDesc
        self.callDescriptionLabel.textColor = DesignConstants.ringScrCallScrDescColor
        self.callDescriptionLabel.font = DesignConstants.ringScrCallScrDescFont
    }
    
    @IBAction func acceptCall(_ sender: Any) {
        timer.invalidate()
        self.dismiss(animated: true) {
            self.delegate?.acceptCall()
        }
    }
}
