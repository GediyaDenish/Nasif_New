//
//  ProfileVC.swift
//  Nasif
//
//  Created by Denish Gediya on 01/07/25.
//

import UIKit
import AVFoundation

class ProfileVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwProfile: UIView?
    @IBOutlet weak var imgProfile: UIImageView?
    @IBOutlet weak var btnProfile: UIButton?
    @IBOutlet weak var vwNickName: UIView?
    @IBOutlet weak var txtName: UITextField?
    @IBOutlet weak var btnSave: UIButton?
    
    // MARK: - Variables
    var avatar:String?
    private let imagePicker = ImagePicker()
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension ProfileVC {
    @IBAction func btnOnClickProfile(_ sender: UIButton) {
        self.view.endEditing(true)
        imagePicker.pickImage(self, "", type: .single, allowVideo: false) { image, url in
            self.handleNewImage(image)
        }
    }
    
    @IBAction func btnOnClickSave(_ sender: UIButton) {
        self.view.endEditing(true)
        if checkValidation() {
            self.wsProfile()
        }
    }
}

// MARK: - UI helpers
extension ProfileVC {
    func InitConfig() {
        self.btnSave?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.txtName?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnSave?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        self.vwNickName?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 5.0, borderWidth: 1.0)
        self.vwProfile?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 75.0, borderWidth: 0.0)
        self.imgProfile?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 75.0, borderWidth: 0.0)
        //self.imagePicker.viewController = self
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.txtName?.placeholder = "NickName".localized
        self.btnSave?.setTitle("Save".localized, for: .normal)
    }
    
    func handleNewImage(_ img: UIImage) {
        self.imgProfile?.image = img
        self.avatar = convertImageToBase64String(img: img)
    }
}

// MARK: - Web Service Calls
extension ProfileVC {
    func checkValidation() -> Bool {
        if txtName?.text?.isEmpty ?? true {
            Utility.showToast(message: "Please enter name".localized)
            return false
        }
        return true
    }
    
    func wsProfile() {
        Utility.showLoading()
        var params: [String: Any] = [:]
        if let avatar = self.avatar {
            params[PARAMS.AVATAR] = avatar
        }
        if let displayName = self.txtName?.text {
            params[PARAMS.DISPLAYNAME] = displayName
        }
        Utility.addIfValid(&params, key: PARAMS.AVATAR, value: avatar)
        Utility.addIfValid(&params, key: PARAMS.DISPLAYNAME, value: self.txtName?.text)
        
        WebServices.Put(url: WebService.PROFILE, params: params, type: UserModel.self) { response in
            Utility.hideLoading()
            if let data = response {
                UserDefaultsHelper.shared.displayName = data.displayName
                Utility.showToast(message: "Profile successfully created".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let tabBarController = TabBarVC()
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let sceneDelegate = windowScene.delegate as? SceneDelegate {
                        sceneDelegate.window?.rootViewController = tabBarController
                        sceneDelegate.window?.makeKeyAndVisible()
                    }
                }
            } else {
                self.txtName?.text = ""
                Utility.hideLoading()
            }
        }
    }
}
