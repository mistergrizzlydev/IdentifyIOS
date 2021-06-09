//
//  OnBoardingDetailViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 19.02.2021.
//

import UIKit

class SDKOnBoardingDetailViewController: SDKBaseViewController {
    
    var textArray = [String]()
    var imgArray = [UIImage(imageLiteralResourceName: "ob1"), UIImage(imageLiteralResourceName: "ob2"), UIImage(imageLiteralResourceName: "ob3"), UIImage(imageLiteralResourceName: "ob4")]
    
    var cominTitle = ""
    var currentIndex = 0
    
    weak var delegate: OnboardButtonListener?
    @IBOutlet weak var nextBtnTxt: UIButton!
    @IBOutlet weak var nextBtnImg: UIButton!
    @IBOutlet weak var backBtnImg: UIButton!
    @IBOutlet weak var backBtnTxt: UIButton!
    
    @IBOutlet weak var boardImg: UIImageView!
    @IBOutlet weak var boardPageControl: UIPageControl!
    @IBOutlet weak var boardLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        translate()
    }
    
    func translate() {
        textArray.append(translate(text: .board1))
        textArray.append(translate(text: .board2))
        textArray.append(translate(text: .board3))
        textArray.append(translate(text: .board4))
        populate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        boardPageControl.currentPage = currentIndex
        
    }
    
    func populate() {
        self.boardImg.image = imgArray[currentIndex]
        self.boardLabel.text = textArray[currentIndex]
        boardPageControl.numberOfPages = textArray.count
        
        backBtnTxt.addTarget(self, action: #selector(backPageAct), for: .touchUpInside)
        backBtnImg.addTarget(self, action: #selector(backPageAct), for: .touchUpInside)
        changeNextButtonAction()
    }
    
    func changeNextButtonAction() {
        standartButtonActions()
        standartButtonsText()
        if currentIndex == 0 {
            backBtnTxt.setTitleColor(UIColor(named: "80 White"), for: .normal)
            backBtnTxt.setTitle(translate(text: .skipPage), for: .normal)
            backBtnTxt.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
            backBtnImg.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
            backBtnImg.isHidden = true
        } else if currentIndex == imgArray.count - 1 {
            nextBtnTxt.setTitle(self.translate(text: .continuePage), for: .normal)
            nextBtnTxt.setTitleColor(UIColor(named: "Yellow"), for: .normal)
            nextBtnImg.isHidden = true
            nextBtnTxt.addTarget(self, action: #selector(self.backToHome), for: .touchUpInside)
        } else {
            nextBtnTxt.setTitle(self.translate(text: .nextPage), for: .normal)
            nextBtnTxt.setTitleColor(UIColor(named: "KB White"), for: .normal)
            backBtnTxt.setTitleColor(UIColor(named: "KB White"), for: .normal)
            nextBtnImg.isHidden = false
        }
    }
    
    func standartButtonsText() {
        nextBtnTxt.setTitle(translate(text: .nextPage), for: .normal)
        backBtnTxt.setTitle(translate(text: .backPage), for: .normal)
    }
    
    func standartButtonActions() {
        nextBtnTxt.addTarget(self, action: #selector(nextPageAct), for: .touchUpInside)
        nextBtnImg.addTarget(self, action: #selector(nextPageAct), for: .touchUpInside)
        backBtnTxt.addTarget(self, action: #selector(backPageAct), for: .touchUpInside)
        backBtnImg.addTarget(self, action: #selector(backPageAct), for: .touchUpInside)
    }
    
    @objc func backToHome() {
        self.dismiss(animated: true)
    }
    
    @objc func nextPageAct() {
        delegate?.nextPage()
    }
    
    @objc func backPageAct() {
        delegate?.backPage()
    }
    
}

