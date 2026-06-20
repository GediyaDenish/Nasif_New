//
//  ChatProfileVC.swift
//  Nasif
//
//  Created by Denish Gediya on 08/08/25.
//

import UIKit

class ChatProfileVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var imgProfile: UIImageView?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblMobileNumber: UILabel?
    @IBOutlet var vwMenu: [UIView]?
    @IBOutlet weak var lblChatTitle: UILabel!
    @IBOutlet weak var lblListingsTitle: UILabel!
    @IBOutlet weak var lblBlockTitle: UILabel!
    
    // MARK: - Variables
    var objGroupUser: GroupUser?
    var isFromPush: Bool = false
    var objChat: ChatMessage?
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension ChatProfileVC {
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickList(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let dealDetailVC = storyboard.instantiateViewController(withIdentifier: "ListShareVC") as? ListShareVC {
            self.navigationController?.pushViewController(dealDetailVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickChat(_ sender: UIButton) {
        if isFromPush == true {
            self.wsAddChat(members: [objGroupUser?.id ?? ""])
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnOnClickBlock(_ sender: UIButton) {
        if self.objChat?.isBlock ?? false {
            showDeleteConfirmation(from: self, message: "Are you sure want to unblock the member?".localized, title: "UnBlock".localized) { confirmed in
                if confirmed {
                    self.wsReportMember(strType: "unblock")
                }
            }
        } else {
            showDeleteConfirmation(from: self, message: "Are you sure want to block the member?".localized, title: "Block".localized) { confirmed in
                if confirmed {
                    self.wsReportMember(strType: "block")
                }
            }
        }
    }
}

// MARK: - UI helpers
fileprivate extension ChatProfileVC {
    func InitConfig() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.imgProfile?.layer.cornerRadius = (self.imgProfile?.frame.width ?? 0.0) / 2
        self.imgProfile?.layer.masksToBounds = true
        self.vwMenu?.forEach({
            $0.layer.cornerRadius = 10.0
            $0.layer.masksToBounds = true
        })
        if isFromPush == true {
            self.lblName?.text = objGroupUser?.displayName
            self.lblMobileNumber?.text = Utility.formattedPhoneNumber(objGroupUser?.mobile)
            if let url = URL(string: self.objGroupUser?.avatar ?? ""){
                self.imgProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
        } else {
            self.lblName?.text = (self.objChat?.oposition?.displayName?.isEmpty == false) ? self.objChat?.oposition?.displayName : Utility.formattedPhoneNumber(self.objChat?.oposition?.mobile)
            self.lblMobileNumber?.text = Utility.formattedPhoneNumber(self.objChat?.oposition?.mobile)
            if let url = URL(string: self.objChat?.oposition?.avatar ?? ""){
                self.imgProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
        }
        self.setupLocalized()
        
        if self.objChat?.isBlock ?? false {
            self.lblBlockTitle?.text = "UnBlock".localized
        } else {
            self.lblBlockTitle?.text = "Block & Report".localized
        }
    }
    
    func setupLocalized() {
        self.lblChatTitle?.text = "Chat".localized
        self.lblListingsTitle?.text = "Listings".localized
        self.lblBlockTitle?.text = "Block & Report".localized
    }
}

// MARK: - Web Service Calls
extension ChatProfileVC {
    func wsAddChat(members: [String]) {
        Utility.showLoading()
        var params: [String: Any] = [:]
        params[PARAMS.MEMBERS] = members
        let url = "\(WebService.CHATS)"
        WebServices.Post(url: url, params: params, type: ChatMessage.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            Utility.showToast(message: "Add chat successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                if let chatDetailVC = storyboard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC {
                    chatDetailVC.objChat = response
                    chatDetailVC.isFromNewPush = true
                    self.navigationController?.pushViewController(chatDetailVC, animated: true)
                }
            }
        }
    }
    
    func wsReportMember(strType: String) {
        guard let chatID = objChat?.oposition?.id else { return }
        Utility.showLoading()
        WebServices.Delete(url: "\(WebService.CHATS)\(chatID)/\(strType)/", type: ChatMessage.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            if response?.status == false {
                Utility.showToast(message: "User not found".localized)
            } else {
                Utility.showToast(message: "Report the member successfully".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}
