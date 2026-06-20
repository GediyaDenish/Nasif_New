//
//  EditProfileVC.swift
//  Nasif
//
//  Created by Denish Gediya on 17/11/25.
//

import UIKit
import FirebaseMessaging

protocol delegateDataUpdate {
    func updateData()
}

class EditProfileVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var vwImag: UIView!
    @IBOutlet weak var vwAddName: UIView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    
    // MARK: - Variables
    var avatar:String?
    private let imagePicker = ImagePicker()
    var delegateData: delegateDataUpdate?
    var isFromProfile: Bool = false
    var objChat: ChatMessage?
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension EditProfileVC {
    @IBAction func btnOnClickDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnOnClickUpdate(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isFromProfile == true {
            if checkValidation() {
                self.wsUpdateGroupChat()
            }
        } else {
            if checkValidation() {
                self.wsProfile()
            }
        }
    }
    
    @IBAction func btnOnClickAdd(_ sender: UIButton) {
        self.view.endEditing(true)
        imagePicker.pickImage(self, "", type: .single, allowVideo: false) { image, url in
            self.handleNewImage(image)
        }
    }
}

// MARK: - UI helpers
extension EditProfileVC {
    func InitConfig() {
        self.btnUpdate?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.txtName?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnUpdate?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        self.vwAddName?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 10.0, borderWidth: 1.0)
        self.vwMain?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0.0)
        self.vwImag?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 75.0, borderWidth: 0.0)
        self.imgProfile?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 75.0, borderWidth: 0.0)
        if self.isFromProfile == true {
            if let url = URL(string: self.objChat?.groupImage ?? ""){
                self.imgProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
            self.txtName?.text = self.objChat?.groupName
            self.txtName?.placeholder = "Group name".localized
        } else {
            self.setupLocalized()
            self.getProfile()
        }
        
    }
    
    func setupLocalized() {
        self.txtName?.placeholder = "NickName".localized
        self.btnUpdate?.setTitle("تعديل", for: .normal)
    }
    
    func handleNewImage(_ img: UIImage) {
        self.imgProfile?.image = img
        self.avatar = convertImageToBase64String(img: img)
    }
}

// MARK: - Web Service Calls
extension EditProfileVC {
    func checkValidation() -> Bool {
        if self.isFromProfile == true {
            if txtName?.text?.isEmpty ?? true {
                Utility.showToast(message: "Please enter group name".localized)
                return false
            }
        } else {
            if txtName?.text?.isEmpty ?? true {
                Utility.showToast(message: "Please enter name".localized)
                return false
            }
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
                Utility.showToast(message: "Profile successfully update".localized)
                self.delegateData?.updateData()
                self.dismiss(animated: true)
            } else {
                Utility.hideLoading()
            }
        }
    }
    
    func getProfile() {
        WebServices.Get(url: WebService.PROFILE, type: UserModel.self) { [weak self] (response: UserModel?) in
            guard let self = self else { return }
            guard let response = response else { return }
            let topic = response.id.replacingOccurrences(of: "-", with: "")
            UserDefaultsHelper.shared.topic = topic
            Messaging.messaging().subscribe(toTopic: topic)
            self.txtName?.text = response.displayName
            UserDefaultsHelper.shared.displayName = response.displayName
            if let url = URL(string: response.avatar){
                self.imgProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
        }
    }
    
    func wsUpdateGroupChat() {
        Utility.showLoading()
        var dictParam: [String: Any] = [:]
        if let avatar = self.avatar {
            dictParam[PARAMS.GROUP_IMAGE] = avatar
        }
        if let name = self.txtName?.text {
            dictParam[PARAMS.GROUP_NAME] = name
        }
        WebServices.Put(url: "\(WebService.CHATS)\(self.objChat?.id ?? "")/", params: dictParam, type: ChatMessage.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            Utility.showToast(message: "Group update successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.delegateData?.updateData()
                self.dismiss(animated: true)
            }
        }
    }
    
}
