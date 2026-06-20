//
//  GroupChatDetailVC.swift
//  Nasif
//
//  Created by Denish Gediya on 07/10/25.
//

import UIKit
import IQKeyboardManagerSwift
import UniformTypeIdentifiers
import SocketIO

class GroupChatDetailVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblTotalGroupMember: UILabel?
    @IBOutlet weak var vwText: UIView?
    @IBOutlet weak var txtMesg: UITextView?
    @IBOutlet weak var tblChat: UITableView?
    @IBOutlet weak var vwSub: UIView?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var btnProfile: UIButton?
    @IBOutlet weak var vwBottomMessage: UIView?
    @IBOutlet weak var txtHeight: NSLayoutConstraint!
    @IBOutlet var vwImageMenu: [UIView]?
    
    // MARK: - Variables
    private var arrChat: [ChatGroupMessage] = []
    private var pageInfo: ChatMessagesResponse?
    private let refreshControl = UIRefreshControl()
    var objChat: ChatMessage?
    private let imagePicker = ImagePicker()
    var objProperty: Property?
    var isFromPush: Bool = false
    var groupId: String = ""
    private var sections: [ChatSection] = []
    private var isLoadingMessages = false
    
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.vwSub?.isHidden = true
        self.vwImageMenu?.forEach({
            $0.layer.cornerRadius = 20.0
            $0.clipsToBounds = true
        })
        IQKeyboardManager.shared.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.wsGetGroupDetails()
        pageInfo = nil
        wsGetGroupChat()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.isEnabled = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Refresh
private extension GroupChatDetailVC {
    @objc func refreshData() {
        self.pageInfo = nil
        self.wsGetGroupChat()
    }
}

//MARK: - IBAction Mthonthd
extension GroupChatDetailVC {
    @IBAction func btnOnClickImage(_ sender: UIButton) {
        self.view.endEditing(true)
        imagePicker.pickImage(self, "", type: .single, allowVideo: true) { image, url in
            // 🖼️ Handle image selection
            self.vwSub?.isHidden = true
            
            // Generate filename
            let fileName = url?.lastPathComponent ?? "image_\(Int(Date().timeIntervalSince1970)).jpg"
            
            // Convert image to Base64
            if let base64String = self.convertImageToBase64String(img: image) {
                self.wsSendMesg(type: "Image",
                                file: base64String,
                                fileType: "image",
                                fileName: fileName)
            } else {
                print("❌ Failed to convert image to Base64")
            }
            
        } videoHandler: { videoURL in
            // 🎥 Handle video selection
            self.vwSub?.isHidden = true
            
            let fileName = videoURL.lastPathComponent
            print("📹 Video selected: \(fileName)")
            
            do {
                // Read video file data
                let videoData = try Data(contentsOf: videoURL)
                
                // Convert to Base64
                let base64String = videoData.base64EncodedString(options: .lineLength64Characters)
                
                // Send video as Base64
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
            dealListVC.objPushType = .GroupChat
            self.navigationController?.pushViewController(dealListVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickClose(_ sender: UIButton) {
        self.vwSub?.isHidden = true
    }
    
    @IBAction func btnOnClickAdd(_ sender: UIButton) {
        self.vwSub?.isHidden = false
    }
    
    @IBAction func btnOnClickSend(_ sender: UIButton) {
        guard let text = self.txtMesg?.text, !text.isEmpty else { return }
        
        // Prepare message for socket
        let objMessage = MessageModel(type: "Text", text: text)
        //let objMessage = MessageModel(type: "Property", property: "ID pass karva nu")
        
        // Append locally for instant UI
        self.scrollToBottom(animated: true)
        
        self.txtMesg?.text = ""
        txtHeight.constant = 40
        // Send via socket
        SocketService.shared?.sendChatMessage(chatId: self.objChat?.id, message: objMessage)
        
    }
    
    @IBAction func btnOnClickInfo(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        if let createNewGroupVC = storyboard.instantiateViewController(withIdentifier: "CreateNewGroupVC") as? CreateNewGroupVC {
            createNewGroupVC.isFromUpdate = true
            createNewGroupVC.objChat = self.objChat
            self.navigationController?.pushViewController(createNewGroupVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnOnClickProfile(_ sender: UIButton) {
        
    }
}

// MARK: - UI helpers
fileprivate extension GroupChatDetailVC {
    func InitConfig() {
        self.txtMesg?.delegate = self
        txtHeight.constant = 40
        txtMesg?.isScrollEnabled = false
        self.tblChat?.separatorStyle = .none
        self.tblChat?.delegate = self
        self.tblChat?.dataSource = self
        self.tblChat?.register(UINib(nibName: "ChatTVCell", bundle: nil), forCellReuseIdentifier: "ChatTVCell")
        self.vwText?.layer.cornerRadius = 22.0
        self.vwText?.layer.masksToBounds = true
        self.configureRefreshControl()
        self.socketHandlers()
        self.btnProfile?.setRound()
        if self.isFromPush == true {
            let objMessage = MessageModel(type: "Property", property: objProperty?.id)
            SocketService.shared?.sendChatMessage(chatId: self.objChat?.id, message: objMessage)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.openGroupController(_:)), name: NSNotification.Name(rawValue: "openController"), object: nil)
    }
    
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint?.constant = keyboardHeight
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.scrollToBottom(animated: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
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
extension GroupChatDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let page = pageInfo else { return }
        
        if page.hasNextPage && indexPath.section == 0 && indexPath.row == 0 && !isLoadingMessages {
            
            let previousHeight = tableView.contentSize.height
            wsGetGroupChat(showLoader: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let newHeight = tableView.contentSize.height
                tableView.setContentOffset(CGPoint(x: 0, y: newHeight - previousHeight), animated: false)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTVCell", for: indexPath) as? ChatTVCell else {
            return UITableViewCell()
        }
        guard sections.indices.contains(indexPath.section),
              sections[indexPath.section].messages.indices.contains(indexPath.row) else {
            return UITableViewCell()
        }
        let msg = sections[indexPath.section].messages[indexPath.row]
        cell.configure(with: msg)
        cell.lblRightReciverMesgName.isHidden = true
        cell.lblRightImageReceiverName.isHidden = true
        cell.lblRightVideoUploadName.isHidden = true
        cell.lblRightSendFileName.isHidden = true
        cell.lblRightReceiverPropertyName.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objChat = sections[indexPath.section].messages[indexPath.row]
        if objChat.type == "Image" {
            let customVC = ImagePreviewVC()
            customVC.isFromHide = true
            customVC.strImage = objChat.file ?? ""
            self.navigationController?.pushViewController(customVC, animated: true)
        } else if objChat.type == "File" {
            if let url = URL(string: objChat.file ?? ""){
                openPDF(url: url)
            }
        } else if objChat.type == "Property" {
            if let property = objChat.property {
                navigateToDetail(for: property)
            } else {
                print("No property found")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .clear
        
        let label = UILabel()
        label.text = sections[section].date.localized
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .black
        label.backgroundColor = UIColor(white: 0.90, alpha: 1)
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 28),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 140)
        ])
        
        return container
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func navigateToDetail(for property: ChatProperty) {
        let detailVC = ListingDetailVC()
        detailVC.isFromPush = true
        detailVC.strProperty = property.id ?? ""
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Document Picker
extension GroupChatDetailVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        vwSub?.isHidden = true
        let fileName = fileURL.lastPathComponent
        if let base64String = convertFileToBase64String(fileURL: fileURL) {
            wsSendMesg(type: "File", file: base64String, fileType: "pdf", fileName: fileName)
        }
    }
}

// MARK: - Web Service Calls
fileprivate extension GroupChatDetailVC {
    
    @objc func openGroupController(_ notification: Notification){
        if let chat = notification.userInfo?["content"] as? ChatMessage {
            self.objChat = chat
            pageInfo = nil
            wsGetGroupChat()
        }
    }
    
    func socketHandlers(){
        guard let chatID = objChat?.id else { return }
        
        SocketService.shared?.socket.on("chat/\(chatID)") { [weak self] _,_ in
            guard let self = self else { return }
            
            self.pageInfo = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.wsGetGroupChat(showLoader: false)
            }
            
            if let table = self.tblChat {
                let isAtBottom = table.contentOffset.y >= table.contentSize.height - table.frame.height - 50
                if isAtBottom { self.scrollToBottom(animated: true) }
            }
            
        }
    }
    
    func wsGetGroupDetails() {
        Utility.showLoading()
        WebServices.Get(url: "\(WebService.CHATS)\(objChat?.id ?? "")/", type: ChatMessage.self) { response in
            Utility.hideLoading()
            if let page = response {
                self.objChat = page
                self.lblTotalGroupMember?.text = "مجموعة من \(page.totalPeoples ?? 0) شخص"
                self.lblName?.text = self.objChat?.groupName
                if let avatar = self.objChat?.groupImage,
                   let url = URL(string: avatar),
                   !avatar.isEmpty {
                    self.btnProfile?.sd_setImage(with: url, for: .normal, placeholderImage: UIImage(named: "icn_contact_placeholder"))
                } else {
                    self.btnProfile?.setImage(UIImage(named: "icn_contact_placeholder"), for: .normal)
                }
                if self.objChat?.isModerator == true || self.self.objChat?.isAdmin == true {
                    self.vwBottomMessage?.isHidden = false
                } else {
                    self.vwBottomMessage?.isHidden = true
                }
                //                self.vwBottomMessage?.isHidden = self.objChat?.isMember == true
            }
        }
    }
    
    func buildSectionsFromMessages() {
        
        let sortedMessages = arrChat.sorted {
            ($0.createdAtDate ?? .distantPast) < ($1.createdAtDate ?? .distantPast)
        }
        
        var grouped: [ChatSection] = []
        
        for message in sortedMessages {
            let header = formattedDate(message.createdAt ?? "")
            
            if let index = grouped.firstIndex(where: { $0.date == header }) {
                grouped[index].messages.append(message)
            } else {
                grouped.append(ChatSection(date: header, messages: [message]))
            }
        }
        
        sections = grouped
        
        DispatchQueue.main.async {
            self.tblChat?.reloadData()
            self.tblChat?.layoutIfNeeded()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.scrollToBottom(animated: false)
            }
        }
    }
    
    
    func wsGetGroupChat(showLoader:Bool = true) {
        // ❌ If already loading → exit
        if isLoadingMessages { return }
        isLoadingMessages = true
        
        if showLoader { Utility.showLoading() }
        
        let nextPage = (pageInfo?.page ?? 0) + 1
        WebServices.Get(url: "\(WebService.CHATS)\(objChat?.id ?? "")/messages/?page=\((pageInfo?.page ?? 0) + 1)&size=20", type: ChatMessagesResponse.self) { response in
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
    
    func wsSendMesg(type: String, file: String, fileType: String, fileName: String) {
        Utility.showLoading()
        let params: [String: Any] = [
            PARAMS.TYPE: type,
            PARAMS.FILE: file,
            PARAMS.FILE_TYPE: fileType,
            PARAMS.FILE_NAME: fileName
        ]
        let url = "\(WebService.CHATS)\(objChat?.id ?? "")/message/"
        WebServices.Post(url: url, params: params, type: DealContent.self) { [weak self] _ in
            Utility.hideLoading()
        }
    }
    
    func formattedDate(_ isoString: String) -> String {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: isoString) else { return "" }
        
        // Today / Yesterday logic
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "dd/MM/yyyy"
        
        return df.string(from: date)
    }
    
}

extension GroupChatDetailVC: UITextViewDelegate {
    
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
