//
//  CreateGroupProfileVC.swift
//  Nasif
//
//  Created by Denish Gediya on 08/08/25.
//

import UIKit

class CreateGroupProfileVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwProfile: UIView?
    @IBOutlet weak var icnProfile: UIImageView?
    @IBOutlet weak var btnNext: UIButton?
    @IBOutlet weak var txtName: UITextField?
    @IBOutlet weak var vwGroupName: UIView?
    @IBOutlet weak var lblTitle: UILabel?
    
    // MARK: - Variables
    private let imagePicker = ImagePicker()
    var dictParam: [String: Any] = [:]
    var avatar:String?
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension CreateGroupProfileVC {
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickNext(_ sender: UIButton) {
        if txtName?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            Utility.showToast(message: "Please enter group name".localized)
            return
        } else {
            dictParam[PARAMS.GROUP_NAME] = self.txtName?.text ?? ""
            if let avatar = self.avatar {
                dictParam[PARAMS.GROUP_IMAGE] = avatar
            }
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            if let createNewGroupVC = storyboard.instantiateViewController(withIdentifier: "CreateNewGroupVC") as? CreateNewGroupVC {
                createNewGroupVC.dictParam = self.dictParam
                createNewGroupVC.isFromUpdate = false
                createNewGroupVC.profileImage = self.icnProfile?.image
                self.navigationController?.pushViewController(createNewGroupVC, animated: true)
            }
        }
    }
    
    @IBAction func btnOnClickProfile(_ sender: UIButton) {
        self.view.endEditing(true)
        imagePicker.pickImage(self, "", type: .single, allowVideo: false) { image, url in
            self.handleNewImage(image)
        }
    }
}

// MARK: - UI helpers
extension CreateGroupProfileVC {
    func InitConfig() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.btnNext?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.txtName?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.txtName?.placeholder = "Group Name".localized
        self.btnNext?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        self.vwGroupName?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 10.0, borderWidth: 1.0)
        self.vwProfile?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 75.0, borderWidth: 0.0)
        self.icnProfile?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 75.0, borderWidth: 0.0)
        self.lblTitle?.text = "Create New Group".localized
        self.btnNext?.setTitle("Next".localized, for: .normal)
    }
    
    func handleNewImage(_ img: UIImage) {
        self.icnProfile?.image = img
        self.avatar = convertImageToBase64String(img: img)
    }
}
