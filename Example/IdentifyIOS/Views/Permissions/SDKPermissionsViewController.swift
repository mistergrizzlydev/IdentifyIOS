//
//  SDKPermissionsViewController.swift
//  IdentifyIOS_Example
//
//  Created by Emir Beytekin on 9.06.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Speech

protocol PermissionViewDelegate {
    func permissionCompleted()
}

class SDKPermissionsViewController: SDKBaseViewController {
    
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var camBtn: UIButton!
    @IBOutlet weak var speechBtn: UIButton!
    @IBOutlet weak var permissionTitle: UILabel!
    @IBOutlet weak var permissionDesc: UILabel!
    @IBOutlet weak var dismissBtn: UIButton!
    
    var micOk = false
    var camOk = false
    var speechOk = false
    var permissionDelegate: PermissionViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        microphoneReq()
        self.micBtn.addTarget(self, action: #selector(micRequest), for: .touchUpInside)
        self.camBtn.addTarget(self, action: #selector(camRequest), for: .touchUpInside)
        self.speechBtn.addTarget(self, action: #selector(speechReq), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        speechRequest()
    }
    
    func setupUI() {
        self.view.backgroundColor = DesignConstants.permissionScrBackgroundColor
        self.permissionTitle.text = DesignConstants.permissionTitle
        self.permissionTitle.textColor = DesignConstants.permissionTitleColor
        self.permissionDesc.text = DesignConstants.permissionDesc
        self.permissionDesc.textColor = DesignConstants.permissionDescColor
    }
    
    @objc func micRequest() {
        self.goToSettings()
    }
    
    @objc func camRequest() {
        self.goToSettings()
    }
    
    @objc func speechReq() {
        self.goToSettings()
    }
    
    @objc func dismissPermissionScreen() {
        self.dismiss(animated: true, completion: {
            self.permissionDelegate?.permissionCompleted()
        })
    }
    
    func goToSettings() {
        let alertController = UIAlertController (title: DesignConstants.permissionAlertTitle, message: DesignConstants.permissionAlertDesc, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: DesignConstants.permissionAlertPositiveAct, style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: DesignConstants.permissionAlertNegativeAct, style: .default, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func changeBtnApproved(btn: UIButton) {
        DispatchQueue.main.async {
            btn.backgroundColor = DesignConstants.acceptedtedBtnBackColor
            btn.isUserInteractionEnabled = false
        }
    }
    
    func changeBtnReject(btn: UIButton) {
        DispatchQueue.main.async {
            btn.backgroundColor = DesignConstants.rejectedBtnBackColor
            btn.isUserInteractionEnabled = true
        }
    }
    
    func microphoneReq() {
        let microPhoneStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch microPhoneStatus {
        case .authorized:
            changeBtnApproved(btn: micBtn)
            micOk = true
            self.wantCameraRequest()
        case .denied, .restricted, .notDetermined:
            changeBtnReject(btn: micBtn)
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { resp in
                if !resp {
                    self.changeBtnReject(btn: self.micBtn)
                } else {
                    self.micOk = true
                    self.changeBtnApproved(btn: self.micBtn)
                    self.wantCameraRequest()
                }
            })
        @unknown default:
            return
        }
    }
    
    func wantCameraRequest() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .authorized:
            camOk = true
            self.changeBtnApproved(btn: self.camBtn)
            self.speechReq()
        case .denied, .restricted, .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { resp in
                if !resp {
                    self.changeBtnReject(btn: self.camBtn)
                } else {
                    self.camOk = true
                    self.changeBtnApproved(btn: self.camBtn)
                    self.speechRequest()
                }
            }
            self.changeBtnReject(btn: self.camBtn)
        default:
            return
        }
        addDismissAct()
    }
    
    func speechRequest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SFSpeechRecognizer.requestAuthorization { status in
                switch status {
                case .notDetermined, .restricted, .denied:
                    self.changeBtnReject(btn: self.speechBtn)
                case .authorized:
                    self.speechOk = true
                    self.changeBtnApproved(btn: self.speechBtn)
                    self.addDismissAct()
                @unknown default:
                    print("Unknown case")
              }
            }
        }
    }
    
    func addDismissAct() {
        if micOk && camOk && speechOk {
            DispatchQueue.main.async {
                self.dismissBtn.isHidden = false
                self.dismissBtn.addTarget(self, action: #selector(self.dismissPermissionScreen), for: .touchUpInside)
            }
        }
    }

}
