//
//  SelfieViewController.swift
//  Kimlik
//
//  Created by Emir Beytekin on 1.04.2021.
//

import UIKit
import AVKit
import MobileCoreServices
import IdentifyIOS

protocol SelfieDelegate:class {
    func selfieCompleted()
}

class SDKSelfieViewController: SDKBaseViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var backGround: UIView!
    @IBOutlet weak var comingPhotoView: UIImageView!
    var manager: IdentifyManager?
    weak var delegate: SelfieDelegate?
    weak var oldDeviceSmileyDelegate: SmileDelegate?
    @IBOutlet weak var appLogo: UIImageView!
    var selfieTypes: SelfieTypes? = .selfie
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var againBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appLogo.image = GlobalConstants.appLogo
        self.view.backgroundColor = DesignConstants.selfieScrBackgroundColor
        self.setupUI()
        switch selfieTypes {
        case .video:
            if DesignConstants.selfieScrVideoShowInfoPopUp == true {
                DispatchQueue.main.async {
                    self.showPopUp(image: UIImage(imageLiteralResourceName: "ob3"), desc: DesignConstants.selfieScrVideoPopUpInfoText!)
                }
            }
            
        case .oldPhoneFace:
            if DesignConstants.selfieScrLivenessShowInfoPopUp == true {
                DispatchQueue.main.async {
                    self.showPopUp(image: UIImage(imageLiteralResourceName: "ob3"), desc: DesignConstants.selfieScrLivenessPopUpInfoText)
                }
            }
            
        case .selfie:
            if DesignConstants.selfieScrSelfieShowInfoPopUp == true {
                DispatchQueue.main.async {
                    self.showPopUp(image: UIImage(imageLiteralResourceName: "ob3"), desc: DesignConstants.selfieScrSelfiePopUpInfoText!)
                }
            }
            
        case .frontId:
            if DesignConstants.selfieScrIdFrontShowInfoPopUp == true {
                DispatchQueue.main.async {
                    self.showPopUp(image: UIImage(imageLiteralResourceName: "ob3"), desc: DesignConstants.selfieScrIdFrontPopUpInfoText!)
                }
            }
            
        default:
            return
        }
        addSkipModulesButton()
    }
    
    func setupUI() {
        submitBtn.alpha = DesignConstants.selfieScrCancelDisableAlpha
        submitBtn.backgroundColor = DesignConstants.selfieScrSubmitBtnBackColor
        submitBtn.setTitleColor(DesignConstants.selfieScrSubmitBtnColor, for: .normal)
        submitBtn.setTitle(DesignConstants.selfieScrSubmitBtnText, for: .normal)
        submitBtn.titleLabel?.font = DesignConstants.selfieScrSubmitBtnFont
        
        againBtn.backgroundColor = DesignConstants.selfieScrCancelBtnBackColor
        againBtn.setTitleColor(DesignConstants.selfieScrCancelBtnColor, for: .normal)
        againBtn.setTitle(DesignConstants.selfieScrCancelBtnText, for: .normal)
        againBtn.titleLabel?.font = DesignConstants.selfieScrCancelBtnFont
    }
    
    func openCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        switch selfieTypes {
        case .frontId, .backId:
            vc.cameraDevice = .rear
        case .video:
            vc.mediaTypes = [kUTTypeMovie as String]
            vc.cameraCaptureMode = .video
            vc.videoMaximumDuration = 5
        default:
            vc.cameraCaptureMode = .photo
            vc.cameraDevice = .front
        }
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image: UIImage? = info[.originalImage] as? UIImage
        if image != nil {
            submitBtn.isUserInteractionEnabled = true
            submitBtn.alpha = 1
            comingPhotoView.image = image
        }
        
        switch selfieTypes {
        case .oldPhoneFace:
            showLoader()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.detectSmiley()
            }
        case .video:
            submitBtn.isUserInteractionEnabled = true
            submitBtn.alpha = 1
        default:
            return
        }
    }

    @IBAction func submitAct(_ sender: Any) {
        self.showLoader()
        let portraitImg = fixOrientation(img: comingPhotoView.image ?? UIImage.init())
        let x = (comingPhotoView.image?.size.width ?? 1200) / 3
        let y = (comingPhotoView.image?.size.height ?? 1200) / 3
        let myImage = portraitImg.convert(toSize: CGSize(width: x, height: y), scale: UIScreen.main.scale)
        let idPhoto = myImage.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
        let portraitImage = myImage.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
        switch selfieTypes {
        case .selfie:
            self.manager?.netw.uploadSelfieImage(image: portraitImage, selfieType: .selfie, callback: { response, error in
                if response == true {
                    self.manager?.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadSelfie")
                    self.dismiss(animated: true) {
                        self.delegate?.selfieCompleted()
                        self.hideLoader()
                    }
                } else {
                    self.manager?.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadSelfie")
                    self.hideLoader()
                }
                if (error != nil) {
                    print(error?.localizedDescription)
                    self.hideLoader()
                }
            })
        case .frontId:
            self.manager?.netw.uploadSelfieImage(image: idPhoto, selfieType: .frontId, callback: { response, error in
                self.hideLoader()
                if response == true {
                    self.popupAlert(title: self.translate(text: .coreSuccess), message: DesignConstants.selfieScrIdBackPopUpInfoText, actionTitles: ["Tamam"], actions:[{ action1 in
                        self.selfieTypes = .backId
                        self.manager?.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadIdFront")
                        self.openCamera()
                        self.submitBtn.isUserInteractionEnabled = false
                        self.submitBtn.alpha = DesignConstants.selfieScrCancelDisableAlpha
                        self.comingPhotoView.image = UIImage()
                    }])
                } else {
                    self.manager?.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadIdFront")
                }
                if (error != nil) {
                    print(error?.localizedDescription)
                    self.hideLoader()
                }
            })
        case .backId:
            self.manager?.netw.uploadSelfieImage(image: idPhoto, selfieType: .backId, callback: { response, error in
                self.hideLoader()
                if response == true {
                    self.manager?.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadIdBack")
                    self.dismiss(animated: true) {
                        self.delegate?.selfieCompleted()
                    }
                } else {
                    self.manager?.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadIdBack")
                }
                
                if (error != nil) {
                    print(error?.localizedDescription)
                    self.hideLoader()
                }
                
            })
        case .video:
            self.dismiss(animated: true) {
                self.delegate?.selfieCompleted()
            }
        default:
            return
        }
        
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
    
    func detectSmiley() {
        let myImage = CIImage(image: comingPhotoView.image!)!
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: myImage, options: [CIDetectorSmile:true])
        if !faces!.isEmpty {
            for face in faces as! [CIFaceFeature] {
                hideLoader()
                if face.hasSmile == false {
                    self.popupAlert(title: self.translate(text: .coreError), message: "Gülümseyen bir yüz bulunamadı, tekrar deneyin", actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
                        self.openCamera()
                    }])
                } else {
                    self.dismiss(animated: true) {
                        self.oldDeviceSmileyDelegate?.smileCompleted()
                    }
                }
            }
        } else {
            hideLoader()
            self.popupAlert(title: self.translate(text: .coreError), message: "Yüz bulunamadı, tekrar deneyin", actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
                self.openCamera()
            }])
        }
    }
    
    func uploadErrorPopup() {
        self.popupAlert(title: self.translate(text: .coreError), message: "Yükleme sırasında hata oluştu, lütfen tekrar deneyin", actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
            self.openCamera()
        }])
    }
    
    @IBAction func reTakeAct(_ sender: Any) {
        self.openCamera()
    }
}
extension SDKSelfieViewController: PopUpProtocol {
    
    func handlePopUpAction(action: Bool) {
        self.openCamera()
    }
    
}

extension UIImage
{
    func convert(toSize size:CGSize, scale:CGFloat) -> UIImage
    {
        let imgRect = CGRect(origin: CGPoint(x:0.0, y:0.0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: imgRect)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return copied!
    }
}
