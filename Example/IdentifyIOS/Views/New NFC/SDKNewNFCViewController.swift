//
//  SDKNewNFCViewController.swift
//  Kimlik
//
//  Created by Emir Beytekin on 28.09.2021.
//

import UIKit
import WeScan
import MLKit
import NFCPassportReader
import IdentifyIOS

enum CardType: String {
    case idCard
    case passport
    case oldSchool
}

protocol DismissIDDelegate {
    func updateKeys(birtdate: String, docNo: String, validDate: String)
    func updateSelectedType(cardType: CardType)
}

@available(iOS 13, *)
class SDKNewNFCViewController: SDKBaseViewController, PopUpProtocol {
    
    enum ScreenType: String {
        case frontID
        case backID
    }
    
    struct IdInfo {
        var birthDate: String!
        var docNo: String!
        var validDate: String!
        var infoCompleted: Bool? = false
        
        init() { }
    }
    
    var delegate: ScannerStatusDelegate?
    var nfcErrorCount = 0
    var comingPhotoView = UIImageView()
    
    var scrType: ScreenType? = .frontID
    var currentScr: ScreenType? = .frontID
    var cardType: CardType? = .idCard
    var resultsText = ""
    @IBOutlet weak var infoLbl: UILabel!
    
    var frontBirthDateOk = false
    var frontDocNoOk = false
    var frontValidDateOk = false
    
    var backBirthDate = ""
    var backBirhDateOk = false
    var backDocNo = ""
    var backDocNoOk = false
    var backValidDate = ""
    var backValidDateOk = false
    var mrzLine1 = ""
    var mrzLine1Ok = false
    var mrzLine2 = ""
    var mrzLine2Ok = false
    
    var frontInfo = IdInfo()
    var backInfo = IdInfo()
    
    let passportReader = PassportReader.init()
    var isWantNfc = true
    var withoutMrz = false
    var currentOrientation: UIImage.Orientation = .up
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var backgroundIdPhoto: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        openInfoScreen(page: .nfc)
        addSkipModulesButton()
        reloadViews()
        self.withoutMrz = manager.mrzBirthDate != "" && manager.mrzValidDate != "" && manager.mrzDocumentNo != ""
        if manager.verificationCardType == .all {
            let next = SDKScannerSelectorViewController.instantiate()
            next.isModalInPresentation = true
            next.modalPresentationStyle = .fullScreen
            next.delegate = self
            DispatchQueue.main.async {
                self.present(next, animated: true, completion: {
                    self.reloadViews()
                })
            }
        } else {
            isWantNfc = true
            self.cardType = .idCard
            self.backgroundIdPhoto.image = #imageLiteral(resourceName: "frontId")
            reloadViews()
        }
        
        
    }
    
    func reloadViews() {
        if withoutMrz && !manager.nfcCompleted {
            editBtn.addTarget(self, action: #selector(infoAct), for: .touchUpInside)
        } else if isWantNfc {
            switch cardType {
            case .passport:
                infoLbl.text = self.translate(text: .nfcPassportScanInfo)
            case .idCard:
                infoLbl.text = self.translate(text: .nfcIDScanInfo)
            default:
                return
            }
        } else {
            infoLbl.text = self.translate(text: .nfcDocumentScanInfo)
        }
        self.editBtn.setTitle(self.translate(text: .coreScan), for: .normal)
        editBtn.addTarget(self, action: #selector(infoAct), for: .touchUpInside)
    }
    
    func openSelectArea() {
        let next = SDKScannerSelectorViewController.instantiate()
        next.isModalInPresentation = true
        next.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(next, animated: true, completion: nil)
        }
    }
    
    func goToWaitScreen() {
        self.dismiss(animated: true, completion: {
            switch self.cardType {
            case .passport, .idCard:
                self.delegate?.nfcCompleted(isOldSchool: false)
            case .oldSchool:
                self.delegate?.nfcCompleted(isOldSchool: true)
            default:
                return
            }
            
        })
    }
    
    func showInfo() {
        
        if cardType == .oldSchool {
            switch scrType {
            case .frontID:
                self.showPopUp(image: #imageLiteral(resourceName: "travel"), desc: self.translate(text: .newDocumentFront))
            case .backID:
                self.showPopUp(image: #imageLiteral(resourceName: "travel"), desc: self.translate(text: .newDocumentBack))
            default:
                return
            }
        } else if cardType == .passport {
            switch scrType {
                case .frontID:
                self.showPopUp(image: #imageLiteral(resourceName: "passport"), desc: self.translate(text: .newNfcFront))
            default:
                return
            }
        } else {
            switch scrType {
            case .frontID:
                if withoutMrz && !manager.nfcCompleted {
                    self.showPopUp(image: UIImage(named: "ob2")!, desc: DesignConstants.nfcScrWithoutMrzInfoText!)
                } else {
                    self.showPopUp(image: #imageLiteral(resourceName: "frontId"), desc: self.translate(text: .newNfcFront))
                }
            case .backID:
                self.showPopUp(image: #imageLiteral(resourceName: "backId"), desc: self.translate(text: .newNfcBack))
            default:
                return
            }
        }
    }
    
    func handlePopUpAction(action: Bool) {
        if withoutMrz && !manager.nfcCompleted {
            self.startNfc()
        } else {
            switch scrType {
            case .frontID:
                startReader()
            case .backID:
                startReader()
            default:
                return
            }
        }
    }
    
    @objc func infoAct() {
        showInfo()
    }
    
    func startReader() {
        let scannerViewController = ImageScannerController()
        if #available(iOS 13.0, *) {
            scannerViewController.isModalInPresentation = true
        }
        scannerViewController.modalPresentationStyle = .fullScreen
        scannerViewController.imageScannerDelegate = self
        present(scannerViewController, animated: true)
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
    
    func uploadPhoto() {
        self.showLoader()
        let portraitImg = fixOrientation(img: comingPhotoView.image ?? UIImage.init())
        let x = (comingPhotoView.image?.size.width ?? 1200) / 3
        let y = (comingPhotoView.image?.size.height ?? 1200) / 3
        let myImage = portraitImg.convert(toSize: CGSize(width: x, height: y), scale: UIScreen.main.scale)
        let idPhoto = myImage.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
        
        switch currentScr {
        case .frontID:
            self.manager.netw.uploadSelfieImage(image: idPhoto, selfieType: .frontId, callback: { response in
                self.hideLoader()
                if response.result == true {
                    if self.cardType == .passport {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.startNfc()
                        }
                    } else {
                        self.manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadIdFront")
                        self.currentScr = .backID
                        self.scrType = .backID
                        self.showInfo()
                        self.comingPhotoView.image = UIImage()
//                        self.popupAlert(title: self.translate(text: .coreSuccess), message: DesignConstants.selfieScrIdBackPopUpInfoText, actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
//                            self.manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadIdFront")
//                            self.currentScr = .backID
//                            self.scrType = .backID
//                            self.showInfo()
//                            self.comingPhotoView.image = UIImage()
//                        }])
                    }
                    
                } else {
                    self.manager.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadIdFront")
                }
            })
        case .backID:
            self.manager.netw.uploadSelfieImage(image: idPhoto, selfieType: .backId, callback: { response in
                self.hideLoader()
                if response.result == true {
                    self.manager.sendSelfieImageStatus(uploadStatus: "true", actionName: "uploadIdBack")
                    
                    if self.manager.nfcCompleted {
                        self.manager.nfcCompleted = true // aslında nfc yok ama hack amaçlı yazıyoruz, böylece nfc den sonra tekrar foto çekme modülü açılmıyor
                        self.goToWaitScreen()
                    } else if self.frontInfo.birthDate == nil && self.isWantNfc || self.frontInfo.birthDate == nil && self.isWantNfc || self.frontInfo.validDate == nil && self.isWantNfc { // parlak ışıklı çekimlerde datalardan hata gelebiliyor
                        DispatchQueue.main.async {
                            self.currentScr = .frontID
                            self.openEditPanel()
                        }
                    } else {
                        if self.isWantNfc && self.nfcAvailable && self.manager.activeScreen == .nfc { // bu ekranda nfc kullanılmak isteniyorsa ve cihazı destekliyorsa tarayıcı başlar
                            self.startNfc()
                        } else { // istemiyorsa sonraki modüle geçiyoruz
                            self.manager.nfcCompleted = true // aslında nfc yok ama hack amaçlı yazıyoruz, böylece nfc den sonra tekrar foto çekme modülü açılmıyor
                            self.goToWaitScreen()
                        }
                    }
                } else {
                    self.manager.sendSelfieImageStatus(uploadStatus: "false", actionName: "uploadIdBack")
                }
            })
        default:
            return
        }
    }

}

@available(iOS 13, *)
extension SDKNewNFCViewController {
    
    func readFrontPage(text: String) {
        let range = NSRange(location: 0, length: text.utf16.count)
        let documentRegex = try! NSRegularExpression(pattern: "^([A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{5})$")
        let documentErrorRegex = try! NSRegularExpression(pattern: "^([A-Z]{2}[0-9]{1}[A-Z]{1}[0-9]{5})$")
        let documentNoAllErrorRegex = try! NSRegularExpression(pattern: "^([A-Z]{1}[0-9]{8})") // ilk karakter string, gerisini int okursa
        
        // pasaport için ek
        let passportMrzLine = try! NSRegularExpression(pattern: "([A-Z]{1}[0-9]{9}[A-Z]{3}[0-9]{7}[A-Z]{1}[0-9]{18}[<]{3}[0-9]{2}$)")
        var replace = text.replacingOccurrences(of: "«", with: "<", options: .literal, range: nil)
        replace = text.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)

        
        // doğum tarihi ve geçerlilik tarihi
        let dateRegex = try! NSRegularExpression(pattern: "^(0[1-9]|[12][0-9]|3[01])[.](0[1-9]|1[012])[.](19|20)") //  // "(^[0-9]{2}.[0-9]{2}.[0-9]{4})$"
        if !frontDocNoOk { // döküman no taraması tamamlanmamışsa
            
            if cardType == .passport {
                if passportMrzLine.firstMatch(in: replace, options: [], range: range) != nil {
                    let docNo = matches(for: "(^[A-Z]{1}[0-9]{8})", in: replace)
                    let passportDates = matches(for: "([0-9]{7})", in: replace)
                    frontInfo.docNo = docNo[0]
                    frontInfo.birthDate = "\(passportDates[1].dropLast())"
                    frontInfo.validDate = "\(passportDates[2].dropLast())"
                    frontInfo.infoCompleted = true
                    backInfo.infoCompleted = true
                    
                }
            } else {
                if (documentRegex.firstMatch(in: text, options: [], range: range) != nil) {
                    frontInfo.docNo = text
                    print("ön döküman no: \(text)")
                    frontDocNoOk = true
                } else if (documentErrorRegex.firstMatch(in: text, options: [], range: range) != nil) {
                    var newText = ""
                    if text[1] == "D" || text[1] == "O" {
                        newText = replaceWrongChr(myString: text, 1, "0")
                    } else if text[1] == "Z" {
                        newText = replaceWrongChr(myString: text, 1, "2")
                    } else if text[1] == "S" {
                        newText = replaceWrongChr(myString: text, 1, "5")
                    } else if text[1] == "I" {
                        newText = replaceWrongChr(myString: text, 1, "1")
                    }
                    frontInfo.docNo = newText
                    print("ön döküman değiştirilmiş no: \(frontInfo.docNo ?? "")")
                    frontDocNoOk = true
                } else if (documentNoAllErrorRegex.firstMatch(in: text, options: [], range: range) != nil) {
                    var newText = ""
                    if text[3] == "0" {
                        newText = replaceWrongChr(myString: text, 3, "O")
                    } else if text[3] == "2" {
                        newText = replaceWrongChr(myString: text, 3, "Z")
                    } else if text[3] == "0" {
                        newText = replaceWrongChr(myString: text, 3, "O")
                    } else if text[3] == "1" {
                        newText = replaceWrongChr(myString: text, 3, "I")
                    }
                    frontInfo.docNo = newText
                    print("ön döküman değiştirilmiş no: \(frontInfo.docNo ?? "")")
                    frontDocNoOk = true
                }
            }
            
            
        }
        
        if !frontBirthDateOk || !frontValidDateOk {
            if (dateRegex.firstMatch(in: text, options: [], range: range) != nil) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.YYYY"
                let date = dateFormatter.date(from:text)
                let delta = date?.timeIntervalSince(Date()) ?? 0
                if delta < 0 {
                    frontInfo.birthDate = text
                    print("ön doğum tarihi: \(frontInfo.birthDate ?? "")")
                    frontBirthDateOk = true
                } else {
                    frontInfo.validDate = text
                    print("ön valid tarihi: \(frontInfo.validDate ?? "")")
                    frontValidDateOk = true
                }
            }
        }
        
        if frontBirthDateOk && frontValidDateOk && frontDocNoOk {
            frontInfo.infoCompleted = true
//            scrType = .backID
//            showInfo()
        }
    }
    
    func readBackPage(text: String) {
        let range = NSRange(location: 0, length: text.utf16.count)
        
        // line 1
        let idRegexLine1 = try! NSRegularExpression(pattern: "(^[A|C|I][A-Z0-9<]{1})([A-Z]{3})([A-Z0-9<]{24})")
        if !mrzLine1Ok {
            if (idRegexLine1.firstMatch(in: text.trimmingCharacters(in: .whitespacesAndNewlines), options: [], range: range) != nil) {
                var newText = text
                if text[6] == "D" || text[6] == "O" {
                    newText = replaceWrongChr(myString: text, 6, "0")
                }
                newText = newText.replacingOccurrences(of: " ", with: "")
                mrzLine1 = newText
                // mrz satırında bulunan doküman numarasını arıyoruz
                let trueDate = matches(for: "([A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{5})", in: newText) //
                let wrongDate = matches(for: "([A-Z]{1}[0-9]{8})", in: newText)
                if trueDate.count > 0 {
                    backInfo.docNo = trueDate.first!
                    backDocNoOk = true
                    mrzLine1Ok = true
                    print("back doc no: \(backInfo.docNo ?? "")")
                } else if wrongDate.count > 0 {
                    var newDocNo = ""
                    if wrongDate.first![3] == "0" {
                        newDocNo = replaceWrongChr(myString: wrongDate.first!, 3, "O")
                    }
                    backInfo.docNo = newDocNo
                    print("back değişen doc no: \(backInfo.docNo ?? "")")
                    backDocNoOk = true
                    mrzLine1Ok = true
                }
            }
        }
        
        // line 2
        let idRegexLine2 = try! NSRegularExpression(pattern:"^([0-9]{7})([M|F|X|<]{1})([0-9]{7})")
        if !mrzLine2Ok {
            if (idRegexLine2.firstMatch(in: text.trimmingCharacters(in: .whitespacesAndNewlines), options: [], range: range) != nil) {
                let birthDay = matches(for: "([0-9]{7})", in: text)
                backInfo.birthDate = String(birthDay.first!.dropLast())
                backInfo.validDate = String(birthDay.last!.dropLast())
                print("back doğum tarihi: \(backInfo.birthDate ?? "")")
                print("back valid tarihi: \(backInfo.validDate ?? "")")
                mrzLine2Ok = true
            }
        }
        
        if mrzLine1Ok && mrzLine2Ok {
            backInfo.infoCompleted = true
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func replaceWrongChr(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString)
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    private func resetResults() {
        resultsText = ""
    }
    
    private func getCardTexts() {
        
        let z = self.resultsText.components(separatedBy: "\n")
        for word in z {
            if scrType == .frontID {
                self.readFrontPage(text: word)
            } else if scrType == .backID {
                self.readBackPage(text: word)
            }
            
        }
    }
    
    func detectTextOnDevice(image: UIImage?) {
        guard let image = image else { return }
        let imgSize = image.size
        let onDeviceTextRecognizer = TextRecognizer.textRecognizer()
        let visionImage = VisionImage(image: image)
        if imgSize.width < imgSize.height {
            self.currentOrientation = .left
        } else {
            self.currentOrientation = .up
        }
        visionImage.orientation = self.currentOrientation
        self.resultsText += "Running On-Device Text Recognition...\n"
        process(visionImage, with: onDeviceTextRecognizer)
    }
    
    private func process(_ visionImage: VisionImage, with textRecognizer: TextRecognizer?) {
        weak var weakSelf = self
        textRecognizer?.process(visionImage) { text, error in
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            guard error == nil, let text = text else {
                self.resetResults()
                let errorString = error?.localizedDescription ?? ""
                strongSelf.resultsText = "Text recognizer failed with error: \(errorString)"
                strongSelf.getCardTexts()
                return
            }
            strongSelf.resultsText += "\(text.text.removingWhitespaces())\n"
            self.getCardTexts()
        }
    }
    
    @objc func startNfc() {
        
        if frontInfo.infoCompleted == true && backInfo.infoCompleted == true || withoutMrz == true {
            let passportUtil = PassportUtil()
            var mrzKey = passportUtil.makeMrzKey(birthDate: "", expireDate: "", documentNo: "")
            
            if withoutMrz {
                mrzKey = passportUtil.makeMrzKey(birthDate: manager.mrzBirthDate.toMrzDate(), expireDate: manager.mrzValidDate.toMrzDate(), documentNo: manager.mrzDocumentNo)
            } else {
                if cardType == .passport {
                    mrzKey = passportUtil.makeMrzKey(birthDate: frontInfo.birthDate, expireDate: frontInfo.validDate, documentNo: frontInfo.docNo)
                } else {
                    mrzKey = passportUtil.makeMrzKey(birthDate: frontInfo.birthDate.toMrzDate(), expireDate: frontInfo.validDate.toMrzDate(), documentNo: frontInfo.docNo)
                }
            }
            
            passportReader.readPassport(mrzKey: mrzKey, customDisplayMessage: { (displayMessage) in
                switch displayMessage {
                    case .requestPresentPassport:
                        return self.translate(text: .popNFC)
                    case .successfulRead:
                    return self.translate(text: .nfcSuccess)
                    case .readingDataGroupProgress(let dataGroup, let progress):
                        let progressString = self.handleProgress(percentualProgress: progress)
                        return "Veriler okunuyor \(dataGroup) ...\n\(progressString)"
                    default:
                        return nil
                }
            }, completed: { (passport, error) in
                if let passport = passport {
                    DispatchQueue.main.async {
                        passportUtil.passport = passport
                        var gender = "N/A"
                        if passportUtil.passport?.gender == "F" {
                            gender = "FEMALE"
                        } else if passportUtil.passport?.gender == "M" {
                            gender = "MALE"
                        }
                        var documentType = "Unknown"
                        if passportUtil.passport?.documentType == "P" {
                            documentType = "Passport"
                        } else if passportUtil.passport?.documentType == "I" {
                            documentType = "ID Card"
                        }
                                            
                        let img = passportUtil.passport?.passportImage?.toBase64()
                        
                        self.resetButton() // hatalı taramanın düzeltilmesinden sonra başarılı şekilde taranırsa butonu ve metni resetliyorum
                        
                        var passportDataElements : [String:String]? {
                            guard let dg1 = passportUtil.passport?.dataGroupsRead[.DG1] as? DataGroup1 else { return nil }
                            return dg1.elements
                        }
                        let idCardFrontText = passportDataElements?["5F1F"]
                        
                        
                        let idInfo = IdentifyCard(ident_id: self.manager.userToken, name: passportUtil.passport?.firstName ?? "", surname: passportUtil.passport?.lastName ?? "", personalNumber: passportUtil.passport?.personalNumber ?? "", birthdate: passportUtil.passport?.dateOfBirth.toNormalDate() ?? "", expireDate: passportUtil.passport?.documentExpiryDate.toNormalDate() ?? "", serialNumber: passportUtil.passport?.documentNumber ?? "", nationality: passportUtil.passport?.nationality ?? "", docType: documentType, authority: passportUtil.passport?.issuingAuthority ?? "", gender: gender, image: img, mrzInfo: idCardFrontText)
                                                                
                        self.manager.netw.verifyNFC(model: idInfo) { (resp) in
                            if resp.result == true {
                                self.manager.nfcCompleted = true
                                self.delegate?.nfcAvailable(status: true)
                                self.goToWaitScreen()
                            } else {
                                self.delegate?.nfcAvailable(status: false)
                                self.goToWaitScreen()
                            }
                        }
                        return
                    }
                } else {
                    AlertViewManager.defaultManager.showOkAlert("Identify", message: error.debugDescription) { (action) in
                        self.delegate?.nfcAvailable(status: false)
                        self.goToWaitScreen()
                    }
                }
                if let _ = error {
                    DispatchQueue.main.async {
                        self.editBtn.setTitle(self.translate(text: .nfcEditInfoTitle), for: .normal)
                        self.infoLbl.text = self.translate(text: .nfcEditInfoDesc)
                        self.editBtn.removeTarget(self, action: #selector(self.infoAct), for: .touchUpInside)
                        self.editBtn.addTarget(self, action: #selector(self.openEditPanel), for: .touchUpInside)
                    }
                    self.nfcErrorCount = self.nfcErrorCount + 1
                    if self.nfcErrorCount == GlobalConstants.nfcErrorMaxCount {
                        DispatchQueue.main.async {
                            self.delegate?.nfcAvailable(status: false)
                            self.goToWaitScreen()
                        }
                    }
                }
            })
            return
            
        } else {
            DispatchQueue.main.async {
                self.editBtn.setTitle(self.translate(text: .nfcEditInfoTitle), for: .normal)
                self.infoLbl.text = self.translate(text: .nfcEditInfoDesc)
                self.editBtn.removeTarget(self, action: #selector(self.infoAct), for: .touchUpInside)
                self.editBtn.addTarget(self, action: #selector(self.openEditPanel), for: .touchUpInside)
            }
        }
        
    }
    
    @objc func openEditPanel() {
        let next = KeysErrorViewController()
        next.delegate = self
        next.isModalInPresentation = true
        next.birthDateVal = self.frontInfo.birthDate ?? self.translate(text: .coreDate)
        next.validDateVal = self.frontInfo.validDate ?? self.translate(text: .coreDate)
        next.docNo = self.frontInfo.docNo ?? ""
        self.present(next, animated: true, completion: nil)
    }
    
    func handleProgress(percentualProgress: Int) -> String {
        let p = (percentualProgress/10)
        let full = String(repeating: "🔵", count: p)
        let empty = String(repeating: "⚪️", count: 10-p)
        return "\(full)\(empty)"
    }
}

@available(iOS 13, *)
extension SDKNewNFCViewController: ImageScannerControllerDelegate {
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        comingPhotoView.image = results.croppedScan.image
//        if manager.idPhotoCompleted == false { // eğer nfc den önce foto upload çalışırsa tekrar resmi upload etmiyoruz
//            uploadPhoto()
//        }
        if manager.nfcCompleted == false {
            detectTextOnDevice(image: results.croppedScan.image)
        }
        scanner.dismiss(animated: true) {
            if !self.manager.idPhotoCompleted {
                self.uploadPhoto()
            }
        }
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        scanner.dismiss(animated: true)
    }
    
}

@available(iOS 13, *)
extension SDKNewNFCViewController: DismissIDDelegate {
    
    func updateSelectedType(cardType: CardType) {
        switch cardType {
        case .idCard:
            isWantNfc = true
            self.cardType = .idCard
            self.backgroundIdPhoto.image = #imageLiteral(resourceName: "frontId")
        case .passport:
            isWantNfc = true
            self.cardType = .passport
            self.backgroundIdPhoto.image = #imageLiteral(resourceName: "passport")
        case .oldSchool:
            isWantNfc = false
            self.cardType = .oldSchool
            self.backgroundIdPhoto.image = #imageLiteral(resourceName: "travel")
        }
        reloadViews()
    }
    
    func updateKeys(birtdate: String, docNo: String, validDate: String) {
        if cardType == .passport {
            frontInfo.validDate = validDate.toMrzDate()
            frontInfo.birthDate = birtdate.toMrzDate()
        } else {
            frontInfo.validDate = validDate
            frontInfo.birthDate = birtdate
        }
        
        frontInfo.docNo = docNo
        frontInfo.infoCompleted = true
        backInfo.infoCompleted = true
        DispatchQueue.main.async {
            self.startNfc()
        }
    }
    
    func resetButton() {
        DispatchQueue.main.async {
            self.editBtn.setTitle(self.translate(text: .coreScan), for: .normal)
            if self.isWantNfc {
                self.infoLbl.text = self.translate(text: .nfcIDScanInfo)
            } else {
                self.infoLbl.text = self.translate(text: .nfcDocumentScanInfo)
            }
            self.editBtn.removeTarget(self, action: #selector(self.openEditPanel), for: .touchUpInside)
            self.editBtn.addTarget(self, action: #selector(self.infoAct), for: .touchUpInside)
        }
    }
    
}

extension String {
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func toMrzDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "yyMMdd"
        return dateFormatter.string(from: date ?? Date())
    }
    
    func toNormalDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date ?? Date())
    }
}
