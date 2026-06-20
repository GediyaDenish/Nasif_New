//
//  ChatVC.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit

class ChatVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwSearch: UIView?
    @IBOutlet weak var txtSearch: UITextField?
    @IBOutlet weak var lblNoData: UILabel?
    @IBOutlet weak var tblChat: UITableView?
    @IBOutlet weak var vwSubMenu: UIView?
    @IBOutlet weak var btnNewChat: UIButton?
    @IBOutlet weak var btnNewGroup: UIButton?
    @IBOutlet weak var btnCancel: UIButton?
    @IBOutlet weak var vwChat: UIView?
    @IBOutlet weak var vwNewGroup: UIView?
    @IBOutlet weak var lblNewChatTitel: UILabel!
    @IBOutlet weak var lblCreateNewTitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - Variables
    private var pageInfo: ChatModel?
    private let refreshControl = UIRefreshControl()
    private var arrChat: [ChatMessage] = []
    private var arrOriginalChat: [ChatMessage] = []   // <-- added for search
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        InitConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.pageInfo = nil
        self.arrChat.removeAll()
        self.tblChat?.reloadData()
        wsGetChat()
    }
}

//MARK: - IBAction Mthonthd
extension ChatVC {
    @IBAction func btnOnClickNewChat(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.vwSubMenu?.isHidden = true
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let contactChatVC = storyboard.instantiateViewController(withIdentifier: "ContactChatVC") as? ContactChatVC {
            contactChatVC.onNormalDismiss = { [weak self] in
                guard let self else { return }
                if let ownerContactVC = storyboard.instantiateViewController(withIdentifier: "CreateGroupProfileVC") as? CreateGroupProfileVC {
                    self.navigationController?.pushViewController(ownerContactVC, animated: true)
                }
            }
            contactChatVC.onDismiss = { [weak self] objChatModel in
                guard let self else { return }
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                if let chatDetailVC = storyboard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC {
                    chatDetailVC.objChat = objChatModel
                    chatDetailVC.isFromNewPush = false
                    self.navigationController?.pushViewController(chatDetailVC, animated: true)
                }
            }
            self.present(contactChatVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickChat(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.vwSubMenu?.isHidden = true
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let contactChatVC = storyboard.instantiateViewController(withIdentifier: "ContactChatVC") as? ContactChatVC {
            contactChatVC.onDismiss = { [weak self] objChatModel in
                guard let self else { return }
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                if let chatDetailVC = storyboard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC {
                    chatDetailVC.objChat = objChatModel
                    chatDetailVC.isFromNewPush = false
                    self.navigationController?.pushViewController(chatDetailVC, animated: true)
                }
            }
            self.present(contactChatVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickGroup(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.vwSubMenu?.isHidden = true
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let ownerContactVC = storyboard.instantiateViewController(withIdentifier: "CreateGroupProfileVC") as? CreateGroupProfileVC {
            self.navigationController?.pushViewController(ownerContactVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickCancel(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.vwSubMenu?.isHidden = true
    }
}

// MARK: - UI helpers
fileprivate extension ChatVC {
    func InitConfig() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.lblNoData?.text = "No user data".localized
        self.vwSearch?.layer.cornerRadius = 25.0
        self.vwSearch?.layer.masksToBounds = true
        self.txtSearch?.delegate = self
        self.txtSearch?.returnKeyType = .search
        self.tblChat?.separatorStyle = .none
        self.tblChat?.delegate = self
        self.tblChat?.dataSource = self
        self.tblChat?.register(UINib(nibName: "ChatListTVCell", bundle: nil), forCellReuseIdentifier: "ChatListTVCell")
        self.tblChat?.refreshControl = refreshControl
        self.btnCancel?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0)
        self.vwChat?.layer.cornerRadius = 20.0
        self.vwChat?.layer.masksToBounds = true
        self.vwNewGroup?.layer.cornerRadius = 20.0
        self.vwNewGroup?.layer.masksToBounds = true
        self.lblNewChatTitel.text = "New Chat".localized
        self.lblCreateNewTitle.text = "Create New Group".localized
        self.lblTitle.text = "Chat".localized
        self.btnCancel?.setTitle("Cancel".localized, for: .normal)
        self.configureRefreshControl()
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
    }
}

// MARK: - Refresh
private extension ChatVC {
    @objc func refreshData() {
        pageInfo = nil
        wsGetChat()
    }
}

// MARK: - TableView Delegate & DataSource
extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrChat.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let page = self.pageInfo, page.hasNextPage, indexPath.row == self.arrChat.count - 1 {
            self.wsGetChat()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTVCell", for: indexPath) as? ChatListTVCell else {
            return UITableViewCell()
        }
        let objChat = self.arrChat[indexPath.row]
        cell.configureChat(with: objChat)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let objChat = arrChat[indexPath.row]
        if objChat.isGroup == true {
            if let groupChatDetailVC = storyboard.instantiateViewController(withIdentifier: "GroupChatDetailVC") as? GroupChatDetailVC {
                groupChatDetailVC.objChat = objChat
                self.navigationController?.pushViewController(groupChatDetailVC, animated: true)
            }
        } else {
            if let chatDetailVC = storyboard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC {
                chatDetailVC.objChat = objChat
                chatDetailVC.isFromNewPush = false
                self.navigationController?.pushViewController(chatDetailVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Web Service
private extension ChatVC {
    
    private func filterChat(with text: String) {
        guard !text.isEmpty else {
            self.arrChat = self.arrOriginalChat
            self.tblChat?.reloadData()
            return
        }
        
        let key = text.lowercased()
        
        self.arrChat = self.arrOriginalChat.filter { chat in
            let name = chat.oposition?.displayName?.lowercased() ?? ""
            let group = chat.groupName?.lowercased() ?? ""
            return name.contains(key) || group.contains(key)
        }
        
        self.tblChat?.reloadData()
        self.lblNoData?.isHidden = !self.arrChat.isEmpty
    }
    
    func wsGetChat() {
        
        Utility.showLoading()
        
        let nextPage = (pageInfo?.page ?? 0) + 1
        let url = "\(WebService.CHATS)?page=\(nextPage)&size=10&search=\(self.txtSearch?.text ?? "")"
        
        WebServices.Get(url: url, type: ChatModel.self) { [weak self] response in
            guard let self = self else { return }
            guard let result = response else { return }
            
            DispatchQueue.main.async {
                
                if nextPage == 1 {
                    self.arrChat.removeAll()   // reset only on first page
                }
                
                // append new page data
                self.arrChat.append(contentsOf: result.content)
                
                // update header info
                self.pageInfo = result
                
                // ********* AUTO LOAD NEXT PAGE *********
                if result.hasNextPage {
                    self.wsGetChat()   // 🔥 Recursive call till last page
                    return
                }
                
                // 🚀 Sorting only when last page loaded
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                self.arrChat.sort { (c1, c2) -> Bool in
                    let d1 = formatter.date(from: c1.lastMessage?.createdAt ?? "") ?? .distantPast
                    let d2 = formatter.date(from: c2.lastMessage?.createdAt ?? "") ?? .distantPast
                    return d1 > d2
                }
                
                self.arrOriginalChat = self.arrChat
                
                // reload UI
                Utility.hideLoading()
                self.refreshControl.endRefreshing()
                self.tblChat?.reloadData()
                
                self.lblNoData?.isHidden = !self.arrChat.isEmpty
                self.tblChat?.isHidden = self.arrChat.isEmpty
            }
        }
    }
    
}

extension ChatVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let updatedText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        filterChat(with: updatedText)   // <-- added
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.pageInfo = nil
        self.wsGetChat()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            self.pageInfo = nil
            self.wsGetChat()
        }
        return true
    }
}

