//
//  SelfieViewController.swift
//  Kimlik
//
//  Created by Emir Beytekin on 1.04.2021.
//

import UIKit
import AVKit
import MobileCoreServices
import WeScan
import AVFoundation
import IdentifyIOS

protocol SelfieDelegate: class {
    func selfieCompleted()
    func videoCompleted()
}

class SDKSelfieViewController: SDKBaseViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var backGround: UIView!
    @IBOutlet weak var comingPhotoView: UIImageView!
    weak var delegate: SelfieDelegate?
    weak var oldDeviceSmileyDelegate: SmileDelegate?
    @IBOutlet weak var appLogo: UIImageView!
    var selfieTypes: SelfieTypes? = .selfie
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var againBtn: UIButton!
    var videoData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSkipModulesButton()
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
        vc.allowsEditing = false
        vc.delegate = self
        switch selfieTypes {
        case .frontId, .backId:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let scannerViewController = ImageScannerController()
                if #available(iOS 13.0, *) {
                    scannerViewController.isModalInPresentation = true
                }
                scannerViewController.modalPresentationStyle = .fullScreen
                scannerViewController.imageScannerDelegate = self
                self.present(scannerViewController, animated: false)
            }
        case .video:
            vc.mediaTypes = [kUTTypeMovie as String]
            vc.cameraCaptureMode = .video
            vc.cameraDevice = .front
            vc.videoMaximumDuration = 5
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.present(vc, animated: false)
            }
        default:
            vc.cameraCaptureMode = .photo
            vc.cameraDevice = .front
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.present(vc, animated: false)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image: UIImage? = info[.originalImage] as? UIImage
        if image != nil {
            submitBtn.isUserInteractionEnabled = true
            submitBtn.alpha = 1
            comingPhotoView.image = image
            switch selfieTypes {
            
            case .selfie:
                comingPhotoView.image = image
                showLoader()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.detectFace()
                }
            case .oldPhoneFace:
                showLoader()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.detectSmiley()
                }
            default:
                return
            }
        }
        
        guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            return
        }
            do {
                let data = try Data(contentsOf: videoUrl, options: .mappedIfSafe)
                self.videoData = data
                let player = AVPlayer(url: videoUrl) // your video url
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = backGround.bounds
                
                backGround.layer.addSublayer(playerLayer)
                player.play()
//                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
//                   player.seek(to: CMTime.zero)
//                   player.play()
//                }
                
                switch selfieTypes {
                case .video:
                    submitBtn.isUserInteractionEnabled = true
                    submitBtn.alpha = 1
                default:
                    return
                }
            } catch  {
                print("error")
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
            self.manager.netw.uploadSelfieImage(image: portraitImage, selfieType: .selfie, callback: { response in
                if response.result == true {
                    self.manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadSelfie")
                    self.dismiss(animated: true) {
                        if self.selfieTypes == .selfie {
                            self.delegate?.selfieCompleted()
                        }
                        self.hideLoader()
                    }
                } else {
                    self.manager.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadSelfie")
                    self.hideLoader()
                }
            })
        case .frontId:
            self.manager.netw.uploadSelfieImage(image: idPhoto, selfieType: .frontId, callback: { response in
                self.hideLoader()
                if response.result == true {
                    self.popupAlert(title: self.translate(text: .coreSuccess), message: DesignConstants.selfieScrIdBackPopUpInfoText, actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
                        self.selfieTypes = .backId
                        self.manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadIdFront")
                        self.openCamera()
                        self.submitBtn.isUserInteractionEnabled = false
                        self.submitBtn.alpha = DesignConstants.selfieScrCancelDisableAlpha
                        self.comingPhotoView.image = UIImage()
                    }])
                } else {
                    self.manager.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadIdFront")
                }
            })
        case .backId:
            self.manager.netw.uploadSelfieImage(image: idPhoto, selfieType: .backId, callback: { response in
                self.hideLoader()
                if response.result == true {
                    self.manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadIdBack")
                    self.dismiss(animated: true) {
                        self.delegate?.selfieCompleted()
                    }
                } else {
                    self.manager.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadIdBack")
                }
            })
        case .video:
            self.manager.netw.uploadVideo(videoData: self.videoData) { response in
                self.hideLoader()
                if response.result == false {
                    self.manager.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadVideo")
                } else {
                    self.manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadVideo")
                    self.dismiss(animated: true) {
                        self.delegate?.videoCompleted()
                    }
                }
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
    
    func detectFace() {
        let myImage = CIImage(image: comingPhotoView.image!)!
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: myImage, options: [CIDetectorSmile:true])
        if !faces!.isEmpty {
            hideLoader()
            submitBtn.isUserInteractionEnabled = true
            submitBtn.alpha = 1
        } else {
            hideLoader()
            self.popupAlert(title: self.translate(text: .coreError), message: self.translate(text: .faceNotFound), actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
                self.openCamera()
            }])
        }
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
                    self.popupAlert(title: self.translate(text: .coreError), message: self.translate(text: .smilingFaceNotFound), actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
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
            self.popupAlert(title: self.translate(text: .coreError), message: self.translate(text: .faceNotFound), actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
                self.openCamera()
            }])
        }
    }
    
    func uploadErrorPopup() {
        self.popupAlert(title: self.translate(text: .coreError), message: self.translate(text: .coreUploadError), actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
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

extension SDKSelfieViewController: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        comingPhotoView.image = results.croppedScan.image
        submitBtn.isUserInteractionEnabled = true
        submitBtn.alpha = 1
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error.localizedDescription)
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
