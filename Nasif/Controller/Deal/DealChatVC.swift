//
//  DealChatVC.swift
//  Nasif
//
//  Created by Denish Gediya on 31/07/25.
//
import UIKit
import IQKeyboardManagerSwift
import UniformTypeIdentifiers
import SocketIO

class DealChatVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lblDealNumber: UILabel!
    @IBOutlet weak var lblEmptyChat: UILabel!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var vwChatText: UIView!
    @IBOutlet weak var txtChat: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var vwSub: UIView?
    @IBOutlet weak var vwMainChat: UIView?
    @IBOutlet weak var vwLabel: UIView?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblSubTitle: UILabel?
    @IBOutlet weak var img: UIImageView?
    @IBOutlet weak var lblPrice: UILabel?
    @IBOutlet weak var vwMain: UIView?
    
    @IBOutlet weak var vwImg: UIView!
    @IBOutlet weak var vwStatus: UIView!
    @IBOutlet weak var vwsubListMain: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    //    @IBOutlet weak var vwSubMenu: UIView?
    //    @IBOutlet weak var vwMainSquare: UIView!
    
    @IBOutlet weak var vw1: UIView!
    @IBOutlet weak var vw2: UIView!
    @IBOutlet weak var vw3: UIView!
    @IBOutlet weak var vw4: UIView!
    @IBOutlet weak var vw5: UIView!
    
    @IBOutlet private weak var lblSquare: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    
    @IBOutlet var vwSubmenu: [UIView]!
    
    // MARK: - Variables
    var objDeal: Deal?
    private let imagePicker = ImagePicker()
    private var arrChat: [DealContent] = []
    private var pageInfo: DealChatModel?
    private let refreshControl = UIRefreshControl()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        InitConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        pageInfo = nil
        wsGetChat()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.isEnabled = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func btnOnClickAddName(_ sender: UIButton) {
        if objDeal?.user?.id == UserDefaultsHelper.getUserFromDefaults()?.userId {
            self.showAlert()
        }
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
                // ✅ Call API and dismiss alert
                self.wsDealUpdate(name: text)
            } else {
                // ❌ Prevent dismiss by re-presenting the same alert
                self.present(alert, animated: true) {
                    Utility.showToast(message: "Please enter name".localized)
                }
            }
        }
        okAction.isEnabled = false   // disable initially
        alert.addAction(okAction)
        
        // Add Cancel button (this will dismiss normally)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Enable OK only when text is entered
        if let textField = alert.textFields?.first {
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { _ in
                let text = textField.text ?? ""
                okAction.isEnabled = !text.isEmpty
            }
        }
        
        // Present alert
        present(alert, animated: true)
    }
}

// MARK: - IBAction Methods
extension DealChatVC {
    @IBAction func btnOnClickDealDetail(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Deal", bundle: nil)
        if let dealDetailVC = storyboard.instantiateViewController(withIdentifier: "DealDetailVC") as? DealDetailVC {
            dealDetailVC.objDeal = self.objDeal
            navigationController?.pushViewController(dealDetailVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnOnClickFiles(_ sender: UIButton) {
        self.view.endEditing(true)
        self.vwSub?.isHidden = false
    }
    
    @IBAction func btnOnClickSent(_ sender: UIButton) {
        guard let text = self.txtChat.text, !text.isEmpty else { return }
        
        // Prepare message for socket
        let objMessage = MessageModel(type: "Text", text: text)
        
        // Append locally for instant UI
        if let dealId = objDeal?.id {
            let nowString = ISO8601DateFormatter().string(from: Date())
            
            // Use current user info as sender
            let currentSender = Sender(id: "local_user_id", mobile: "0000000000", displayName: "Me", avatar: nil)
            
            let localMessage = DealContent(
                deal: dealId,
                createdAt: nowString,
                sender: currentSender,
                id: UUID().uuidString,
                type: "Text",
                text: text,
                fileName: nil,
                file: nil,
                fileType: nil
            )
            
            self.arrChat.append(localMessage)
            self.tblChat.reloadData()
            self.scrollToBottom(animated: true)
        }
        
        self.txtChat.text = ""
        
        // Send via socket
        SocketService.shared?.sendDealMessage(dealId: self.objDeal?.id, message: objMessage)
    }
    
    @IBAction func btnOnClickClose(_ sender: UIButton) {
        self.view.endEditing(true)
        self.vwSub?.isHidden = true
    }
    
    @IBAction func btnOnClickImage(_ sender: UIButton) {
        self.view.endEditing(true)
        imagePicker.pickImage(self, "", type: .single, allowVideo: false) { image, url in
            self.vwSub?.isHidden = true
            let fileName = url?.lastPathComponent ?? "image_\(Int(Date().timeIntervalSince1970)).jpg"
            self.wsSendMesg(type: "Image", file: convertImageToBase64String(img: image), fileType: "image", fileName: fileName)
        }
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
}

// MARK: - UI Helpers
fileprivate extension DealChatVC {
    func InitConfig() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
        
        self.vwSubmenu?.forEach({
            $0.layer.cornerRadius = 20.0
            $0.clipsToBounds = true
        })
        [vw1, vw2, vw3, vw4, vw5].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }
        
        vw1.backgroundColor = UIColor.themeD9D9D9
        vw2.backgroundColor = UIColor.themeD9D9D9
        vw3.backgroundColor = UIColor.themeD9D9D9
        vw4.backgroundColor = UIColor.themeD9D9D9
        vw5.backgroundColor = UIColor.themeD9D9D9
        
        tblChat?.separatorStyle = .none
        tblChat?.delegate = self
        tblChat?.dataSource = self
        tblChat?.register(UINib(nibName: "ChatDealTVCell", bundle: nil), forCellReuseIdentifier: "ChatDealTVCell")
        tblChat?.transform = CGAffineTransform(scaleX: 1, y: -1)
        tblChat?.refreshControl = refreshControl
        
        vwChatText.layer.cornerRadius = 22.0
        vwChatText.layer.masksToBounds = true
        bottomConstraint.constant = 0
        
        vwMainChat?.isHidden = objDeal?.isExit == true
        vwLabel?.isHidden = objDeal?.isExit != true
        
        vwMain?.layer.cornerRadius = 10
        vwMain?.layer.masksToBounds = true
        
        vwStatus.layer.cornerRadius = 10
        vwStatus.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        img?.layer.cornerRadius = 10
        img?.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                    .layerMaxXMaxYCorner]   // bottom-right
        img?.layer.masksToBounds = true
        
        vwsubListMain.layer.cornerRadius = 10.0
        vwsubListMain.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        vwsubListMain.layer.masksToBounds = true
        
        vwsubListMain.layer.borderColor = UIColor.black.cgColor
        vwsubListMain.layer.borderWidth = 1.0
        
        vwImg.layer.cornerRadius = 10
        vwImg.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        vwImg.layer.masksToBounds = true
        vwImg.layer.borderWidth = 1.5
        vwImg.layer.borderColor = UIColor.theme999999.cgColor
        
        
        if  objDeal?.name == "" || objDeal?.name == nil {
            lblDealNumber.text = "\("Deal No .".localized) \(objDeal?.dealNo ?? 0)"
        } else {
            lblDealNumber.text = objDeal?.name
        }
        
        if let type = objDeal?.property?.type?.localized {
            if objDeal?.property?.availableFor == "Sale" {
                self.lblTitle?.text = "\(type) للبيع"
            } else {
                self.lblTitle?.text = "\(type) للإيجار"
            }
        } else {
            self.lblTitle?.text = objDeal?.property?.type?.localized ?? "N/A"
        }
        
        lblSubTitle?.text = objDeal?.property?.city
        
        lblPrice?.text = formatPriceNew("\(objDeal?.property?.price ?? 0)")
        lblSquare?.text = "\(objDeal?.property?.area ?? 0)"
        if objDeal?.property?.type == "Land" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if objDeal?.property?.type == "Villa" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
            if objDeal?.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(objDeal?.property?.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
        } else if objDeal?.property?.type == "Apartment" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = false
            self.vw5.isHidden = true
            if objDeal?.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(objDeal?.property?.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
            if objDeal?.property?.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(objDeal?.property?.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if objDeal?.property?.type == "Floor" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw5.isHidden = true
            if objDeal?.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(objDeal?.property?.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
            if objDeal?.property?.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(objDeal?.property?.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if objDeal?.property?.type == "Building Complex" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if objDeal?.property?.type == "Chalet" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if objDeal?.property?.type == "Farm" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if objDeal?.property?.type == "Other" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        }
        
        if let url = URL(string: objDeal?.property?.coverImage ?? "") {
            img?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_new_placeholder"))
        }
        
        self.wsGetDeals()
        self.configureRefreshControl()
        self.socketHandlers()
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.scrollToBottom(animated: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollToBottom(animated: Bool) {
        DispatchQueue.main.async {
            guard self.arrChat.count > 0 else { return }
            let indexPath = IndexPath(row: 0, section: 0) // top row in inverted table
            self.tblChat.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
}

// MARK: - Refresh
private extension DealChatVC {
    @objc func refreshData() {
        self.pageInfo = nil
        self.wsGetChat()
    }
}

// MARK: - TableView Delegate & DataSource
extension DealChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrChat.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let page = self.pageInfo, page.hasNextPage, indexPath.row == self.arrChat.count - 1 {
            self.wsGetChat()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDealTVCell", for: indexPath) as? ChatDealTVCell else {
            return UITableViewCell()
        }
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.configure(with: arrChat[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objChat = arrChat[indexPath.row]
        if objChat.type == "Image" {
            let customVC = ImagePreviewVC()
            customVC.isFromHide = true
            customVC.strImage = objChat.file ?? ""
            self.navigationController?.pushViewController(customVC, animated: true)
        } else if objChat.type == "File" {
            if let url = URL(string: objChat.file ?? ""){
                openPDF(url: url)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - Document Picker
extension DealChatVC: UIDocumentPickerDelegate {
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
fileprivate extension DealChatVC {
    
    func socketHandlers(){
        guard let dealId = objDeal?.id else { return }
        let eventName = "deal/\(dealId)"
        
        SocketService.shared?.socket.on(eventName) { (data, ack) in
            self.pageInfo = nil
            self.wsGetChat(showLoader: false)
        }
    }
    
    func wsGetChat(showLoader:Bool = true) {
        if showLoader {
            Utility.showLoading()
        }
        WebServices.Get(url: "\(WebService.DEALS)\(objDeal?.id ?? "")/messages/?page=\((pageInfo?.page ?? 0) + 1)&size=20", type: DealChatModel.self) { response in
            Utility.hideLoading()
            self.refreshControl.endRefreshing()
            if let page = response {
                if self.pageInfo == nil || page.totalPages == 1{
                    self.arrChat = Array(page.content)
                }else{
                    self.arrChat.append(contentsOf: page.content)
                }
                self.pageInfo = page
                self.tblChat.reloadData()
            }
        }
    }
    
    func wsGetDeals() {
        guard let dealID = objDeal?.id else { return }
        WebServices.Get(url: "\(WebService.DEALS)\(dealID)/", type: Deal.self) { [weak self] response in
            guard let self = self, let response = response else { return }
            DispatchQueue.main.async {
                self.objDeal = response
                self.lblStatus?.text = response.property?.status?.localized
                if response.property?.status == "Available" {
                    self.vwStatus.backgroundColor = UIColor.themeBackgroundGreenColor
                } else if response.property?.status == "Reserved" {
                    self.vwStatus.backgroundColor = UIColor.themePurpor
                }  else {
                    self.vwStatus.backgroundColor = UIColor.themeBackgroundRedColor
                }
                if response.property?.type == "Land" {
                    self.vw1.isHidden = false
                    self.vw2.isHidden = true
                    self.vw3.isHidden = true
                    self.vw4.isHidden = true
                    self.vw5.isHidden = true
                } else if response.property?.type == "Villa" {
                    self.vw1.isHidden = false
                    self.vw2.isHidden = true
                    self.vw4.isHidden = true
                    self.vw5.isHidden = true
                    if response.property?.totalBedrooms != 0 {
                        self.vw3.isHidden = false
                        self.lbl3.text = "\(response.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vw3.isHidden = true
                    }
                } else if response.property?.type == "Apartment" {
                    self.vw1.isHidden = false
                    self.vw2.isHidden = true
                    self.vw4.isHidden = false
                    self.vw5.isHidden = true
                    if response.property?.totalBedrooms != 0 {
                        self.vw3.isHidden = false
                        self.lbl3.text = "\(response.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vw3.isHidden = true
                    }
                    if response.property?.totalBathrooms != 0 {
                        self.vw4.isHidden = false
                        self.lbl4.text = "\(response.property?.totalBathrooms ?? 0)"
                    } else {
                        self.vw4.isHidden = true
                    }
                } else if response.property?.type == "Floor" {
                    self.vw1.isHidden = false
                    self.vw2.isHidden = true
                    self.vw5.isHidden = true
                    if response.property?.totalBedrooms != 0 {
                        self.vw3.isHidden = false
                        self.lbl3.text = "\(response.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vw3.isHidden = true
                    }
                    if response.property?.totalBathrooms != 0 {
                        self.vw4.isHidden = false
                        self.lbl4.text = "\(response.property?.totalBathrooms ?? 0)"
                    } else {
                        self.vw4.isHidden = true
                    }
                } else if response.property?.type == "Building Complex" {
                    self.vw1.isHidden = false
                    self.vw2.isHidden = true
                    self.vw3.isHidden = true
                    self.vw4.isHidden = true
                    self.vw5.isHidden = true
                } else if response.property?.type == "Chalet" {
                    self.vw1.isHidden = false
                    self.vw2.isHidden = true
                    self.vw3.isHidden = true
                    self.vw4.isHidden = true
                    self.vw5.isHidden = true
                } else if response.property?.type == "Farm" {
                    self.vw1.isHidden = false
                    self.vw2.isHidden = true
                    self.vw3.isHidden = true
                    self.vw4.isHidden = true
                    self.vw5.isHidden = true
                } else if response.property?.type == "Other" {
                    self.vw1.isHidden = false
                    self.vw2.isHidden = true
                    self.vw3.isHidden = true
                    self.vw4.isHidden = true
                    self.vw5.isHidden = true
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
        let url = "\(WebService.DEALS)\(objDeal?.id ?? "")/message/"
        WebServices.Post(url: url, params: params, type: DealContent.self) { [weak self] _ in
            Utility.hideLoading()
        }
    }
    
    func wsDealUpdate(name: String) {
        guard let dealID = objDeal?.id else { return }
        Utility.showLoading()
        let params: [String: Any] = [
            PARAMS.NAME: name
        ]
        
        Utility.showLoading()
        WebServices.Put(url: "\(WebService.DEALS)\(dealID)/", params: params, type: Deal.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            self.lblDealNumber.text = name
            Utility.showToast(message: "Deal name successfully change".localized)
            self.dismiss(animated: true)
        }
    }
}
