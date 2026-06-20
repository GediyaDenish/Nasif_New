//
//  SettingVC.swift
//  Nasif
//
//  Created by Denish Gediya on 01/07/25.
//

import UIKit
import FirebaseMessaging

class SettingVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet var vwMenu: [UIView]?
    @IBOutlet weak var vwTopMenu: UIView?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblMobileNumber: UILabel?
    @IBOutlet weak var imgProfile: UIImageView?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblPoliciesTitle: UILabel!
    @IBOutlet weak var lblReportsTitle: UILabel!
    @IBOutlet weak var lblContactTitle: UILabel!
    @IBOutlet weak var lblAboutTitle: UILabel!
    @IBOutlet weak var lblFalLicenseTitle: UILabel!
    @IBOutlet weak var lblLogoutTitle: UILabel!
    @IBOutlet weak var lblDeleteTitle: UILabel!
    
    
    // MARK: - Variables
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
    
    @IBAction func btnOnClickProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.isFromProfile = false
            vc.delegateData = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnOnClickMenu(_ sender: UIButton) {
        if sender.tag == 0 {
            if let url = URL(string: "https://nasif.com.sa/FAQ") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if sender.tag == 1 {
            if let url = URL(string: "https://nasif.com.sa/Policy") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if sender.tag == 2 {
            if let url = URL(string: "https://nasif.com.sa/Policy") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if sender.tag == 3 {
            if let url = URL(string: "https://forms.gle/VmNdmbWx1Ktwf6YS6") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if sender.tag == 4 {
            if let url = URL(string: "https://Nasif.com.sa/about") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if sender.tag == 5 {
            if let url = URL(string: "https://Nasif.com.sa/about") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}

//MARK: - IBAction Methods
extension SettingVC {
    @IBAction func btnOnClickLogout(_ sender: UIButton) {
        logout(from: self, message: "Are you sure want to logout the account?".localized) { confirmed in
            if confirmed {
                Utility.signOut()
            }
        }
    }
    
    @IBAction func btnOnClickDelete(_ sender: UIButton) {
        showDeleteConfirmation(from: self, message: "Are you sure want to delete the account?".localized, title: "Delete".localized) { confirmed in
            if confirmed {
                self.wsDeleteAccount()
            }
        }
    }
}

// MARK: - UI helpers
fileprivate extension SettingVC {
    func InitConfig() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.vwMenu?.forEach({
            $0.layer.cornerRadius = 10.0
            $0.layer.masksToBounds = true
        })
        self.vwTopMenu?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 10.0, borderWidth: 1.0)
        self.imgProfile?.setRound(withBorderColor: .clear, andCornerRadious: 25.0, borderWidth: 0.0)
        self.getProfile()
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle.text = "Profile".localized
        self.lblInfo.text = "info and frequently asked questions".localized
        self.lblPoliciesTitle.text = "Policies and Terms".localized
        self.lblReportsTitle.text = "Reports and Complaints".localized
        self.lblContactTitle.text = "contact us".localized
        self.lblAboutTitle.text = "About Nasif".localized
        self.lblFalLicenseTitle.text = "Fal license".localized
        self.lblLogoutTitle.text = "Log Out".localized
        self.lblDeleteTitle.text = "Delete Account".localized
    }
}

// MARK: - Web Service Calls
extension SettingVC {
    func getProfile() {
        WebServices.Get(url: WebService.PROFILE, type: UserModel.self) { [weak self] (response: UserModel?) in
            guard let self = self else { return }
            guard let response = response else { return }
            let topic = response.id.replacingOccurrences(of: "-", with: "")
            UserDefaultsHelper.shared.topic = topic
            Messaging.messaging().subscribe(toTopic: topic)
            self.lblName?.text = response.displayName
            self.lblMobileNumber?.text = Utility.formattedPhoneNumber(response.mobile)
            UserDefaultsHelper.shared.displayName = response.displayName
            if let url = URL(string: response.avatar){
                self.imgProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
        }
    }
    
    func wsDeleteAccount() {
        Utility.showLoading()
        WebServices.Delete(url: WebService.DELETE_ACCOUNT, type: AuthModel.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else { return }
            guard response != nil else { return }
            Utility.showToast(message: "Delete account successfully".localized)
            if let topic = UserDefaultsHelper.shared.topic as? String{
                WebService.firebaseMessaging?.unsubscribe(fromTopic: topic)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC, let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
                    UserDefaultsHelper.shared.removeToken()
                    UserDefaultsHelper.removeUserFromDefaults()
                    sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: vc)
                }
            }
        }
    }
}

extension SettingVC: delegateDataUpdate {
    func updateData() {
        self.getProfile()
    }
}
