//
//  SDKAddressViewController.swift
//  IdentifyIOS_Example
//
//  Created by Emir Beytekin on 3.11.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IdentifyIOS
import MobileCoreServices
import WeScan

protocol AddressDelegate: class {
    func addressCompleted()
}

class SDKAddressViewController: SDKBaseViewController {

    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var documentInfoLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var addressTxt: UITextView!
    @IBOutlet weak var docPhoto: UIImageView!
    var imagePicker = UIImagePickerController()
    var idPhoto = ""
    weak var delegate: AddressDelegate?
    var addressOk = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSkipModulesButton()
        setupUI()
        addressTxt.delegate = self
    }
    
    func setupUI() {
        self.appLogo.image = GlobalConstants.appLogo
        submitBtn.layer.cornerRadius = 12
        submitBtn.addShadow()
        photoBtn.layer.cornerRadius = 12
        photoBtn.addShadow()
    }

    @IBAction func photoAct(_ sender: Any) {
        self.showSheet()
    }
    
    func showSheet() {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Fotoğraf Çek", style: .default) { action -> Void in
            self.openScanner()
        }

        let secondAction: UIAlertAction = UIAlertAction(title: "Fotoğraf Seç", style: .default) { action -> Void in
            self.openGallery()
        }
        
//        let thirddAction: UIAlertAction = UIAlertAction(title: "Belge Seç", style: .default) { action -> Void in
//            self.attachDocument()
//        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
//        actionSheetController.addAction(thirddAction)
        actionSheetController.addAction(cancelAction)

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true) {
        }
    }
    
    private func attachDocument() {
        let types = [kUTTypePDF]
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)

        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = true
        }

        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet

        present(importMenu, animated: true)
    }
    
    private func openScanner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let scannerViewController = ImageScannerController()
            if #available(iOS 13.0, *) {
                scannerViewController.isModalInPresentation = true
            }
            scannerViewController.modalPresentationStyle = .fullScreen
            scannerViewController.imageScannerDelegate = self
            self.present(scannerViewController, animated: false)
        }
    }
    
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func submitForm() {
        if checkSubmitAvailablity() {
            self.showLoader()
            self.manager.netw.uploadAddressInfo(image: self.idPhoto, addressText: self.addressTxt.text ?? "", callback: { response in
                self.hideLoader()
                if response.result == true {
                    self.manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "validateAddress")
                    self.dismiss(animated: true) {
                        self.delegate?.addressCompleted()
                    }
                } else {
                    self.popupAlert(title: self.translate(text: .coreError), message: "Hata oluştu, tekrar deneyin", actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
                    }])
                    self.manager.sendSelfieImageStatus(uploadStatus: "false", actionName: "validateAddress")
                }
            })
        }
        
    }
    
    @discardableResult func checkSubmitAvailablity() -> Bool {
        if idPhoto != "" && addressOk == true {
            submitBtn.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.3) {
                self.submitBtn.alpha = 1
            }
            return true
        } else {
            submitBtn.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.3) {
                self.submitBtn.alpha = 0.6
            }
            return false
        }
    }
}

extension SDKAddressViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        docPhoto.image = UIImage(named: "pdf")
    }

     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        let image: UIImage? = info[.originalImage] as? UIImage
        
        if image != nil {
            docPhoto.image = image
            self.idPhoto = image?.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
            checkSubmitAvailablity()
        }
    }
}

extension SDKAddressViewController: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        docPhoto.image = results.croppedScan.image
        self.idPhoto = results.croppedScan.image.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
        checkSubmitAvailablity()
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

extension SDKAddressViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            addressOk = true
            checkSubmitAvailablity()
        } else {
            addressOk = false
            checkSubmitAvailablity()
        }
    }
    
}
