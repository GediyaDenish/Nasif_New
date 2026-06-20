//
//  SignVC.swift
//  Nasif
//
//  Created by Denish Gediya on 04/07/25.
//

import UIKit
import CountryPickerView

class SignVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwPhone: UIView?
    @IBOutlet weak var imgCountry: UIImageView?
    @IBOutlet weak var btnCountry: UIButton?
    @IBOutlet weak var txtPhone: UITextField?
    @IBOutlet weak var btnSignUP: UIButton?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblLoginTitle: UILabel!
    @IBOutlet weak var btnSignin: UIButton!
    @IBOutlet weak var btnChek: UIButton?
    @IBOutlet weak var lblAccept: UILabel?
    
    // MARK: - Variables
    let countryPickerView = CountryPickerView()
    var countryCode: String?
    var params:[String:String] = ["code":"","mobile":""]
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
    
    @IBAction func btnOnClickCheck(_ sender: UIButton) {
        if btnChek?.isSelected == true {
            btnChek?.isSelected = false
        } else {
            btnChek?.isSelected = true
        }
    }
    
    @IBAction func btnOnClickTerms(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TermsVC") as? TermsVC {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
}

//MARK: - IBAction Mthonthd
extension SignVC {
    @IBAction func btnOnClickCountry(_ sender: UIButton) {
        self.countryPicker()
    }
    
    @IBAction func btnOnClickSignUP(_ sender: UIButton) {
        self.view.endEditing(true)
        if checkValidation() {
            self.wsSignUP()
        }
    }
    
    @IBAction func btnOnClickLogin(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI helpers
fileprivate extension SignVC {
    func InitConfig() {
        countryPickerView.delegate = self
        self.lblTitle?.font = FontHelper.font(size: 24.0, type: FontType.Regular)
        self.btnSignUP?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnCountry?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.txtPhone?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.vwPhone?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 5.0, borderWidth: 1.0)
        self.btnSignUP?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        let defaultCountry = countryPickerView.getCountryByCode("SA") // e.g., India
        self.btnCountry?.setTitle(defaultCountry?.phoneCode, for: .normal)
        let cleaned = defaultCountry?.phoneCode.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        self.countryCode = cleaned ?? ""
        self.imgCountry?.image = defaultCountry?.flag
        
        self.txtPhone?.delegate = self
        self.txtPhone?.keyboardType = .numberPad
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle?.text = "Phone Number".localized
        self.lblAccept?.text = "Accept Terms & Conditions".localized
        self.lblLoginTitle?.text = "Don't have an account?".localized
        self.btnSignin?.setTitle("Login".localized, for: .normal)
        self.btnSignUP?.setTitle("Sign In".localized, for: .normal)
    }
    
    func countryPicker(){
        countryPickerView.showCountriesList(from: self)
    }
}

extension SignVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.btnCountry?.setTitle(country.phoneCode, for: .normal)
        let cleaned = country.phoneCode.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        self.countryCode = cleaned
        self.imgCountry?.image = country.flag
    }
}

// MARK: - Web Service Calls
extension SignVC {
    func checkValidation() -> Bool {
        let validPhoneNumber = txtPhone?.text!.isValidMobileNumber()
        if !validPhoneNumber!.0 {
            Utility.showToast(message: validPhoneNumber!.1)
            return false
        } else if self.btnChek?.isSelected == false {
            Utility.showToast(message: "Please select the terms and conditions".localized)
            return false
        }
        return true
    }
    
    func wsSignUP() {
        Utility.showLoading()
        var params: [String: Any] = [:]
        if let phone = self.txtPhone?.text?.trim() {
            params[PARAMS.MOBILE] = phone
        }
        if let code = countryCode {
            params[PARAMS.CODE] = code
        }
        
        WebServices.Post(url: WebService.SIGNUP, params: params, type: AuthModel.self) { response in
            Utility.hideLoading()
            if let data = response {
                Utility.showToast(message: data.message.localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if data.status == true {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let otpVC = storyboard.instantiateViewController(withIdentifier: "OTPVC") as? OTPVC {
                            otpVC.countryCode = self.countryCode
                            otpVC.strPhone = self.txtPhone?.text?.trim() ?? ""
                            self.navigationController?.pushViewController(otpVC, animated: true)
                        }
                    } else {
                        self.txtPhone?.text = ""
                        self.btnChek?.isSelected = false
                        return
                    }
                }
            } else {
                self.txtPhone?.text = ""
                self.btnChek?.isSelected = false
                Utility.hideLoading()
            }
        }
    }
}

extension SignVC: UITextFieldDelegate {
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
