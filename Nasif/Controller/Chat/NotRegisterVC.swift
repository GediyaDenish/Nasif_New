//
//  NotRegisterVC.swift
//  Nasif
//
//  Created by Denish Gediya on 20/11/25.
//

import UIKit
import CountryPickerView

protocol NotRegisterDelegate: AnyObject {
    func addChat(mobile: String)
}

class NotRegisterVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwPhone: UIView?
    @IBOutlet weak var imgCountry: UIImageView?
    @IBOutlet weak var btnCountry: UIButton?
    @IBOutlet weak var txtPhone: UITextField?
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClick: UIButton!
    @IBOutlet weak var vwMain: UIView!
    
    // MARK: - Variables
    let countryPickerView = CountryPickerView()
    var countryCode:String?
    weak var delegate: NotRegisterDelegate?
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension NotRegisterVC {
    @IBAction func btnOnClickDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnOnClickCountry(_ sender: UIButton) {
        self.countryPicker()
    }
    
    @IBAction func btnOnClick(_ sender: UIButton) {
        self.view.endEditing(true)
        if checkValidation() {
            self.dismiss(animated: true) {
                self.delegate?.addChat(mobile: self.txtPhone?.text ?? "")
            }
        }
    }
    
    func checkValidation() -> Bool {
        let validPhoneNumber = txtPhone?.text!.isValidMobileNumber()
        if !validPhoneNumber!.0 {
            Utility.showToast(message: validPhoneNumber!.1)
            return false
        }
        return true
    }
}

// MARK: - UI helpers
extension NotRegisterVC {
    func InitConfig() {
        countryPickerView.delegate = self
        self.vwPhone?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 5.0, borderWidth: 1.0)
        self.btnClick?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnClick?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        self.vwMain?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0.0)
        self.setupLocalized()
        let defaultCountry = countryPickerView.getCountryByCode("SA") // e.g., India
        self.btnCountry?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnCountry?.setTitle(defaultCountry?.phoneCode, for: .normal)
        let cleaned = defaultCountry?.phoneCode.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        self.countryCode = cleaned ?? ""
        self.imgCountry?.image = defaultCountry?.flag
        self.txtPhone?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.txtPhone?.textAlignment = .left
        self.txtPhone?.semanticContentAttribute = .forceLeftToRight
        self.txtPhone?.delegate = self
        self.txtPhone?.keyboardType = .numberPad
    }
    
    func setupLocalized() {
        self.btnClick?.setTitle("تأكيد", for: .normal)
    }
    
    func countryPicker(){
        countryPickerView.showCountriesList(from: self)
    }
}

extension NotRegisterVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        let cleaned = country.phoneCode.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        self.countryCode = cleaned
        self.btnCountry?.setTitle(country.phoneCode, for: .normal)
        self.imgCountry?.image = country.flag
    }
}

extension NotRegisterVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Only for phone textfield
        guard textField == txtPhone else { return true }
        
        // Current text
        let currentText = textField.text ?? ""
        
        // New text after change
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // ✅ Allow only numbers
        let allowedCharacterSet = CharacterSet.decimalDigits
        if string.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
            return false
        }
        
        // ✅ Allow max 9 digits
        return updatedText.count <= 10
    }
}
