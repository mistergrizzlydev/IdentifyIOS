//
//  SmsScreenViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 25.01.2021.
//

import UIKit
import CHIOTPField
import IdentifyIOS

protocol SmsStatusDelegate: class {
    func isCompleted(status: Bool)
}

class SmsScreenViewController: SDKBaseViewController {
    
    @IBOutlet weak var connectLabel: UILabel!
    @IBOutlet weak var smsInfoLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var submitHolderView: UIView!
    weak var delegate: SmsScreenDelegate?
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var codeTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        translate()
        setupViews()
        codeTxt.becomeFirstResponder()
        codeTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func translate() {
        self.smsInfoLabel.text = self.translate(text: .enterSmsCode)
        self.connectLabel.text = self.translate(text: .connect)
    }
    
    func setupViews() {
        appLogo.image = GlobalConstants.appLogo
        self.addGradientBackground(view: backView)
        submitHolderView.layer.cornerRadius = 12
        submitHolderView.addShadow()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 6 {
            delegate?.smsTag(tag: textField.text!)
        }
    }
        
    @objc func doneBtnAct() {
        self.view.endEditing(true)
    }

}

extension SmsScreenViewController: SmsStatusDelegate {
    func isCompleted(status: Bool) {
        if status == false {
            DispatchQueue.main.async {
                self.popupAlert(title: self.translate(text: .coreError), message: self.translate(text: .wrongSMSCode), actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
                    self.codeTxt.text = ""
                }])
            }
        }
    }
    
    
}
