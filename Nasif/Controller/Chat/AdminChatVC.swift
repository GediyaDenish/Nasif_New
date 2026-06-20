//
//  AdminChatVC.swift
//  Nasif
//
//  Created by Denish Gediya on 25/11/25.
//

import UIKit
import Contacts
import libPhoneNumber
import CoreTelephony
import Alamofire

enum statusType {
    case Admin
    case Moderator
    case Member
}

class AdminChatVC: UIViewController, UITextFieldDelegate {
    
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
    var objStatus: statusType = .Admin
    var onDismissContacts: (([UserContact]) -> Void)?
    
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
extension AdminChatVC {
    @IBAction func btnOnClickCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnOnClickAdd(_ sender: UIButton) {
        guard !selectedContacts.isEmpty else {
            Utility.showToast(message: "Please select contact".localized)
            return
        }
        self.onDismissContacts?(selectedContacts)
        self.dismiss(animated: true)
    }
}

// MARK: - UI Setup
fileprivate extension AdminChatVC {
    
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
        switch objStatus {
        case .Admin: lblTitle.text = "Add Admin".localized
        case .Moderator: lblTitle.text = "Add Moderator".localized
        case .Member: lblTitle.text = "Add Member".localized
        }
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
fileprivate extension AdminChatVC {
    
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
extension AdminChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return sections[section].contacts.count
    }
    
    
    // MARK: - CELL
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realSection = indexPath.section
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
            cell.btnCheck?.isSelected = selectedIDs.contains(contact.id ?? "")
        }
        
        return cell
    }
    
    // MARK: - TAP ON ROW
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = sections[indexPath.section].contacts[indexPath.row]
        
        guard let id = contact.id, !id.isEmpty else {
            Utility.showToast(message: "Please invite this contact".localized)
            return
        }

        toggleSelection(at: indexPath)
    }

    
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    // MARK: HEADER
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let title = sections[section].title
        
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
        return 32
    }
}

// MARK: - Selection Logic
fileprivate extension AdminChatVC {
    
    @objc func didTapCheck(_ sender: UIButton) {
        let sec = sender.tag >> 16
        let row = sender.tag & 0xFFFF
        toggleSelection(at: IndexPath(row: row, section: sec))
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
        
        guard section >= 0, section < sections.count else { return }
        guard row >= 0, row < sections[section].contacts.count else { return }
        
        let contact = sections[section].contacts[row]
        
        let serverMobile = contact.mobile ?? ""
        let finalNumber = findOriginalContactNumber(serverNumber: serverMobile)
        
        let inviteMessage = generateInviteMessage(for: finalNumber)
        openWhatsAppInvite(to: finalNumber, message: inviteMessage)
    }
    
    func toggleSelection(at indexPath: IndexPath) {

        let contact = sections[indexPath.section].contacts[indexPath.row]
        guard let id = contact.id else { return }

        // Already selected → unselect
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
            selectedContacts.removeAll { $0.id == id }
        }
        // Not selected → add
        else {
            selectedIDs.insert(id)
            selectedContacts.append(contact)
        }

        tblContact?.reloadRows(at: [indexPath], with: .automatic)
    }

}

// MARK: - API CALLS
fileprivate extension AdminChatVC {
    
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
}
