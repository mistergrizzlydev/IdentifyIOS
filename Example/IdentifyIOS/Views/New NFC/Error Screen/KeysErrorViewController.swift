//
//  KeysErrorViewController.swift
//  drawtest
//
//  Created by Emir Beytekin on 14.09.2021.
//

import UIKit

class KeysErrorViewController: UIViewController, UITextFieldDelegate {
    
    var birthDateVal = ""
    var validDateVal = ""
    var docNo = ""
    @IBOutlet weak var updateBtn: UIButton!
    var isBirthday = false
    
    @IBOutlet weak var dontBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var documentTxt: UITextField!
    @IBOutlet weak var birthBtn: UIButton!
    @IBOutlet weak var validBtn: UIButton!
    var delegate: DismissIDDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHideKeyboardOnTap()
        updateArea()
        updateBtn.addTarget(self, action: #selector(dismissToMain), for: .touchUpInside)
        documentTxt.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func updateArea() {
        self.documentTxt.text = docNo
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        birthBtn.setTitle(birthDateVal, for: .normal)
        birthBtn.addTarget(self, action: #selector(openBirthDateSelector), for: .touchUpInside)
        
        validBtn.setTitle(validDateVal, for: .normal)
        validBtn.addTarget(self, action: #selector(openValidDateSelector), for: .touchUpInside)
        
        datePicker.isHidden = true
        dontBtn.isHidden =  true
    }
    
    @IBAction func doneAct(_ sender: Any) {
        dontBtn.isHidden = true
        datePicker.isHidden = true
        updateBtn.isHidden = false
    }
    
    @objc func openBirthDateSelector() {
        isBirthday = true
        openDatePicker()
    }
    
    @objc func openValidDateSelector() {
        isBirthday = false
        openDatePicker()
    }
    
    func openDatePicker() {
        dontBtn.isHidden = false
        datePicker.isHidden = false
        updateBtn.isHidden = true
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.locale = Locale(identifier: "tr")
        let strDate = dateFormatter.string(from: datePicker.date)
        if isBirthday {
            birthBtn.setTitle(strDate, for: .normal)
            self.birthDateVal = strDate
        } else {
            validBtn.setTitle(strDate, for: .normal)
            self.validDateVal = strDate
        }
    }
    
    @objc func dismissToMain() {
        self.docNo = self.documentTxt.text ?? ""
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.delegate?.updateKeys(birtdate: self.birthDateVal, docNo: self.docNo, validDate: self.validDateVal)
            }
        }
    }
}

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
