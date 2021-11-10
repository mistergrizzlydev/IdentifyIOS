//
//  PopUpActionViewController.swift
//  Kimlik
//
//  Created by Emir Beytekin on 2.04.2021.
//

import UIKit
import IdentifyIOS
import Lottie

class SDKPopUpActionViewController: SDKBaseViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var popupImg: UIImageView!
    @IBOutlet weak var popupDesc: UILabel!
    var delegate: PopUpProtocol?
    
    var textArray = [String]()
    var imgArray = [UIImage(imageLiteralResourceName: "ob1"), UIImage(imageLiteralResourceName: "ob2"), UIImage(imageLiteralResourceName: "ob3"), UIImage(imageLiteralResourceName: "ob4")]
    
    var popUpImage = UIImage()
    var popUpDesc = String()
    var haveAnimation = false
    var animatonName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        translater()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        //customizing the dialog box view
        popupView.layer.cornerRadius = 6.0
        popupView.layer.borderWidth = 0.2
        popupView.layer.borderColor = UIColor.gray.cgColor
        popupView.addShadow()
    }
    
    func translater() {
        textArray.append(translate(text: .board1))
        textArray.append(translate(text: .board2))
        textArray.append(translate(text: .board3))
        textArray.append(translate(text: .board4))
        populate()
    }
    
    func populate() {
        if haveAnimation {
            let animationView = UIView()
            animationView.frame = popupImg.frame
            popupImg.addSubview(animationView)
            self.setAnimation(view: animationView, name: animatonName, loop: true)
            self.popupDesc.text = popUpDesc
        } else {
            self.popupDesc.text = popUpDesc
            self.popupImg.image = popUpImage
        }
        
    }
    
    @IBAction func okayAction(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.handlePopUpAction(action: true)
        }
    }
    
    static func showPopup(parentVC: UIViewController, infoImage: UIImage, infoText: String) {
        let myBundle = Bundle(for: SDKPopUpActionViewController.self)
        let myStoryboard = UIStoryboard(name: "KYC", bundle: myBundle).instantiateSB() as SDKPopUpActionViewController
        myStoryboard.modalPresentationStyle = .custom
        myStoryboard.modalTransitionStyle = .crossDissolve
        myStoryboard.delegate = parentVC as? PopUpProtocol
        myStoryboard.popUpImage = infoImage
        myStoryboard.popUpDesc = infoText
            parentVC.present(myStoryboard, animated: true)
    }
    
    static func showAnimationPopup(parentVC: UIViewController, animation: String, infoText: String) {
        let myBundle = Bundle(for: SDKPopUpActionViewController.self)
        let myStoryboard = UIStoryboard(name: "KYC", bundle: myBundle).instantiateSB() as SDKPopUpActionViewController
        myStoryboard.modalPresentationStyle = .custom
        myStoryboard.modalTransitionStyle = .crossDissolve
        myStoryboard.delegate = parentVC as? PopUpProtocol
        myStoryboard.haveAnimation = true
        myStoryboard.animatonName = animation
        myStoryboard.popUpDesc = infoText
            parentVC.present(myStoryboard, animated: true)
    }

}

public extension UIView
{
    static func loadFromXib<T>(withOwner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil) -> T where T: UIView
    {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "\(self)", bundle: bundle)

        guard let view = nib.instantiate(withOwner: withOwner, options: options).first as? T else {
            fatalError("Could not load view from nib file.")
        }
        return view
    }
}
