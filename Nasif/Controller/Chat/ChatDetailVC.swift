//
//  ChatDetailVC.swift
//  Nasif
//
//  Created by Denish Gediya on 07/08/25.
//

import UIKit
import IQKeyboardManagerSwift
import UniformTypeIdentifiers
import SocketIO
import PDFKit
import CoreTelephony
import Contacts
import SDWebImage

// MARK: - Section Model for grouping
struct ChatSection {
    let date: String
    var messages: [ChatGroupMessage]
}

class ChatDetailVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var vwText: UIView?
    @IBOutlet weak var txtMesg: UITextView?
    @IBOutlet weak var tblChat: UITableView?
    @IBOutlet weak var vwSub: UIView?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var vwBottomMessage: UIView?
    @IBOutlet weak var btnProfile: UIButton?
    @IBOutlet weak var btnUnBlock: UIButton?
    @IBOutlet weak var vwUnBlock: UIView?
    @IBOutlet weak var txtHeight: NSLayoutConstraint!
    @IBOutlet var vwImageMenu: [UIView]!
    
    // MARK: - Variables
    var objChat: ChatMessage?
    private var arrChat: [ChatGroupMessage] = []
    private var sections: [ChatSection] = []
    private var pageInfo: ChatMessagesResponse?
    private let refreshControl = UIRefreshControl()
    var keyboardHeight = 60
    private let imagePicker = ImagePicker()
    var objProperty: Property?
    var isFromPush: Bool = false
    var isFromNewPush: Bool = false
    private var isLoadingMessages = false
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        IQKeyboardManager.shared.isEnabled = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        self.vwSub?.isHidden = true
        wsGetGroupDetails()
        pageInfo = nil
        wsGetPersonalChat()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.isEnabled = true
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func btnOnClickUnBlock(_ sender: UIButton) {
        showDeleteConfirmation(from: self,
                               message: "Are you sure want to unblock the member?".localized,
                               title: "UnBlock".localized) { confirmed in
            if confirmed {
                self.wsReportMember(strType: "unblock")
            }
        }
    }
}

//MARK: - IBAction Methods
extension ChatDetailVC {
    
    @IBAction func btnOnClickImage(_ sender: UIButton) {
        self.view.endEditing(true)
        
        imagePicker.pickImage(self, "", type: .single, allowVideo: true) { image, url in
            self.vwSub?.isHidden = true
            
            let fileName = url?.lastPathComponent ?? "image_\(Int(Date().timeIntervalSince1970)).jpg"
            
            if let base64String = self.convertImageToBase64String(img: image) {
                self.wsSendMesg(type: "Image",
                                file: base64String,
                                fileType: "image",
                                fileName: fileName)
            } else {
                print("❌ Failed to convert image to Base64")
            }
            
        } videoHandler: { videoURL in
            self.vwSub?.isHidden = true
            
            let fileName = videoURL.lastPathComponent
            print("📹 Video selected: \(fileName)")
            
            do {
                let videoData = try Data(contentsOf: videoURL)
                let base64String = videoData.base64EncodedString(options: .lineLength64Characters)
                
                self.wsSendMesg(type: "Video",
                                file: base64String,
                                fileType: "video",
                                fileName: fileName)
            } catch {
                print("❌ Failed to read video data: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper function to convert UIImage to Base64 string
    func convertImageToBase64String(img: UIImage) -> String? {
        guard let imageData = img.jpegData(compressionQuality: 0.6) else { return nil }
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
    
    
    @IBAction func btnOnClickFile(_ sender: UIButton) {
        self.view.endEditing(true)
        let supportedTypes: [UTType] = [
            .pdf,
            .plainText,
            .rtf,
            .zip,
            .spreadsheet,
            .presentation,
            .database,
            .xml,
            .json
        ]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func btnOnClickLocation(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Deal", bundle: nil)
        if let dealListVC = storyboard.instantiateViewController(withIdentifier: "DealListVC") as? DealListVC {
            dealListVC.objChat = self.objChat
            dealListVC.objPushType = .Chat
            self.navigationController?.pushViewController(dealListVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickClose(_ sender: UIButton) {
        self.view.endEditing(true)
        self.vwSub?.isHidden = true
    }
    
    @IBAction func btnOnClickAdd(_ sender: UIButton) {
        self.view.endEditing(true)
        self.vwSub?.isHidden = false
    }
    
    @IBAction func btnOnClickSend(_ sender: UIButton) {
        guard let text = self.txtMesg?.text, !text.isEmpty else { return }
        
        // Prepare message for socket
        let objMessage = MessageModel(type: "Text", text: text)
        
        self.scrollToBottom(animated: true)
        self.txtMesg?.text = ""
        
        // Send via socket
        SocketService.shared?.sendChatMessage(chatId: self.objChat?.id, message: objMessage)
        
    }
    
    @IBAction func btnOnClickCall(_ sender: UIButton) {
        let finalNumber = Utility.formattedPhoneNumber(objChat?.oposition?.mobile)
        if let phoneURL = URL(string: "tel://\(finalNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Can't make a call on this device")
        }
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        if isFromNewPush {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnOnClickProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let chatProfileVC = storyboard.instantiateViewController(withIdentifier: "ChatProfileVC") as? ChatProfileVC {
            chatProfileVC.isFromPush = false
            chatProfileVC.objChat = self.objChat
            self.navigationController?.pushViewController(chatProfileVC, animated: true)
        }
    }
}

// MARK: - Refresh
private extension ChatDetailVC {
    @objc func refreshData() {
        self.pageInfo = nil
        self.wsGetPersonalChat()
    }
}

// MARK: - UI helpers
fileprivate extension ChatDetailVC {
    func InitConfig() {
        self.txtMesg?.delegate = self
        txtHeight.constant = 40
        txtMesg?.isScrollEnabled = false
        self.vwImageMenu?.forEach({
            $0.layer.cornerRadius = 20.0
            $0.clipsToBounds = true
        })
        self.tblChat?.separatorStyle = .none
        self.tblChat?.delegate = self
        self.tblChat?.dataSource = self
        self.tblChat?.register(UINib(nibName: "ChatTVCell", bundle: nil), forCellReuseIdentifier: "ChatTVCell")
        self.vwText?.layer.cornerRadius = 22.0
        self.vwText?.layer.masksToBounds = true
        self.configureRefreshControl()
        self.socketHandlers()
        self.btnProfile?.setRound()
        self.btnUnBlock?.setTitle("UnBlock".localized, for: .normal)
        self.btnUnBlock?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnUnBlock?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        if self.isFromPush == true {
            let objMessage = MessageModel(type: "Property", property: objProperty?.id)
            SocketService.shared?.sendChatMessage(chatId: self.objChat?.id, message: objMessage)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.openChatController), name: NSNotification.Name(rawValue: "openChatController"), object: nil)
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
        self.tblChat?.refreshControl = refreshControl
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        bottomConstraint?.constant = frame.cgRectValue.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.scrollToBottom(animated: true)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Scroll helper – KEEP ONLY THIS ONE
    func scrollToBottom(animated: Bool = false) {
        guard let table = tblChat else { return }
        
        DispatchQueue.main.async {
            table.layoutIfNeeded()
            
            guard self.sections.count > 0 else { return }
            let section = self.sections.count - 1
            let row = self.sections[section].messages.count - 1
            guard row >= 0 else { return }
            
            let indexPath = IndexPath(row: row, section: section)
            
            if table.numberOfSections > section &&
                table.numberOfRows(inSection: section) > row {
                
                table.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            } else {
                // Retry if table not ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    self.scrollToBottom(animated: animated)
                }
            }
        }
    }
}

// MARK: - TableView Delegate & DataSource
extension ChatDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return sections[section].messages.count
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let container = UIView()
        container.backgroundColor = .clear
        
        let label = UILabel()
        label.text = sections[section].date.localized
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .black
        label.backgroundColor = UIColor(white: 0.90, alpha: 1) // Light grey like screenshot
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        
        // Shadow (Optional - looks nice like WhatsApp)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.08
        label.layer.shadowRadius = 4
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 28),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -30)
        ])
        
        return container
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        guard let page = pageInfo else { return }
        
        // Load more only when user reaches very first message
        if page.hasNextPage && indexPath.section == 0 && indexPath.row == 0 && !isLoadingMessages {
            
            let oldOffset = tableView.contentOffset.y
            wsGetPersonalChat(showLoader: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                // restore scroll position (NO jump)
                let newOffset = (self.tblChat?.contentSize.height ?? 0) - oldOffset
                self.tblChat?.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTVCell",
                                                       for: indexPath) as? ChatTVCell else {
            return UITableViewCell()
        }
        
        // ✅ Crash Prevention: Ensure section & row exist
        guard sections.indices.contains(indexPath.section),
              sections[indexPath.section].messages.indices.contains(indexPath.row) else {
            print("⚠️ Invalid IndexPath -> section: \(indexPath.section), row: \(indexPath.row)")
            return UITableViewCell()
        }
        
        let msg = sections[indexPath.section].messages[indexPath.row]
        cell.configure(with: msg)
        cell.parentDelegate = self
        // 🔹 Keep your hidden labels setup same
        cell.lblLeftSenderMesgName.isHidden = true
        cell.lblLeftImageSenderName.isHidden = true
        cell.lblVideoUploadName.isHidden = true
        cell.lblSendFileName.isHidden = true
        cell.lblLeftSenertPropertyName.isHidden = true
        cell.lblRightReciverMesgName.isHidden = true
        cell.lblRightImageReceiverName.isHidden = true
        cell.lblRightVideoUploadName.isHidden = true
        cell.lblRightSendFileName.isHidden = true
        cell.lblRightReceiverPropertyName.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let obj = sections[indexPath.section].messages[indexPath.row]
        if obj.type == "Image" {
            let customVC = ImagePreviewVC()
            customVC.isFromHide = true
            customVC.strImage = obj.file ?? ""
            self.navigationController?.pushViewController(customVC, animated: true)
        } else if obj.type == "File" {
            if let url = URL(string: obj.file ?? "") {
                openPDF(url: url)
            }
        } else if obj.type == "Property" {
            if let property = obj.property {
                navigateToDetail(for: property)
            }
        }
    }
    
    func navigateToDetail(for property: ChatProperty) {
        let detailVC = ListingDetailVC()
        detailVC.isFromPush = true
        detailVC.strProperty = property.id ?? ""
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Document Picker
extension ChatDetailVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        vwSub?.isHidden = true
        let fileName = fileURL.lastPathComponent
        if let base64String = convertFileToBase64String(fileURL: fileURL) {
            wsSendMesg(type: "File",
                       file: base64String,
                       fileType: "pdf",
                       fileName: fileName)
        }
    }
    
    private func convertFileToBase64String(fileURL: URL) -> String? {
        do {
            let fileData = try Data(contentsOf: fileURL)
            return fileData.base64EncodedString(options: .lineLength64Characters)
        } catch {
            print("❌ Error converting file: \(error)")
            return nil
        }
    }
}

// MARK: - Web Service Calls
fileprivate extension ChatDetailVC {
    
    @objc func openChatController(_ notification: Notification){
        if let chat = notification.userInfo?["content"] as? ChatMessage {
            self.objChat = chat
            pageInfo = nil
            wsGetPersonalChat()
        }
    }
    
    func socketHandlers(){
        guard let chatID = objChat?.id else { return }
        
        SocketService.shared?.socket.on("chat/\(chatID)") { [weak self] _,_ in
            guard let self = self else { return }
            
            self.pageInfo = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.wsGetPersonalChat(showLoader: false)
            }
            
            if let table = self.tblChat {
                let isAtBottom = table.contentOffset.y >= table.contentSize.height - table.frame.height - 50
                if isAtBottom { self.scrollToBottom(animated: true) }
            }
            
        }
    }
    
    func wsGetGroupDetails() {
        Utility.showLoading()
        WebServices.Get(url: "\(WebService.CHATS)\(objChat?.id ?? "")/",
                        type: ChatMessage.self) { response in
            Utility.hideLoading()
            if let page = response {
                self.objChat = page
                let name = self.objChat?.oposition?.displayName
                self.lblName?.text = (name?.isEmpty == false) ? name : Utility.formattedPhoneNumber(self.objChat?.oposition?.mobile)
                
                if let avatar = self.objChat?.oposition?.avatar,
                   let url = URL(string: avatar),
                   !avatar.isEmpty {
                    self.btnProfile?.sd_setImage(with: url,
                                                 for: .normal,
                                                 placeholderImage: UIImage(named: "icn_contact_placeholder"))
                } else {
                    self.btnProfile?.setImage(UIImage(named: "icn_contact_placeholder"),
                                              for: .normal)
                }
                
                if self.objChat?.isBlock ?? false {
                    self.vwBottomMessage?.isHidden = true
                    self.vwUnBlock?.isHidden = false
                } else {
                    self.vwBottomMessage?.isHidden = false
                    self.vwUnBlock?.isHidden = true
                }
            }
        }
    }
    
    func wsReportMember(strType: String) {
        guard let chatID = objChat?.oposition?.id else { return }
        Utility.showLoading()
        WebServices.Delete(url: "\(WebService.CHATS)\(chatID)/\(strType)/",
                           type: ChatMessage.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            if response?.status == false {
                Utility.showToast(message: "User not found".localized)
            } else {
                self.wsGetGroupDetails()
            }
        }
    }
    
    func wsGetPersonalChat(showLoader: Bool = true) {
        
        // ❌ If already loading → exit
        if isLoadingMessages { return }
        isLoadingMessages = true
        
        if showLoader { Utility.showLoading() }
        
        let nextPage = (pageInfo?.page ?? 0) + 1
        let url = "\(WebService.CHATS)\(objChat?.id ?? "")/messages/?page=\(nextPage)&size=20"
        
        WebServices.Get(url: url, type: ChatMessagesResponse.self) { response in
            
            self.isLoadingMessages = false  // <-- ✓ reset here
            
            Utility.hideLoading()
            self.refreshControl.endRefreshing()
            
            guard let page = response else { return }
            
            let newMessagesAsc = page.content.reversed()
            
            if self.pageInfo == nil {
                // First Load
                self.arrChat = Array(newMessagesAsc)
            } else {
                // Pagination → add older message at top
                let previousHeight = self.tblChat?.contentSize.height ?? 0
                self.arrChat.insert(contentsOf: newMessagesAsc, at: 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    let newHeight = self.tblChat?.contentSize.height ?? 0
                    let offset = newHeight - previousHeight
                    self.tblChat?.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                }
            }
            
            self.pageInfo = page
            self.buildSectionsFromMessages()
            
            // 👉 Only first time auto-scroll to bottom
            if nextPage == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.scrollToBottom(animated: false)
                }
            }
            
            
        }
    }
    
    func buildSectionsFromMessages() {
        
        // 1️⃣ Final sorted array oldest → newest
        let sorted = arrChat.sorted(by: { (msg1: ChatGroupMessage, msg2: ChatGroupMessage) -> Bool in
            (msg1.createdAtDate ?? Date.distantPast) < (msg2.createdAtDate ?? Date.distantPast)
        })
        
        // 2️⃣ Group by Section Date
        var sectionArray: [ChatSection] = []
        
        for msg in sorted {
            let header = formattedDate(msg.createdAt ?? "")
            
            if let index = sectionArray.firstIndex(where: { $0.date == header }) {
                sectionArray[index].messages.append(msg)
            } else {
                sectionArray.append(ChatSection(date: header, messages: [msg]))
            }
        }
        
        // 3️⃣ Update UI Data Source
        sections = sectionArray
        
        DispatchQueue.main.async {
            self.tblChat?.reloadData()
            
            // 🔥 Important - Wait until rendering is complete
            self.tblChat?.layoutIfNeeded()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.scrollToBottom(animated: false)
            }
        }
        
        
    }
    
    func wsSendMesg(type: String,
                    file: String,
                    fileType: String,
                    fileName: String) {
        Utility.showLoading()
        let params: [String: Any] = [
            PARAMS.TYPE: type,
            PARAMS.FILE: file,
            PARAMS.FILE_TYPE: fileType,
            PARAMS.FILE_NAME: fileName
        ]
        let url = "\(WebService.CHATS)\(objChat?.id ?? "")/message/"
        WebServices.Post(url: url,
                         params: params,
                         type: ChatMessagesResponse.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
        }
    }
    
    func formattedDate(_ isoString: String) -> String {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: isoString) else { return "" }
        
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)  // << FIX
        df.locale = Locale(identifier: "en_US_POSIX")   // << FIX
        df.dateFormat = "dd/MM/yyyy"
        
        return df.string(from: date)
    }
    
    func dateFromString(_ str: String) -> Date {
        
        if str == "Today" { return Date() }
        
        if str == "Yesterday" {
            return Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: Date()) ?? Date()
        }
        
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)   // << FIX
        df.locale = Locale(identifier: "en_US_POSIX")    // << FIX
        df.dateFormat = "dd/MM/yyyy"
        
        return df.date(from: str) ?? Date.distantPast
    }
    
    func joinGroup(groupId: String, window: UIWindow?) {
        Utility.showLoading()
        
        WebServices.Put(url: "\(WebService.CHATS)\(groupId)/join/",
                        params: [:],
                        type: ChatMessage.self) { response in
            Utility.hideLoading()
            
            guard var chatObj = response else {
                Utility.showToast(message: "Failed to join group.".localized)
                return
            }
            
            chatObj.isGroup = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: NSNotification.Name("openController"),
                                                object: nil,
                                                userInfo: ["content": chatObj])
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension ChatDetailVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(
            CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        )
        
        let minHeight: CGFloat = 40      // initial height
        let maxHeight: CGFloat = 100     // max limit
        
        let finalHeight = min(max(newSize.height, minHeight), maxHeight)
        txtHeight.constant = finalHeight
        
        textView.isScrollEnabled = (newSize.height > maxHeight)
        
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatGroupMessage {
    var createdAtDate: Date? {
        guard let createdAt = createdAt else { return nil }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt)
    }
}

extension ChatDetailVC: LinkHandlerDelegate {
    
    func handleJoinGroup(groupId: String) {
        print("🚀 Joining group from VC → \(groupId)")
        joinGroup(groupId: groupId, window: self.view.window)
    }
}
