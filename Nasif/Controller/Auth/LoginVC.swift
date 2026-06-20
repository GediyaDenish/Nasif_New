//
//  LoginVC.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit
import CountryPickerView
import FirebaseMessaging

class LoginVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwPhone: UIView?
    @IBOutlet weak var imgCountry: UIImageView?
    @IBOutlet weak var btnCountry: UIButton?
    @IBOutlet weak var txtPhone: UITextField?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblLoginTitle: UILabel?
    @IBOutlet weak var lblAccept: UILabel?
    @IBOutlet weak var btnCheck: UIButton?
    @IBOutlet weak var btnSignup: UIButton?
    @IBOutlet weak var btnLogin: UIButton?
    
    // MARK: - Variables
    let countryPickerView = CountryPickerView()
    var countryCode:String?
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
    
    @IBAction func btnOnClickCheck(_ sender: UIButton) {
        if btnCheck?.isSelected == true {
            btnCheck?.isSelected = false
        }else{
            btnCheck?.isSelected = true
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
extension LoginVC {
    @IBAction func btnOnClickCountry(_ sender: UIButton) {
        self.countryPicker()
    }
    
    @IBAction func btnOnClickSignUP(_ sender: UIButton) {
        self.view.endEditing(true)
        if checkValidation() {
            self.wsSignIn()
        }
    }
    
    @IBAction func btnOnClickSignup(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signVC = storyboard.instantiateViewController(withIdentifier: "SignVC") as? SignVC {
            self.navigationController?.pushViewController(signVC, animated: true)
        }
    }
}

// MARK: - UI helpers
fileprivate extension LoginVC {
    func InitConfig() {
        countryPickerView.delegate = self
        self.lblTitle?.font = FontHelper.font(size: 24.0, type: FontType.Regular)
        self.btnLogin?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnCountry?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.txtPhone?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.txtPhone?.textAlignment = .left
        self.txtPhone?.semanticContentAttribute = .forceLeftToRight
        self.vwPhone?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 5.0, borderWidth: 1.0)
        self.btnLogin?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
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
        self.btnLogin?.setTitle("Login".localized, for: .normal)
        self.btnSignup?.setTitle("Sign Up".localized, for: .normal)
    }
    
    func countryPicker(){
        countryPickerView.showCountriesList(from: self)
    }
}

extension LoginVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        let cleaned = country.phoneCode.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        self.countryCode = cleaned
        self.btnCountry?.setTitle(country.phoneCode, for: .normal)
        self.imgCountry?.image = country.flag
    }
}

// MARK: - Web Service Calls
extension LoginVC {
    func checkValidation() -> Bool {
        let validPhoneNumber = txtPhone?.text!.isValidMobileNumber()
        if !validPhoneNumber!.0 {
            Utility.showToast(message: validPhoneNumber!.1)
            return false
        } else if self.btnCheck?.isSelected == false {
            Utility.showToast(message: "Please select the terms and conditions".localized)
            return false
        }
        return true
    }
    
    func wsSignIn() {
        Utility.showLoading()
        var params: [String: Any] = [:]
        if let phone = self.txtPhone?.text?.trim() {
            params[PARAMS.MOBILE] = phone
        }
        if let code = countryCode {
            params[PARAMS.CODE] = code
        }
        WebServices.Post(url: WebService.SIGNIN, params: params, type: AuthModel.self) { response in
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
                        self.btnCheck?.isSelected = false
                        return
                    }
                }
            } else {
                self.txtPhone?.text = ""
                self.btnCheck?.isSelected = false
                Utility.hideLoading()
            }
        }
    }
}

extension LoginVC: UITextFieldDelegate {
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
