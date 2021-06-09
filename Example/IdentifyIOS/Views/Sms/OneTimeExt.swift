//
//  OneTimeExt.swift
//  Kimlik
//
//  Created by MacBookPro on 25.01.2021.
//

import Foundation
import UIKit

class OneTimeCodeTextField: UITextField {
    
    var defaultCharacter: String = "-"
    private var isConfigure = false
    var didEnterLastDigit: ((String)-> Void)?
     private var digitLabels = [UILabel]()
    private lazy var tapRecognizer: UITapGestureRecognizer = {
    let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    
    }()
    
    
    //use this function for one time
    func configure(with slotCount: Int = 6)  {
        guard  isConfigure == false else { return }
        // Use this method to toggle a Boolean value from true to false or from false to true.
            isConfigure.toggle()
        configureTextField()
        //Add StackView to AtextField and constrain it
        let labelStackView = createLabelStackViews(with: slotCount)
        addSubview(labelStackView)
        addGestureRecognizer(tapRecognizer)
        NSLayoutConstraint.activate([
            labelStackView.topAnchor.constraint(equalTo: topAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        
        }


    func configureTextField()  {
        textColor = .clear
        tintColor = .clear
        keyboardType = .numberPad
        textContentType = .oneTimeCode
       
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        delegate = self
    }
    
    func createLabelStackViews(with count: Int) -> UIStackView   {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        for _ in 1 ... count {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 20)
            label.textAlignment = .center
            label.clipsToBounds = true
            label.backgroundColor = .white
            label.isUserInteractionEnabled = true
            label.text = defaultCharacter
            label.textColor = UIColor.red
            stackView.addArrangedSubview(label)
            digitLabels.append(label)
            
        }
        
        return stackView
    
    }
    
    @objc func textDidChange(){
        guard let text = self.text , text.count <= digitLabels.count else { return }
        for i in 0 ..< digitLabels.count {
            let currentLabel = digitLabels[i]
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i )
                currentLabel.text = String(text[index])
            }else{
                currentLabel.text? = defaultCharacter
            }
        }
        if text.count == digitLabels.count {
            didEnterLastDigit?(text)
        }
    }
    
    }
    
extension OneTimeCodeTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterCount = textField.text?.count else{ return false}
        return characterCount < digitLabels.count || string == ""
    }
}
