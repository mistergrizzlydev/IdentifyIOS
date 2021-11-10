//
//  SDKInformationViewController.swift
//  IdentifyIOS_Example
//
//  Created by Emir Beytekin on 2.11.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Lottie
import IdentifyIOS

class SDKInformationViewController: SDKBaseViewController {

    @IBOutlet weak var infoItemView: UIView!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoDesc: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    var isAnimation = false
    var activeScreen: SdkModules? = .waitScreen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        okBtn.setTitle(self.translate(text: .coreOk), for: .normal)
        closeBtn.setTitle(self.translate(text: .coreOk), for: .normal)
        
        switch activeScreen {
        case .nfc:
            self.setAnimation(view: infoItemView, name: "nfc", loop: true)
            self.infoTitle.text = self.translate(text: .nfcInfoTitle)
            self.infoDesc.text = self.translate(text: .nfcInfoDesc)
        case .selfie:
            self.setAnimation(view: infoItemView, name: "selfie", loop: true)
            self.infoTitle.text = self.translate(text: .selfieInfoTitle)
            self.infoDesc.text = self.translate(text: .selfieInfoDesc)
        case .videoRecord:
            self.setAnimation(view: infoItemView, name: "video_record", loop: true)
            self.infoTitle.text = self.translate(text: .videoRecordInfoTitle)
            self.infoDesc.text = self.translate(text: .videoRecordInfoDesc)
        case .idCard:
            self.setAnimation(view: infoItemView, name: "smile", loop: true)
            self.infoTitle.text = self.translate(text: .idCardInfoTitle)
            self.infoDesc.text = self.translate(text: .idCardInfoDesc)
        case .signature:
            self.setAnimation(view: infoItemView, name: "signature", loop: true)
            self.infoTitle.text = "İmzanızı atın"  // self.translate(text: .signatureInfoTitle)
            self.infoDesc.text = "Beyaz alana imzanızı atın" // self.translate(text: .signatureInfoDesc)
        case .speech:
            self.setAnimation(view: infoItemView, name: "speech", loop: true)
            self.infoTitle.text = self.translate(text: .speechInfoTitle)
            self.infoDesc.text = self.translate(text: .speechInfoText)
        default:
            return
        }
    }

    @IBAction func closeAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
