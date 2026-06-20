//
//  CreateNewGroupVC.swift
//  Nasif
//
//  Created by Denish Gediya on 11/08/25.
//

import UIKit

class CreateNewGroupVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var stackAdminStep: UIStackView!
    @IBOutlet weak var btnCreate: UIButton?
    @IBOutlet weak var imgProfile: UIImageView?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var vwList: UIView?
    @IBOutlet weak var subView: UIView?
    @IBOutlet weak var lblUserStatus: UILabel?
    @IBOutlet weak var imgUserProfile: UIImageView?
    @IBOutlet weak var lblUserName: UILabel?
    @IBOutlet weak var vwSub: UIView?
    @IBOutlet var vwSubProfile: [UIView]?
    
    @IBOutlet weak var vwGroupDesc: UIView!
    @IBOutlet weak var vwRemoveGroup: UIView!
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblAddAdminTitle: UILabel?
    @IBOutlet weak var lblAddModeratorTitle: UILabel?
    @IBOutlet weak var lblAddMemberTitle: UILabel?
    @IBOutlet weak var lblCreateInviteTitle: UILabel?
    @IBOutlet weak var lblListingsTitle: UILabel?
    @IBOutlet weak var lblLeaveGroupTitle: UILabel?
    @IBOutlet weak var lblDeleteGroup: UILabel?
    @IBOutlet weak var lblProfileTitle: UILabel?
    @IBOutlet weak var lblChangeTitle: UILabel?
    @IBOutlet weak var lblRemoveTitle: UILabel?
    
    @IBOutlet weak var stackBottom: UIStackView?
    @IBOutlet weak var tblAdmin: ContentSizedTableView?
    @IBOutlet weak var heightAdmin: NSLayoutConstraint?
    @IBOutlet weak var tblModeratore: ContentSizedTableView?
    @IBOutlet weak var heightModeratore: NSLayoutConstraint?
    @IBOutlet weak var tblMember: ContentSizedTableView?
    @IBOutlet weak var heightMember: NSLayoutConstraint?
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var vwLeave: UIView?
    @IBOutlet weak var vwDeleteGroup: UIView?
    
    @IBOutlet weak var vwAdmin: UIView?
    @IBOutlet weak var vwModerator: UIView?
    @IBOutlet weak var vwMember: UIView?
    @IBOutlet weak var vwCreateLink: UIView?
    
    @IBOutlet weak var vwChangePermisson: UIView?
    @IBOutlet weak var btnProfileImage: UIButton?
    @IBOutlet weak var btnName: UIButton?
    @IBOutlet weak var vwProfileMenu: UIView?
    
    @IBOutlet weak var lblTotalGroupMember: UILabel!
    @IBOutlet weak var vwDescription: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var vw1: UIView!
    @IBOutlet weak var vw2: UIView!
    @IBOutlet weak var vw3: UIView!
    @IBOutlet weak var vw4: UIView!
    
    // MARK: - Variables
    var dictParam: [String: Any] = [:]
    var isFromUpdate: Bool = false
    var arrAdmin: [GroupUser] = []
    var arrModeratore: [GroupUser] = []
    var arrMember: [GroupUser] = []
    var objChat: ChatMessage?
    var profileImage : UIImage?
    var objGroupUser: GroupUser?
    private let imagePicker = ImagePicker()
    var avatar:String?
    var strCurrentType: String = ""
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.subView?.isHidden = true
    }
    
    @IBAction func btnOnClickMember(_ sender: UIButton) {
        wsGroupChat(currentType: self.strCurrentType, userId: self.objGroupUser?.id ?? "", newType: "member")
    }
    
    @IBAction func btnOnClickModeratorMenu(_ sender: Any) {
        wsGroupChat(currentType: self.strCurrentType, userId: self.objGroupUser?.id ?? "", newType: "moderator")
    }
    
    @IBAction func btnOnClickAdmin(_ sender: UIButton) {
        wsGroupChat(currentType: self.strCurrentType, userId: self.objGroupUser?.id ?? "", newType: "admin")
    }
    
}

//MARK: - IBAction Mthonthd
extension CreateNewGroupVC {
    
    func openWhatsAppInvite(to mobile: String, message: String) {
        
        // Clean phone number (digits only)
        let digits = mobile.replacingOccurrences(of: "\\D",
                                                 with: "",
                                                 options: .regularExpression)
        
        guard !digits.isEmpty else {
            Utility.showToast(message: "Invalid phone number")
            return
        }
        
        // Percent encode message
        let allowed = CharacterSet.urlQueryAllowed
        guard let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: allowed) else {
            Utility.showToast(message: "Encoding error")
            return
        }
        
        // Direct chat open
        let fullURL = "whatsapp://send?phone=\(digits)&text=\(encodedMessage)"
        
        if let url = URL(string: fullURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            Utility.showToast(message: "WhatsApp not installed".localized)
        }
    }
    
    @IBAction func btnOnClickInvite(_ sender: UIButton) {
        let groupId = objChat?.id ?? ""
       // let inviteLink = "\(WebService.APIConfig.BASE_URL)/join?groupId=\(groupId)"
        let inviteLink = "https://nasif.com.sa?groupId=\(groupId)"
        let activityVC = UIActivityViewController(
            activityItems: [inviteLink], applicationActivities: nil)
        
        if let pop = activityVC.popoverPresentationController {
            pop.sourceView = sender
        }
        
        self.present(activityVC, animated: true)
    }
    
    @IBAction func btnOnClickImage(_ sender: UIButton) {
        //        imagePicker.pickImage(self, "".localized, type: .single, allowVideo: false) { image, url in
        //            self.handleNewImage(image)
        //        }
    }
    
    @IBAction func btnOnClickName(_ sender: UIButton) {
        // showAlert()
    }
    
    @IBAction func btnOnClickCreate(_ sender: UIButton) {
        let arrTotalCount = self.arrAdmin.count + self.arrMember.count + self.arrModeratore.count
        if arrTotalCount >= 1 {
            if self.isFromUpdate == false {
                self.wsAddGroupChat()
            } else {
                if self.objChat?.isAdmin == true {
                    self.wsUpdateGroupChat()
                } else {
                    Utility.showToast(message: "You are not admin of this group".localized)
                    return
                }
            }
            
        } else {
            Utility.showToast(message: "Please add member or moderator".localized)
        }
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickClose(_ sender: UIButton) {
        self.subView?.isHidden = true
    }
    
    @IBAction func btnOnClickAddAdmin(_ sender: UIButton) {
        if self.objChat?.isAdmin == false {
            Utility.showToast(message: "You are not admin of this group".localized)
            return
        } else {
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            if let adminChatVC = storyboard.instantiateViewController(withIdentifier: "AdminChatVC") as? AdminChatVC {
                adminChatVC.objStatus = .Admin
                adminChatVC.onDismissContacts = { [weak self] admin in
                    guard let self else { return }
                    //   self.arrAdmin.removeAll()
                    for contact in admin {
                        // Create GroupUser from UserContact
                        let newGroupUser = GroupUser(
                            id: contact.id, mobile: contact.mobile, avatar: contact.avatar, displayName: contact.name
                        )
                        
                        if let index = self.arrAdmin.firstIndex(where: { $0.id == contact.id }) {
                            // Update existing
                            self.arrAdmin[index] = newGroupUser
                        } else {
                            // Append new
                            self.arrAdmin.append(newGroupUser)
                        }
                    }
                    self.vwGroupDesc.isHidden = false
                    self.tblAdmin?.reloadData()
                }
                self.navigationController?.present(adminChatVC, animated: true)
            }
        }
        
    }
    
    @IBAction func btnOnClickModerator(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let adminChatVC = storyboard.instantiateViewController(withIdentifier: "AdminChatVC") as? AdminChatVC {
            adminChatVC.objStatus = .Moderator
            adminChatVC.onDismissContacts = { [weak self] moderator in
                guard let self else { return }
                // self.arrModeratore.removeAll()
                for contact in moderator {
                    // Create GroupUser from UserContact
                    let newGroupUser = GroupUser(
                        id: contact.id, mobile: contact.mobile, avatar: contact.avatar, displayName: contact.name
                    )
                    
                    if let index = self.arrModeratore.firstIndex(where: { $0.id == contact.id }) {
                        // Update existing
                        self.arrModeratore[index] = newGroupUser
                    } else {
                        // Append new
                        self.arrModeratore.append(newGroupUser)
                    }
                }
                self.vwGroupDesc.isHidden = false
                self.tblModeratore?.reloadData()
            }
            self.navigationController?.present(adminChatVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickMembers(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let adminChatVC = storyboard.instantiateViewController(withIdentifier: "AdminChatVC") as? AdminChatVC {
            adminChatVC.objStatus = .Member
            adminChatVC.onDismissContacts = { [weak self] member in
                guard let self else { return }
                //self.arrMember.removeAll()
                for contact in member {
                    // Create GroupUser from UserContact
                    let newGroupUser = GroupUser(
                        id: contact.id, mobile: contact.mobile, avatar: contact.avatar, displayName: contact.name
                    )
                    
                    if let index = self.arrMember.firstIndex(where: { $0.id == contact.id }) {
                        // Update existing
                        self.arrMember[index] = newGroupUser
                    } else {
                        // Append new
                        self.arrMember.append(newGroupUser)
                    }
                }
                self.vwGroupDesc.isHidden = false
                self.tblMember?.reloadData()
            }
            self.navigationController?.present(adminChatVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let chatProfileVC = storyboard.instantiateViewController(withIdentifier: "ChatProfileVC") as? ChatProfileVC {
            chatProfileVC.objGroupUser = self.objGroupUser
            chatProfileVC.objChat = self.objChat
            chatProfileVC.isFromPush = true
            self.navigationController?.pushViewController(chatProfileVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickList(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Deal", bundle: nil)
        if let dealListVC = storyboard.instantiateViewController(withIdentifier: "DealListVC") as? DealListVC {
            dealListVC.objPushType = .Profile
            self.navigationController?.pushViewController(dealListVC, animated: true)
        }
    }
    
    
    @IBAction func btnOnClickLeaveGroup(_ sender: Any) {
        showDeleteConfirmation(from: self, message: "Are you sure want to leave the group?".localized, title: "Leave".localized) { confirmed in
            if confirmed {
                self.wsLeaveGroup()
            }
        }
    }
    
    @IBAction func btnOnClickDeleteGroup(_ sender: UIButton) {
        showDeleteConfirmation(from: self, message: "Are you sure want to delete the group?".localized, title: "Delete".localized) { confirmed in
            if confirmed {
                self.wsDeleteGroup()
            }
        }
    }
    
    @IBAction func btnOnClickEdit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegateData = self
            vc.objChat = self.objChat
            vc.isFromProfile = true
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnOnClickDescription(_ sender: UIButton) {
        if objChat?.isMember == true {
            Utility.showToast(message: "You don't have permission to change in group".localized)
            return
        } else if objChat?.isModerator == true {
            Utility.showToast(message: "You don't have permission to change in group".localized)
            return
        } else {
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "EditDescriptionVC") as? EditDescriptionVC {
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                vc.objChat = self.objChat
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnOnClickRemoveGroup(_ sender: UIButton) {
        if self.objChat?.isAdmin == true {
            showDeleteConfirmation(from: self, message: "Are you sure want to remove the group?".localized, title: "Remove".localized) { confirmed in
                if confirmed {
                    self.wsRemoveGroup()
                }
            }
        } else {
            Utility.showToast(message: "You are not admin of this group".localized)
            return
        }
    }
}

// MARK: - UI helpers
extension CreateNewGroupVC {
    func InitConfig() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.btnCreate?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnCreate?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        self.vwList?.layer.cornerRadius = 10.0
        self.vwList?.layer.masksToBounds = true
        self.imgProfile?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 40.0, borderWidth: 0.0)
        self.vwDescription?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 10.0, borderWidth: 0.0)
        //self.imagePicker.viewController = self
        self.vwSub?.layer.cornerRadius = 20
        self.vwSub?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.vwSub?.clipsToBounds = true
        
        self.imgUserProfile?.layer.cornerRadius = 20.0
        self.imgUserProfile?.layer.masksToBounds = true
        
        self.vwSubProfile?.forEach({
            $0.layer.cornerRadius = 10.0
            $0.layer.masksToBounds = true
        })
        self.setupLocalized()
        self.configureTableView()
        self.vw1?.layer.cornerRadius = 10.0
        self.vw1?.layer.masksToBounds = true
        self.vw1?.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMaxXMinYCorner
        ]
        self.vw4?.layer.cornerRadius = 10.0
        self.vw4?.layer.masksToBounds = true
        self.vw4?.layer.maskedCorners = [
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner
        ]
        if self.isFromUpdate == false {
            self.vwGroupDesc.isHidden = true
            self.stackBottom?.isHidden = true
            self.btnCreate?.setTitle("Create".localized, for: .normal)
            self.btnEdit?.isHidden = true
            self.lblName?.text = self.dictParam[PARAMS.GROUP_NAME] as? String
            self.imgProfile?.image = self.profileImage
            self.vwCreateLink?.isHidden = true
        } else {
            self.vwGroupDesc.isHidden = false
            self.btnCreate?.setTitle("Update".localized, for: .normal)
            self.stackBottom?.isHidden = false
            self.wsGetGroupDetails()
        }
    }
    
    func configureTableView() {
        tblAdmin?.separatorStyle = .none
        tblAdmin?.delegate = self
        tblAdmin?.dataSource = self
        tblAdmin?.register(
            UINib(nibName: "AdminTVCell", bundle: nil),
            forCellReuseIdentifier: AdminTVCell.reuseIdentifier
        )
        
        tblModeratore?.separatorStyle = .none
        tblModeratore?.delegate = self
        tblModeratore?.dataSource = self
        tblModeratore?.register(
            UINib(nibName: "AdminTVCell", bundle: nil),
            forCellReuseIdentifier: AdminTVCell.reuseIdentifier
        )
        
        tblMember?.separatorStyle = .none
        tblMember?.delegate = self
        tblMember?.dataSource = self
        tblMember?.register(
            UINib(nibName: "AdminTVCell", bundle: nil),
            forCellReuseIdentifier: AdminTVCell.reuseIdentifier
        )
    }
    
    func setupLocalized() {
        self.lblTitle?.text = objChat?.id != nil ? "Update Group".localized : "Create New Group".localized
        self.lblListingsTitle?.text = "Listings".localized
        self.lblAddAdminTitle?.text = "Add Admin".localized
        self.lblAddModeratorTitle?.text = "Add Moderator".localized
        self.lblAddMemberTitle?.text = "Add Member".localized
        self.lblCreateInviteTitle?.text = "Create Invite link".localized
        self.lblLeaveGroupTitle?.text = "Leave the Group".localized
        self.lblDeleteGroup?.text = "Delete the Group".localized
        // self.lblProfileTitle?.text = "Profile".localized
        self.lblProfileTitle?.text = "معلومات الحساب".localized
        self.lblChangeTitle?.text = "Change User Permissions".localized
        self.lblRemoveTitle?.text = "Remove from the group".localized
        self.lblDescription?.text = "Add group description".localized
        self.btnEdit.setTitle("Edit".localized, for: .normal)
    }
}

// MARK: - UITableView Delegate & DataSource
extension CreateNewGroupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblAdmin {
            self.heightAdmin?.constant = CGFloat(self.arrAdmin.count * 35)
            return self.arrAdmin.count
        } else if tableView == tblModeratore {
            self.heightModeratore?.constant = CGFloat(self.arrModeratore.count * 35)
            return self.arrModeratore.count
        } else {
            self.heightMember?.constant = CGFloat(self.arrMember.count * 35)
            return self.arrMember.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdminTVCell", for: indexPath) as? AdminTVCell else {
            return UITableViewCell()
        }
        if tableView == tblAdmin {
            let objAdmin = self.arrAdmin[indexPath.row]
            cell.lblStatus?.text = "Admin".localized
            cell.lblStatus?.textColor = UIColor.themePrimaryColor
            cell.lblName?.text = (objAdmin.displayName?.isEmpty == false) ? objAdmin.displayName : Utility.formattedPhoneNumber(objAdmin.mobile)
            
            if let url = URL(string: objAdmin.avatar ?? ""){
                cell.icnProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
            if UserDefaultsHelper.getUserFromDefaults()?.userId == objAdmin.id {
                cell.icnArrow?.image = UIImage(named: "")
            } else {
                cell.icnArrow?.image = UIImage(named: "icn_right_arrow")
            }
            return cell
        } else if tableView == tblModeratore {
            let objModeratore = self.arrModeratore[indexPath.row]
            cell.lblStatus?.text = "Moderatore".localized
            cell.lblStatus?.textColor = UIColor.themeBackgroundGreenColor
            cell.lblName?.text = (objModeratore.displayName?.isEmpty == false) ? objModeratore.displayName : Utility.formattedPhoneNumber(objModeratore.mobile)
            if let url = URL(string: objModeratore.avatar ?? ""){
                cell.icnProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
            if UserDefaultsHelper.getUserFromDefaults()?.userId == objModeratore.id {
                cell.icnArrow?.image = UIImage(named: "")
            } else {
                cell.icnArrow?.image = UIImage(named: "icn_right_arrow")
            }
            return cell
        } else {
            let objMember = self.arrMember[indexPath.row]
            cell.lblStatus?.text = "Member".localized
            cell.lblStatus?.textColor = UIColor.theme999999
            cell.lblName?.text = (objMember.displayName?.isEmpty == false) ? objMember.displayName : Utility.formattedPhoneNumber(objMember.mobile)
            
            if let url = URL(string: objMember.avatar ?? ""){
                cell.icnProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblAdmin {
            let objAdmin = self.arrAdmin[indexPath.row]
            self.objGroupUser = objAdmin
            if objChat?.isAdmin != true {
                wsAddChat(members: [objAdmin.id ?? ""])
            } else {
                self.subView?.isHidden = false
            }
            self.strCurrentType = "admin"
            self.lblUserStatus?.text = "Admin".localized
            self.lblUserName?.text = objAdmin.displayName
            
            if let url = URL(string: objAdmin.avatar ?? "") {
                self.imgUserProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
            
            if UserDefaultsHelper.getUserFromDefaults()?.userId == objAdmin.id {
                self.subView?.isHidden = true
            } else {
                self.vwProfileMenu?.isHidden = false
                self.vw1?.isHidden = false
                self.vw2?.isHidden = false
                self.vw3?.isHidden = true
                self.vw4?.isHidden = false
                
                self.vw1?.layer.cornerRadius = 10.0
                self.vw1?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.vw4?.layer.cornerRadius = 10.0
                self.vw4?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            
        } else if tableView == tblModeratore {
            let objModeratore = self.arrModeratore[indexPath.row]
            self.objGroupUser = objModeratore
            if UserDefaultsHelper.getUserFromDefaults()?.userId == objModeratore.id {
                self.subView?.isHidden = true
            } else {
                if objChat?.isAdmin != true {
                    wsAddChat(members: [objModeratore.id ?? ""])
                } else {
                    self.subView?.isHidden = false
                }
            }
            self.strCurrentType = "moderator"
            self.lblUserStatus?.text = "Moderatore".localized
            self.lblUserName?.text = objModeratore.displayName
            
            if let url = URL(string: objModeratore.avatar ?? "") {
                self.imgUserProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
            
            self.vw1?.isHidden = false
            self.vw2?.isHidden = true
            self.vw3?.isHidden = false
            self.vw4?.isHidden = !(self.objChat?.isAdmin ?? false)
            
            self.vw1?.layer.cornerRadius = 10.0
            self.vw1?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.vw4?.layer.cornerRadius = 10.0
            self.vw4?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        } else {
            let objMember = self.arrMember[indexPath.row]
            self.objGroupUser = objMember
            
            if UserDefaultsHelper.getUserFromDefaults()?.userId == objMember.id {
                self.subView?.isHidden = true
            } else {
                if objChat?.isAdmin != true {
                    wsAddChat(members: [objMember.id ?? ""])
                } else {
                    self.subView?.isHidden = false
                }
            }
            self.strCurrentType = "member"
            
            self.lblUserStatus?.text = "Member".localized
            self.lblUserName?.text = objMember.displayName
            
            if let url = URL(string: objMember.avatar ?? "") {
                self.imgUserProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            }
            
            self.vw1?.isHidden = true
            self.vw2?.isHidden = false
            self.vw3?.isHidden = false
            self.vw4?.isHidden = !(self.objChat?.isAdmin ?? false)
            
            self.vw2?.layer.cornerRadius = 10.0
            self.vw2?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.vw4?.layer.cornerRadius = 10.0
            self.vw4?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
}

// MARK: - Web Service Calls
extension CreateNewGroupVC {
    
    func wsGetGroupDetails() {
        Utility.showLoading()
        WebServices.Get(url: "\(WebService.CHATS)\(objChat?.id ?? "")/", type: ChatMessage.self) { response in
            Utility.hideLoading()
            if let page = response {
                self.objChat = page
                self.lblTitle?.text = "Update Group".localized
                if let url = URL(string: page.groupImage ?? ""){
                    self.imgProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
                }
                self.lblName?.text = page.groupName
                if page.groupDescription == "" || page.groupDescription == nil {
                    self.lblDescription?.text = "Add group description".localized
                } else {
                    self.lblDescription?.text = page.groupDescription
                }
                self.lblTotalGroupMember?.text = "مجموعة من \(page.totalPeoples ?? 0) شخص"
                self.arrAdmin = page.admin ?? []
                self.tblAdmin?.reloadData()
                self.arrModeratore = page.moderator ?? []
                self.tblModeratore?.reloadData()
                self.arrMember = page.member ?? []
                self.tblMember?.reloadData()
                
                if page.isAdmin == true {
                    self.tblMember?.isHidden = false
                    self.stackAdminStep.isHidden = false
                    self.btnEdit?.isHidden = false
                    self.vwDeleteGroup?.isHidden = false
                    self.vwLeave?.isHidden = false
                    self.vwModerator?.isHidden = false
                    self.vwMember?.isHidden = false
                    self.vwAdmin?.isHidden = false
                    self.btnCreate?.isHidden = false
                    self.vw4?.isHidden = false
                    self.vwChangePermisson?.isHidden = false
                    self.btnProfileImage?.isUserInteractionEnabled = true
                    self.btnName?.isUserInteractionEnabled = true
                    self.vwCreateLink?.isHidden = false
                } else if page.isMember == true {
                    self.vwCreateLink?.isHidden = true
                    self.btnEdit?.isHidden = true
                    self.tblMember?.isHidden = true
                    self.vwLeave?.isHidden = false
                    self.vwDeleteGroup?.isHidden = true
                    self.vwAdmin?.isHidden = true
                    self.vwModerator?.isHidden = true
                    self.vwMember?.isHidden = true
                    self.btnCreate?.isHidden = true
                    self.vw4?.isHidden = true
                    self.vwChangePermisson?.isHidden = true
                    self.btnProfileImage?.isUserInteractionEnabled = false
                    self.btnName?.isUserInteractionEnabled = false
                    self.stackAdminStep.isHidden = true
                } else if page.isModerator == true {
                    self.vwCreateLink?.isHidden = true
                    self.btnEdit?.isHidden = true
                    self.tblMember?.isHidden = false
                    self.stackAdminStep.isHidden = true
                    self.vwDeleteGroup?.isHidden = true
                    self.vwLeave?.isHidden = false
                    self.vwAdmin?.isHidden = true
                    self.vwModerator?.isHidden = true
                    self.vwMember?.isHidden = true
                    self.btnCreate?.isHidden = true
                    self.vw4?.isHidden = true
                    self.vwChangePermisson?.isHidden = true
                    self.btnProfileImage?.isUserInteractionEnabled = false
                    self.btnName?.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    func wsAddGroupChat() {
        Utility.showLoading()
        let adminIDs = arrAdmin.compactMap { $0.id }
        dictParam[PARAMS.ADMINS] = adminIDs
        let moderatoreIDs = arrModeratore.compactMap { $0.id }
        dictParam[PARAMS.MODERATORS] = moderatoreIDs
        let memberIDs = arrMember.compactMap { $0.id }
        dictParam[PARAMS.MEMBERS] = memberIDs
        WebServices.Post(url: "\(WebService.CHATS)", params: dictParam, type: ChatMessage.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            if let data = response {
                Utility.showToast(message: "Group add successfully".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                    if let groupChatDetailVC = storyboard.instantiateViewController(withIdentifier: "GroupChatDetailVC") as? GroupChatDetailVC {
                        groupChatDetailVC.objChat = data
                        self.navigationController?.pushViewController(groupChatDetailVC, animated: true)
                    }
                }
            }
        }
    }
    
    func wsUpdateGroupChat() {
        Utility.showLoading()
        let adminIDs = arrAdmin.compactMap { $0.id }
        dictParam[PARAMS.ADMINS] = adminIDs
        let moderatoreIDs = arrModeratore.compactMap { $0.id }
        dictParam[PARAMS.MODERATORS] = moderatoreIDs
        let memberIDs = arrMember.compactMap { $0.id }
        dictParam[PARAMS.MEMBERS] = memberIDs
        WebServices.Put(url: "\(WebService.CHATS)\(self.objChat?.id ?? "")/", params: dictParam, type: ChatMessage.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            Utility.showToast(message: "Group update successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func wsGroupChat(currentType: String, userId: String, newType: String) {
        Utility.showLoading()
        WebServices.Put(url: "\(WebService.CHATS)\(self.objChat?.id ?? "")/change/\(currentType)/\(userId)/\(newType)/", params: [:], type: ChatMessage.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            if let page = response {
                self.subView?.isHidden = true
                self.objChat = page
                self.lblTitle?.text = "Update Group".localized
                if let url = URL(string: page.groupImage ?? ""){
                    self.imgProfile?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
                }
                self.lblName?.text = page.groupName
                if page.groupDescription == "" || page.groupDescription == nil {
                    self.lblDescription?.text = "Add group description".localized
                } else {
                    self.lblDescription?.text = page.groupDescription
                }
                self.lblTotalGroupMember?.text = "مجموعة من \(page.totalPeoples ?? 0) شخص"
                self.arrAdmin = page.admin ?? []
                self.tblAdmin?.reloadData()
                self.arrModeratore = page.moderator ?? []
                self.tblModeratore?.reloadData()
                self.arrMember = page.member ?? []
                self.tblMember?.reloadData()
                
                if page.isAdmin == true {
                    self.tblMember?.isHidden = false
                    self.stackAdminStep.isHidden = false
                    self.btnEdit?.isHidden = false
                    self.vwDeleteGroup?.isHidden = false
                    self.vwLeave?.isHidden = false
                    self.vwModerator?.isHidden = false
                    self.vwMember?.isHidden = false
                    self.vwAdmin?.isHidden = false
                    self.btnCreate?.isHidden = false
                    self.vw4?.isHidden = false
                    self.vwChangePermisson?.isHidden = false
                    self.btnProfileImage?.isUserInteractionEnabled = true
                    self.btnName?.isUserInteractionEnabled = true
                    self.vwCreateLink?.isHidden = false
                } else if page.isMember == true {
                    self.vwCreateLink?.isHidden = true
                    self.btnEdit?.isHidden = true
                    self.tblMember?.isHidden = true
                    self.vwLeave?.isHidden = false
                    self.vwDeleteGroup?.isHidden = true
                    self.vwAdmin?.isHidden = true
                    self.vwModerator?.isHidden = true
                    self.vwMember?.isHidden = true
                    self.btnCreate?.isHidden = true
                    self.vw4?.isHidden = true
                    self.vwChangePermisson?.isHidden = true
                    self.btnProfileImage?.isUserInteractionEnabled = false
                    self.btnName?.isUserInteractionEnabled = false
                    self.stackAdminStep.isHidden = true
                } else if page.isModerator == true {
                    self.vwCreateLink?.isHidden = true
                    self.btnEdit?.isHidden = true
                    self.tblMember?.isHidden = false
                    self.stackAdminStep.isHidden = true
                    self.vwDeleteGroup?.isHidden = true
                    self.vwLeave?.isHidden = false
                    self.vwAdmin?.isHidden = true
                    self.vwModerator?.isHidden = true
                    self.vwMember?.isHidden = true
                    self.btnCreate?.isHidden = true
                    self.vw4?.isHidden = true
                    self.vwChangePermisson?.isHidden = true
                    self.btnProfileImage?.isUserInteractionEnabled = false
                    self.btnName?.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    func wsLeaveGroup() {
        guard let chatID = objChat?.id else { return }
        
        Utility.showLoading()
        WebServices.Delete(url: "\(WebService.CHATS)\(chatID)/leave/", type: ChatMessage.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            Utility.showToast(message: "Leave the group successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func wsDeleteGroup() {
        guard let chatID = objChat?.id else { return }
        
        Utility.showLoading()
        WebServices.Delete(url: "\(WebService.CHATS)\(chatID)/", type: ChatMessage.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            Utility.showToast(message: "Delete the group successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func wsRemoveGroup() {
        guard let chatID = objChat?.id else { return }
        Utility.showLoading()
        WebServices.Delete(url: "\(WebService.CHATS)\(chatID)/remove/\(self.objGroupUser?.id ?? "")/", type: ChatMessage.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            Utility.showToast(message: "Remove the group successfully".localized)
            self.subView?.isHidden = true
            self.wsGetGroupDetails()
        }
    }
    
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
    
}

extension CreateNewGroupVC {
    
    func handleNewImage(_ img: UIImage) {
        self.imgProfile?.image = img
        self.avatar = convertImageToBase64String(img: img)
    }
    
    func showAlert() {
        // Create alert
        let alert = UIAlertController(title: "Enter Name".localized, message: "Please type something".localized, preferredStyle: .alert)
        
        // Add text field
        alert.addTextField { textField in
            textField.placeholder = "Type here...".localized
        }
        
        // Add OK button (handler will validate)
        let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self.lblName?.text = text
            } else {
                self.present(alert, animated: true) {
                    Utility.showToast(message: "Please enter group name".localized)
                }
            }
        }
        okAction.isEnabled = false   // disable initially
        alert.addAction(okAction)
        
        // Add Cancel button (this will dismiss normally)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Enable OK only when text is entered
        if let textField = alert.textFields?.first {
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { _ in
                let text = textField.text ?? ""
                okAction.isEnabled = !text.isEmpty
            }
        }
        present(alert, animated: true)
    }
}

extension CreateNewGroupVC : delegateDataUpdate {
    func updateData() {
        self.wsGetGroupDetails()
    }
}

extension CreateNewGroupVC : delegateDesc {
    func desc(text: String) {
        self.wsGetGroupDetails()
    }
}
