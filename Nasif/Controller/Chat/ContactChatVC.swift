//
//  ContactChatVC.swift
//  Nasif
//
//  Created by Denish Gediya on 07/10/25.
//

import UIKit
import Contacts
import libPhoneNumber
import CoreTelephony
import Alamofire

class ContactChatVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tblContact: UITableView?
    @IBOutlet weak var vwSearch: UIView?
    @IBOutlet weak var txtSearch: UITextField?
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - Variables
    var arrNumber: [UserContact] = []
    var sections: [Section] = []
    var allSections: [Section] = []
    var selectedIDs: Set<String> = []
    var selectedContacts: [UserContact] = []
    var onDismiss: ((_ objChat: ChatMessage?) -> Void)?
    var onNormalDismiss: (() -> Void)?
    let topMenuTitles = ["Create a new group", "New conversation with an unregistered number"]
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        InitConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.wsGetCheckNumbers()
    }
}

// MARK: - IBAction
extension ContactChatVC {
    @IBAction func btnOnClickCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnOnClickAdd(_ sender: UIButton) {
        let ids = Array(selectedIDs)
        guard !ids.isEmpty else {
            Utility.showToast(message: "Please select contact".localized)
            return
        }
        self.wsAddChat(members: ids)
    }
}

// MARK: - UI Setup
fileprivate extension ContactChatVC {
    
    func InitConfig() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        tblContact?.delegate = self
        tblContact?.dataSource = self
        tblContact?.separatorStyle = .none
        tblContact?.backgroundColor = .clear
        
        tblContact?.register(UINib(nibName: "ContactTVCell", bundle: nil),
                             forCellReuseIdentifier: "ContactTVCell")
        
        vwSearch?.layer.cornerRadius = 22
        vwSearch?.clipsToBounds = true
        
        txtSearch?.delegate = self
        txtSearch?.addTarget(self, action: #selector(searchTextChanged),
                             for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if #available(iOS 15.0, *) {
            tblContact?.sectionHeaderTopPadding = 0
        }
        
        setupLocalized()
    }
    
    func setupLocalized() {
        lblTitle.text = "Start a new chat".localized
        btnAdd?.setTitle("Add".localized, for: .normal)
    }
    
    @objc private func searchTextChanged() {
        guard let text = txtSearch?.text, !text.isEmpty else {
            sections = allSections
            tblContact?.reloadData()
            return
        }
        
        var filtered: [Section] = []
        for s in allSections {
            let filteredContacts = s.contacts.filter {
                $0.name?.lowercased().contains(text.lowercased()) ?? false
            }
            if !filteredContacts.isEmpty {
                filtered.append(Section(title: s.title, contacts: filteredContacts))
            }
        }
        sections = filtered
        tblContact?.reloadData()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Fetch Contacts
fileprivate extension ContactChatVC {
    
    func removeDuplicateContacts(_ contacts: [(name: String, phoneNumber: String)])
    -> [(name: String, phoneNumber: String)] {
        
        var unique: [(name: String, phoneNumber: String)] = []
        var seen = Set<String>()
        
        for contact in contacts {
            if !seen.contains(contact.phoneNumber) {
                seen.insert(contact.phoneNumber)
                unique.append(contact)
            }
        }
        return unique
    }
    
    func fetchContacts() -> [(name: String, phoneNumber: String)] {
        var contactList = [(String, String)]()
        
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactPhoneNumbersKey]
        
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                let fullName = "\(contact.givenName) \(contact.familyName)"
                    .trimmingCharacters(in: .whitespaces)
                
                for number in contact.phoneNumbers {
                    let cleaned = sanitizePhoneNumber(number.value.stringValue)
                    contactList.append((fullName, cleaned))
                }
            }
        } catch {
            print("Contact fetch failed → \(error)")
        }
        
        let uniqueContacts = removeDuplicateContacts(contactList)
        return uniqueContacts
    }
    
    
    func sanitizePhoneNumber(_ number: String) -> String {
        let digits = number.replacingOccurrences(of: "\\D",
                                                 with: "",
                                                 options: .regularExpression)
        return String(digits.suffix(9))
    }
}

// MARK: - FULL TABLEVIEW
extension ContactChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + 1         // +1 for top menu
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 { return topMenuTitles.count }
        return sections[section - 1].contacts.count
    }
    
    // MARK: - CELL
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 🔥 FIRST STATIC SECTION → USE SAME ContactTVCell
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ContactTVCell",
                for: indexPath
            ) as? ContactTVCell else { return UITableViewCell() }
            
            let total = topMenuTitles.count
            
            // 🔥 SAME UI LIKE YOUR SCREENSHOT
            if indexPath.row == 0 {
                // FIRST ROW → top corners rounded
                cell.vwMain?.layer.cornerRadius = 14
                cell.vwMain?.layer.maskedCorners = [
                    .layerMinXMinYCorner, .layerMaxXMinYCorner
                ]
                cell.lblBottom?.isHidden = false          // show separator for row 0
                cell.imgContact?.image = UIImage(named: "icn_add_group")
                
            }
            else if indexPath.row == total - 1 {
                // LAST ROW → bottom corners rounded
                cell.vwMain?.layer.cornerRadius = 14
                cell.vwMain?.layer.maskedCorners = [
                    .layerMinXMaxYCorner, .layerMaxXMaxYCorner
                ]
                cell.lblBottom?.isHidden = true           // bottom row → no line
                cell.imgContact?.image = UIImage(named: "icn_add_new_chat")
            }
            else {
                // (No middle rows here, but safe)
                cell.vwMain?.layer.cornerRadius = 0
                cell.vwMain?.layer.maskedCorners = []
                cell.lblBottom?.isHidden = false
            }
            
            // TEXT
            cell.lblName?.text = topMenuTitles[indexPath.row].localized
            cell.lblName?.textColor = UIColor.themePrimaryColor
            
            // HIDE Buttons
            cell.vwInvite?.isHidden = true
            cell.btnInvite?.isHidden = true
            cell.vwCheck?.isHidden = true
            cell.btnCheck?.isHidden = true
            
            return cell
        }
        
        // MARK: NORMAL CONTACT CELLS
        let realSection = indexPath.section - 1
        let contact = sections[realSection].contacts[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContactTVCell",
            for: indexPath
        ) as? ContactTVCell else { return UITableViewCell() }
        
        let total = tableView.numberOfRows(inSection: indexPath.section)
        cell.imgContact?.image = UIImage(named: "icn_contact_placeholder")
        if total == 1 {
            cell.vwMain?.layer.cornerRadius = 14
            cell.vwMain?.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            cell.lblBottom?.isHidden = true
        }
        else if indexPath.row == 0 {
            cell.vwMain?.layer.cornerRadius = 14
            cell.vwMain?.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
            cell.lblBottom?.isHidden = false
        }
        else if indexPath.row == total - 1 {
            cell.vwMain?.layer.cornerRadius = 14
            cell.vwMain?.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            cell.lblBottom?.isHidden = true
        }
        else {
            cell.vwMain?.layer.cornerRadius = 0
            cell.vwMain?.layer.maskedCorners = []
            cell.lblBottom?.isHidden = false
        }
        
        cell.lblName?.text = contact.name ?? "-"
        cell.lblName?.textColor = UIColor.themeButton636363
        
        let isRegistered = !(contact.id ?? "").isEmpty
        
        cell.vwInvite?.isHidden = isRegistered
        cell.btnInvite?.isHidden = isRegistered
        
        cell.vwCheck?.isHidden = !isRegistered
        cell.btnCheck?.isHidden = !isRegistered
        
        cell.btnInvite?.tag = (indexPath.section << 16) | indexPath.row
        cell.btnCheck?.tag  = (indexPath.section << 16) | indexPath.row
        
        cell.btnInvite?.addTarget(self, action: #selector(didTapInvite(_:)), for: .touchUpInside)
        cell.btnCheck?.addTarget(self, action: #selector(didTapCheck(_:)), for: .touchUpInside)
        
        if let id = contact.id {
            cell.btnCheck?.isSelected = selectedIDs.contains(id)
        }
        return cell
    }
    
    // MARK: - TAP ON ROW
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.dismiss(animated: true) {
                    self.onNormalDismiss?()
                }
                return
            }
            if indexPath.row == 1 {
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "NotRegisterVC") as? NotRegisterVC {
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.delegate = self
                    self.present(vc, animated: true)
                }
            }
            return
        }
        let realSection = indexPath.section - 1
        guard realSection >= 0, realSection < sections.count else {
            print("❌ Invalid section index")
            return
        }
        let contacts = sections[realSection].contacts
        guard indexPath.row < contacts.count else {
            print("❌ Invalid row index")
            return
        }
        let contact = contacts[indexPath.row]
        guard let id = contact.id, !id.isEmpty else {
            Utility.showToast(message: "Please invite this contact".localized)
            return
        }
        toggleSelection(at: IndexPath(row: indexPath.row, section: realSection))
    }
    
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    // MARK: HEADER
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 { return UIView() }  // no header for top menu
        
        let title = sections[section - 1].title
        
        let container = UIView()
        container.backgroundColor = .clear
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .right
        label.textColor = UIColor.theme999999
        
        container.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 12 : 32
    }
}

// MARK: - Selection Logic
fileprivate extension ContactChatVC {
    
    @objc func didTapCheck(_ sender: UIButton) {
        let sec = sender.tag >> 16
        let row = sender.tag & 0xFFFF
        toggleSelection(at: IndexPath(row: row, section: sec - 1))
    }
    
    
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
    
    func generateInviteMessage(for mobile: String) -> String {
        let link = "https://bit.ly/4ocU30K"
        
        return """
        مرحبا ✨
        
        أنا أستخدم تطبيق نصيف
        للتواصل العقاري وإدارة الصفقات. 
        
        حمّل التطبيق وراسلني هناك …
        
        \(link) 🔗
        
        """
    }
    
    func findOriginalContactNumber(serverNumber: String) -> String {
        let cleanServer = serverNumber.replacingOccurrences(of: "\\D",
                                                            with: "",
                                                            options: .regularExpression)
        
        let last9Server = String(cleanServer.suffix(9))
        
        let contactStore = CNContactStore()
        let keys = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        var matchedNumber: String?
        
        do {
            try contactStore.enumerateContacts(with: request) { contact, _ in
                for num in contact.phoneNumbers {
                    
                    let raw = num.value.stringValue
                    let clean = raw.replacingOccurrences(of: "\\D",
                                                         with: "",
                                                         options: .regularExpression)
                    
                    let last9 = String(clean.suffix(9))
                    
                    if last9 == last9Server {
                        matchedNumber = clean   // <- full clean original number
                        return
                    }
                }
            }
        } catch {
            print("Error reading contacts:", error)
        }
        
        return matchedNumber ?? serverNumber
    }
    
    @objc private func didTapInvite(_ sender: UIButton) {
        let section = sender.tag >> 16
        let row = sender.tag & 0xFFFF
        
        guard section > 0 else { return }
        let real = section - 1
        let contact = sections[real].contacts[row]
        
        let serverMobile = contact.mobile ?? ""
        
        // 🔥 FIND REAL ORIGINAL NUMBER FROM CONTACT LIST
        let finalNumber = findOriginalContactNumber(serverNumber: serverMobile)
        
        let inviteMessage = generateInviteMessage(for: finalNumber)
        
        openWhatsAppInvite(to: finalNumber, message: inviteMessage)
    }
    
    func toggleSelection(at indexPath: IndexPath) {
        let contact = sections[indexPath.section].contacts[indexPath.row]
        guard let id = contact.id else { return }
        
        if selectedIDs.contains(id) {
            selectedIDs.removeAll()
            selectedContacts.removeAll()
        } else {
            selectedIDs.removeAll()
            selectedContacts.removeAll()
            selectedIDs.insert(id)
            selectedContacts.append(contact)
        }
        
        tblContact?.reloadData()
    }
}

// MARK: - API CALLS
fileprivate extension ContactChatVC {
    
    private func wsGetCheckNumbers() {
        Utility.showLoading()
        
        DispatchQueue.global().async {
            let contacts = self.fetchContacts()
            let list = contacts.map { ["name": $0.name, "mobile": $0.phoneNumber] }
            
            let param = ["contacts": list]
            
            DispatchQueue.main.async {
                self.sendContactsToServer(dictParam: param)
            }
        }
    }
    
    private func sendContactsToServer(dictParam: [String: Any]) {
        WebServices.Post(url: WebService.CONTACTS,
                         params: dictParam,
                         type: [UserContact].self) { [weak self] response in
            
            Utility.hideLoading()
            guard let self else { return }
            guard let data = response else { return }
            
            self.arrNumber = data
            self.groupContactsAndReload()
        }
    }
    
    private func groupContactsAndReload() {
        
        let registered = arrNumber.filter { !($0.id ?? "").isEmpty }
        var unregistered = arrNumber.filter { ($0.id ?? "").isEmpty }
        
        // MARK: First Character Extractor
        func firstCharacter(_ text: String?) -> String {
            guard let name = text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else { return "#" }
            
            let first = name.prefix(1).uppercased()
            
            let arabicRegex = "^[ء-ي]$"
            let englishRegex = "^[A-Z]$"
            
            if first.range(of: arabicRegex, options: .regularExpression) != nil {
                return first
            }
            if first.range(of: englishRegex, options: .regularExpression) != nil {
                return first
            }
            return "#"
        }
        
        // MARK: Group REGISTERED users
        let grouped = Dictionary(grouping: registered) { contact in
            firstCharacter(contact.name)
        }
        
        let sortedKeys = grouped.keys.sorted { a, b in
            if a == "#" { return false }
            if b == "#" { return true }
            return a.localizedStandardCompare(b) == .orderedAscending
        }
        
        var newSections: [Section] = sortedKeys.map {
            Section(title: $0, contacts: grouped[$0]!)
        }
        
        // MARK: SORT NON-REGISTERED USERS ALPHABETICALLY
        unregistered.sort { ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
        
        if !unregistered.isEmpty {
            newSections.append(
                Section(title: "Contacts without account".localized,
                        contacts: unregistered)
            )
        }
        
        self.sections = newSections
        self.allSections = newSections
        
        DispatchQueue.main.async {
            self.tblContact?.reloadData()
        }
    }
    
    func wsAddChat(members: [String]) {
        Utility.showLoading()
        let params = [PARAMS.MEMBERS: members]
        
        WebServices.Post(url: WebService.CHATS,
                         params: params,
                         type: ChatMessage.self) { [weak self] response in
            
            Utility.hideLoading()
            guard let self else { return }
            guard let res = response else { return }
            
            Utility.showToast(message: "Chat created".localized)
            self.onDismiss?(res)
            self.dismiss(animated: true)
        }
    }
}

extension ContactChatVC : NotRegisterDelegate {
    func addChat(mobile: String) {
        Utility.showLoading()
        var params: [String: Any] = [:]
        params[PARAMS.CONTACTS] = mobile
        let url = "\(WebService.CHATS)"
        WebServices.Post(url: url, params: params, type: ChatMessage.self) { [weak self] response in
            Utility.hideLoading()
            guard let self else { return }
            guard let res = response else { return }
            self.onDismiss?(res)
            self.dismiss(animated: true)
        }
    }
}
