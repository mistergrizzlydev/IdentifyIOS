//
//  SignatureViewController.swift
//  Kimlik
//
//  Created by Emir Beytekin on 15.04.2021.
//

import UIKit
import SwiftSignatureView
import PencilKit
import IdentifyIOS

protocol SignatureDelegate:class {
    func signatureCompleted()
}

class SDKSignatureViewController: SDKBaseViewController {
    
    var manager: IdentifyManager?
    @IBOutlet var backView: UIView!
    @IBOutlet weak var signatureView: SwiftSignatureView!
    @IBOutlet weak var signDescLabel: UILabel!
    
    weak var delegate: SignatureDelegate?
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var againBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignConstants.signatureScrBackgroundColor
        setupUI()
        if #available(iOS 13.0, *) { // dark mode için gerekli
            if let signaturInnerView = signatureView.subviews.first(where: {$0 is ISignatureView}) {
                if let canvasView = signaturInnerView.subviews.first(where: {$0 is PKCanvasView}) {
                canvasView.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)
                }
            }
        }
        signatureView.delegate = self
        self.signatureView.backgroundColor = UIColor.white
        addSkipModulesButton()
    }
    
    func setupUI() {
        sendBtn.alpha = DesignConstants.signatureScrCancelDisableAlpha
        sendBtn.backgroundColor = DesignConstants.signatureScrSubmitBtnBackColor
        sendBtn.setTitleColor(DesignConstants.signatureScrSubmitBtnColor, for: .normal)
        sendBtn.setTitle(DesignConstants.signatureScrSubmitBtnText, for: .normal)
        sendBtn.titleLabel?.font = DesignConstants.signatureScrSubmitBtnFont
        
        againBtn.backgroundColor = DesignConstants.signatureScrCancelBtnBackColor
        againBtn.setTitleColor(DesignConstants.signatureScrCancelBtnColor, for: .normal)
        againBtn.setTitle(DesignConstants.signatureScrCancelBtnText, for: .normal)
        againBtn.titleLabel?.font = DesignConstants.signatureScrCancelBtnFont
        
        signDescLabel.text = DesignConstants.signatureScrDescText
        signDescLabel.textColor = DesignConstants.signatureScrDescTextColor
        signDescLabel.font = DesignConstants.signatureScrDescTextFont
        
        
    }
    
    @IBAction func clearSignAct(_ sender: Any) {
        signatureView.clear()
        sendBtn.isUserInteractionEnabled = false
        sendBtn.alpha = DesignConstants.signatureScrCancelDisableAlpha
    }
    
    @IBAction func sendSignAct(_ sender: Any) {
        showLoader()
        guard let signatureImg = signatureView.getCroppedSignature()?.convert(toSize: CGSize(width: 400, height: 250), scale: UIScreen.main.scale).toBase64() else { return }
        self.manager?.netw.uploadSelfieImage(image: signatureImg, selfieType: .signature, callback: { response, error in
            self.hideLoader()
            if response == true {
                self.dismiss(animated: true) {
                    self.delegate?.signatureCompleted()
                }
            }
            
            if (error != nil) {
                print(error?.localizedDescription)
                self.hideLoader()
            }
        })
    }
}

extension SDKSignatureViewController: SwiftSignatureViewDelegate {
    func swiftSignatureViewDidDrawGesture(_ view: ISignatureView, _ tap: UIGestureRecognizer) { }
    
    func swiftSignatureViewDidDraw(_ view: ISignatureView) { // imza tamamlandı
        sendBtn.isUserInteractionEnabled = true
        sendBtn.alpha = 1
    }
}

