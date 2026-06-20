//
//  OTPVC.swift
//  Nasif
//
//  Created by Denish Gediya on 01/07/25.
//

import UIKit
import FirebaseMessaging

class OTPVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var txtSmsOtp: VPMOTPView?
    @IBOutlet weak var btnContinue: UIButton?
    @IBOutlet weak var lblResendOTP: UILabel?
    @IBOutlet weak var lblResendTime: UILabel?
    @IBOutlet weak var btnBack: UIButton?
    
    // MARK: - Variables
    var strEnteredSmsOtp: String = ""
    var strPhone: String?
    var timer: Timer?
    var remainingTime = 60
    var isDoneOTP: Bool = false
    var countryCode: String?
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    func startOneMinuteCountdown() {
        remainingTime = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.remainingTime -= 1
            self.lblResendTime?.text = ("1 : \(self.remainingTime)")
            if self.remainingTime <= 0 {
                timer.invalidate()
                self.lblResendTime?.text = "1 : 00"
                // Add code to execute after 1 minute
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
}

//MARK: - IBAction Mthonthd
extension OTPVC {
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickContinue(_ sender: UIButton) {
        self.view.endEditing(true)
        let expectedOTPLength = 4 // or 6 if you're using 6-digit OTP
        if isDoneOTP == false {
            txtSmsOtp?.otpFieldErrorBorderColor = UIColor.themeErrorTextColor
            Utility.showToast(message: "Please enter all 4 OTP digits.".localized)
            return
        } else {
            // Guard against incomplete OTP
            guard strEnteredSmsOtp.count == expectedOTPLength else {
                Utility.showToast(message: "Please enter all 4 OTP digits.".localized)
                return
            }
            
            // Check if OTP matches
            if !strEnteredSmsOtp.isEmpty {
                self.wsVerify(otp: strEnteredSmsOtp)
            } else {
                Utility.showToast(message: "Please enter a valid OTP.".localized)
            }
            
        }
    }
    
    @IBAction func btnOnClickResend(_ sender: UIButton) {
        self.wsSendOTP()
    }
}

// MARK: - UI helpers
extension OTPVC {
    func InitConfig() {
        self.lblTitle?.font = FontHelper.font(size: 24.0, type: FontType.Regular)
        self.btnContinue?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.lblResendOTP?.font = FontHelper.font(size: 14.0, type: FontType.Regular)
        self.lblResendTime?.font = FontHelper.font(size: 14.0, type: FontType.Regular)
        setupOtpView(otpView: txtSmsOtp!)
        self.btnContinue?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        self.startOneMinuteCountdown()
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle?.text = "OTP".localized
        self.lblResendOTP?.text = "Resend OTP".localized
        self.btnContinue?.setTitle("Continue".localized, for: .normal)
    }
    
    func setupOtpView(otpView: VPMOTPView) {
        otpView.otpFieldsCount = 4
        otpView.otpFieldDefaultBorderColor = UIColor.themeColorD9D9D9
        otpView.otpFieldEnteredBorderColor = UIColor.black
        otpView.otpFieldErrorBorderColor = UIColor.themeErrorTextColor
        otpView.otpFieldSize = 40
        otpView.otpFieldBorderWidth = 1
        otpView.shouldAllowIntermediateEditing = true
        otpView.otpFieldSeparatorSpace = 16
        otpView.delegate = self
        otpView.initializeUI()
    }
}

// MARK: - Web Service Calls
extension OTPVC {
    
    func wsVerify(otp: String) {
        Utility.showLoading()
        var dictParam: [String: Any] = [:]
        dictParam[PARAMS.MOBILE] = self.strPhone
        dictParam[PARAMS.CODE] = self.countryCode
        dictParam[PARAMS.OTP] = otp
        WebServices.Post(url: WebService.AUTH_VERIFY, params: dictParam, type: SignupResponse.self) { response in
            Utility.hideLoading()
            if let data = response{
                self.strEnteredSmsOtp = ""
                UserDefaultsHelper.shared.token = data.accessToken
                Utility.showToast(message: "Account successfully verify".localized)
                self.getProfile()
                let user = data
                UserDefaultsHelper.saveUserToDefaults(user)
                let _ = SocketService.init()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.timer?.invalidate()
                    self.timer = nil
                    if user.isNew {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                            self.navigationController?.pushViewController(profileVC, animated: true)
                        }
                    } else {
                        let tabBarController = TabBarVC()
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let sceneDelegate = windowScene.delegate as? SceneDelegate {
                            sceneDelegate.window?.rootViewController = tabBarController
                            sceneDelegate.window?.makeKeyAndVisible()
                        }
                    }
                }
            }else{
                self.strEnteredSmsOtp = ""
                Utility.hideLoading()
            }
        }
    }
    
    func getProfile() {
        WebServices.Get(url: WebService.PROFILE, type: UserModel.self) { [weak self] (response: UserModel?) in
            guard let self = self else { return }
            guard let response = response else { return }
            let _ = SocketService.init()
            let topic = response.id.replacingOccurrences(of: "-", with: "")
            UserDefaultsHelper.shared.topic = topic
            Messaging.messaging().subscribe(toTopic: topic)
        }
    }
    
    func wsSendOTP() {
        Utility.showLoading()
        var params: [String: Any] = [:]
        if let phone = strPhone {
            params[PARAMS.MOBILE] = phone
        }
        if let code = countryCode {
            params[PARAMS.CODE] = code
        }
        WebServices.Post(url: WebService.SIGNIN, params: params, type: AuthModel.self) { response in
            Utility.hideLoading()
            if let data = response {
                Utility.showToast(message: data.message.localized)
                self.startOneMinuteCountdown()
            } else {
                Utility.hideLoading()
            }
        }
    }
}

// MARK: - VPMOTPViewDelegate
extension OTPVC: VPMOTPViewDelegate, UITextFieldDelegate {
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numeric input
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Reset border when editing starts
        self.txtSmsOtp?.initializeUI()
    }
    
    func enteredOTP(otpString: String, view: VPMOTPView) {
        strEnteredSmsOtp = otpString
        print("Entered OTP: \(otpString)".localized)
    }
    
    func hasEnteredAllOTP(hasEntered: Bool, view: VPMOTPView) -> Bool {
        print("Has entered all OTP? \(hasEntered)".localized)
        isDoneOTP = hasEntered
        let expectedOTPLength = 4
        
        // Guard against incomplete OTP
        guard hasEntered, strEnteredSmsOtp.count == expectedOTPLength else {
            Utility.showToast(message: "Please enter all \(expectedOTPLength) OTP digits.".localized)
            return false
        }
        
        // If guard passes, return true (or your OTP verification logic)
        return true
    }
}
