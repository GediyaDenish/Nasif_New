//
//  ContactListVC.swift
//  Nasif
//
//  Created by Denish Gediya on 31/07/25.
//

import UIKit
import Contacts
import libPhoneNumber
import CoreTelephony
import Alamofire

class ContactListVC: UIViewController {
    
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
    var isFromDeal: Bool = false
    var onDismiss: ((_ objDeal: Deal?) -> Void)?
    private var selectedIDs = Set<String>()
    var selectSingle: String = ""
    var selectedIndexPath: IndexPath?
    var objProperty: Property?
    let topMenuTitles = ["إرسال لرقم غير مسجل"]
    
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
extension ContactListVC {
    @IBAction func btnOnClickCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnOnClickAdd(_ sender: UIButton) {
        if self.isFromDeal == true {
            
            // check row+section based selection
            guard let selectedIP = selectedIndexPath else {
                Utility.showToast(message: "Please select contact".localized)
                return
            }
            
            // selectSingle already contains the ID
            self.wsDeals(propertyId: self.objProperty?.id ?? "", buyerId: selectSingle)
            
        } else {
            
            let ids = Array(selectedIDs)
            guard !ids.isEmpty else {
                Utility.showToast(message: "Please select contact".localized)
                return
            }
            
            let stringIDs = ids.map { String($0) }
            self.wsPutShare(arrIDS: stringIDs)
        }
    }
}

// MARK: - UI helpers
fileprivate extension ContactListVC {
    func InitConfig() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.tblContact?.delegate = self
        self.tblContact?.dataSource = self
        self.tblContact?.register(UINib(nibName: "ContactTVCell", bundle: nil), forCellReuseIdentifier: "ContactTVCell")
        self.tblContact?.allowsSelection = true
        self.tblContact?.separatorStyle = .none
        self.tblContact?.backgroundColor = .clear
        self.vwSearch?.layer.cornerRadius = 22.0
        self.vwSearch?.layer.masksToBounds = true
        
        // Search text field setup
        self.txtSearch?.delegate = self
        self.txtSearch?.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        // Tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle?.text = "Sharing a listing".localized
        self.lblTitle?.textAlignment = .center
        self.btnAdd?.setTitle("Add".localized, for: .normal)
    }
    
    @objc private func searchTextChanged() {
        guard let text = txtSearch?.text, !text.isEmpty else {
            sections = allSections
            tblContact?.reloadData()
            return
        }
        
        var filteredSections: [Section] = []
        for section in allSections {
            let filteredContacts = section.contacts.filter { contact in
                (contact.name ?? "-").lowercased().contains(text.lowercased())
            }
            if !filteredContacts.isEmpty {
                filteredSections.append(Section(title: section.title, contacts: filteredContacts))
            }
        }
        sections = filteredSections
        tblContact?.reloadData()
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
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
        // keep last 9 digits (original logic). Adjust if you expect different behavior.
        return String(digits.suffix(9))
    }
}

// MARK: - TableView Delegate & DataSource
extension ContactListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return topMenuTitles.count }
        let real = section - 1
        guard real >= 0, real < sections.count else { return 0 }
        return sections[real].contacts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return nil }   // hide static section header
        let real = section - 1
        guard real >= 0, real < sections.count else { return nil }
        return sections[real].title
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // ---------- TOP STATIC SECTION ----------
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ContactTVCell",
                for: indexPath
            ) as? ContactTVCell else { return UITableViewCell() }
            
            // Defensive reset
            cell.vwMain?.layer.masksToBounds = true
            cell.vwMain?.layer.maskedCorners = []
            cell.vwMain?.layer.cornerRadius = 10
            
            let totalTopRows = tableView.numberOfRows(inSection: 0)
            // show bottom separator only for non-last static row
            cell.lblBottom?.isHidden = (indexPath.row == totalTopRows - 1)
            
            // Corner radius rules for top static block - make rounded block across rows
            if indexPath.row == 0 && totalTopRows == 1 {
                cell.vwMain?.layer.maskedCorners = [
                    .layerMinXMinYCorner, .layerMaxXMinYCorner,
                    .layerMinXMaxYCorner, .layerMaxXMaxYCorner
                ]
            } else if indexPath.row == 0 {
                cell.vwMain?.layer.maskedCorners = [
                    .layerMinXMinYCorner, .layerMaxXMinYCorner
                ]
            } else if indexPath.row == totalTopRows - 1 {
                cell.vwMain?.layer.maskedCorners = [
                    .layerMinXMaxYCorner, .layerMaxXMaxYCorner
                ]
            }
            
            // Configure appearance per top-row
            cell.lblName?.text = topMenuTitles[indexPath.row]
            cell.lblName?.textColor = UIColor.themePrimaryColor
            cell.lblBottom?.isHidden = true           // bottom row → no line
            cell.imgContact?.image = UIImage(named: "icn_add_new_chat")
            cell.vwInvite?.isHidden = true
            cell.btnInvite?.isHidden = true
            cell.vwCheck?.isHidden = true
            cell.btnCheck?.isHidden = true
            return cell
        }
        
        // ---------- REAL CONTACT SECTION ----------
        let real = indexPath.section - 1
        guard real >= 0, real < sections.count else { return UITableViewCell() }
        let contacts = sections[real].contacts
        guard indexPath.row >= 0, indexPath.row < contacts.count else { return UITableViewCell() }
        let contact = contacts[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContactTVCell",
            for: indexPath
        ) as? ContactTVCell else { return UITableViewCell() }
        
        // Reset styling defensively
        cell.vwMain?.layer.cornerRadius = 10
        cell.vwMain?.layer.masksToBounds = true
        cell.vwMain?.layer.maskedCorners = []
        
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        cell.lblBottom?.isHidden = (indexPath.row == totalRows - 1)
        cell.imgContact?.image = UIImage(named: "icn_contact_placeholder")
        // Corner radius logic for normal sections
        if indexPath.row == 0 && totalRows == 1 {
            cell.vwMain?.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        } else if indexPath.row == 0 {
            cell.vwMain?.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
        } else if indexPath.row == totalRows - 1 {
            cell.vwMain?.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        }
        
        cell.lblName?.text = contact.name ?? "-"
        cell.lblName?.textColor = UIColor.themeButton636363
        
        let hasID = !(contact.id ?? "").isEmpty
        cell.vwInvite?.isHidden = hasID
        cell.btnInvite?.isHidden = hasID
        cell.vwCheck?.isHidden = !hasID
        cell.btnCheck?.isHidden = !hasID
        cell.btnCheck?.isUserInteractionEnabled = hasID
        
        let safeTag = (indexPath.section << 16) | (indexPath.row & 0xFFFF)
        cell.btnInvite?.tag = safeTag
        cell.btnCheck?.tag = safeTag
        
        cell.btnInvite?.removeTarget(nil, action: nil, for: .allEvents)
        cell.btnCheck?.removeTarget(nil, action: nil, for: .allEvents)
        
        cell.btnInvite?.addTarget(self, action: #selector(didTapInvite(_:)), for: .touchUpInside)
        cell.btnCheck?.addTarget(self, action: #selector(didTapCheck(_:)), for: .touchUpInside)
        
        if self.isFromDeal == true {
            cell.btnCheck?.isSelected = (self.selectedIndexPath == indexPath)
        } else {
            if hasID, let id = contact.id {
                cell.btnCheck?.isSelected = selectedIDs.contains(id)
            } else {
                cell.btnCheck?.isSelected = false
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "NotRegisterVC") as? NotRegisterVC {
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
        let real = indexPath.section - 1
        guard real >= 0, real < sections.count else { return }
        let contact = sections[real].contacts[indexPath.row]
        if isFromDeal {
            guard let id = contact.id, !id.isEmpty else {
                Utility.showToast(message: "Please Invite members for property".localized)
                return
            }
            if let prev = selectedIndexPath,
               let prevCell = tableView.cellForRow(at: prev) as? ContactTVCell {
                prevCell.btnCheck?.isSelected = false
            }
            selectedIndexPath = indexPath
            selectSingle = id
            if let cell = tableView.cellForRow(at: indexPath) as? ContactTVCell {
                cell.btnCheck?.isSelected = true
            }
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
        
        if section == 0 { return UIView() }  // no header for top menu
        
        let real = section - 1
        guard real >= 0, real < sections.count else { return nil }
        let title = sections[real].title
        
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
    
    @objc private func didTapCheck(_ sender: UIButton) {
        let section = sender.tag >> 16
        let row = sender.tag & 0xFFFF
        
        guard section > 0 else { return }
        let indexPath = IndexPath(row: row, section: section)
        
        let real = section - 1
        let contact = sections[real].contacts[row]
        
        if isFromDeal {
            guard let id = contact.id, !id.isEmpty else {
                Utility.showToast(message: "Please Invite members for property".localized)
                return
            }
            if let prev = selectedIndexPath,
               let prevCell = tblContact?.cellForRow(at: prev) as? ContactTVCell {
                prevCell.btnCheck?.isSelected = false
            }
            selectedIndexPath = indexPath
            selectSingle = id
            if let cell = tblContact?.cellForRow(at: indexPath) as? ContactTVCell {
                cell.btnCheck?.isSelected = true
            }
            return
        }
        toggleSelection(at: indexPath)
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
            Utility.showToast(message: "WhatsApp not installed")
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
    
    private func toggleSelection(at indexPath: IndexPath) {
        guard let table = tblContact else { return }
        guard indexPath.section > 0 else { return }  // ignore top menu
        
        let real = indexPath.section - 1
        guard real >= 0, real < sections.count else { return }
        
        let contacts = sections[real].contacts
        guard indexPath.row >= 0, indexPath.row < contacts.count else { return }
        
        let contact = contacts[indexPath.row]
        
        // only contacts with id can be selected
        guard let id = contact.id, !id.isEmpty else { return }
        
        // MARK: MULTI-SELECT LOGIC
        if selectedIDs.contains(id) {
            // already selected → remove
            selectedIDs.remove(id)
            
            if let cell = table.cellForRow(at: indexPath) as? ContactTVCell {
                cell.btnCheck?.isSelected = false
            }
            
            table.deselectRow(at: indexPath, animated: true)
            
        } else {
            // new selection → add
            selectedIDs.insert(id)
            
            if let cell = table.cellForRow(at: indexPath) as? ContactTVCell {
                cell.btnCheck?.isSelected = true
            }
            
            table.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ContactListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss on Return
        return true
    }
}

// MARK: - API Call
fileprivate extension ContactListVC {
    
    private func wsGetCheckNumbers() {
        Utility.showLoading()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let contacts = self.fetchContacts()
            let contactDictionaries = contacts.map {
                ["name": $0.name, "mobile": $0.phoneNumber]
            }
            
            let dictParam: [String: Any] = ["contacts": contactDictionaries]
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.sendContactsToServer(dictParam: dictParam)
            }
        }
    }
    
    private func sendContactsToServer(dictParam: [String: Any]) {
        WebServices.Post(
            url: WebService.CONTACTS,
            params: dictParam,
            type: [UserContact].self
        ) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            
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
            
            let first = String(name.prefix(1)).uppercased()
            
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
            Section(title: $0, contacts: grouped[$0] ?? [])
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tblContact?.reloadData()
        }
    }
    
    func wsPutShare(arrIDS: [String]) {
        Utility.showLoading()
        var params: [String: Any] = [:]
        params[PARAMS.USERS] = arrIDS
        let url = "\(WebService.PROPERTY)\(objProperty?.id ?? "")/share/"
        WebServices.Put(url: url, params: params, type: Property.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            Utility.showToast(message: "Share property successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.onDismiss?(nil)
                self.dismiss(animated: true)
            }
        }
    }
    
    func wsDeals(propertyId: String, buyerId: String ) {
        Utility.showLoading()
        var params: [String: Any] = [:]
        params[PARAMS.PROPERTY_ID] = propertyId
        params[PARAMS.BUYER_ID] = buyerId
        let url = "\(WebService.DEALS)"
        WebServices.Post(url: url, params: params, type: Deal.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            Utility.showToast(message: "Add deal successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.onDismiss?(response)
                self.dismiss(animated: true)
            }
        }
    }
}

extension ContactListVC : NotRegisterDelegate {
    func addChat(mobile: String) {
        if self.isFromDeal == true {
            Utility.showLoading()
            var params: [String: Any] = [:]
            params[PARAMS.PROPERTY_ID] = self.objProperty?.id
            params[PARAMS.BUYER_ID] = UserDefaultsHelper.getUserFromDefaults()?.userId
            params[PARAMS.CONTACTS] = mobile
            let url = "\(WebService.DEALS)"
            WebServices.Post(url: url, params: params, type: Deal.self) { [weak self] response in
                guard let self = self else { return }
                Utility.hideLoading()
                guard response != nil else { return }
                Utility.showToast(message: "Add deal successfully".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.onDismiss?(response)
                    self.dismiss(animated: true)
                }
            }
        } else {
            Utility.showLoading()
            var params: [String: Any] = [:]
            params[PARAMS.CONTACTS] = mobile
            params[PARAMS.USERS] = [UserDefaultsHelper.getUserFromDefaults()?.userId]
            let url = "\(WebService.PROPERTY)\(objProperty?.id ?? "")/share/"
            WebServices.Put(url: url, params: params, type: Property.self) { [weak self] response in
                guard let self = self else { return }
                Utility.hideLoading()
                guard response != nil else { return }
                Utility.showToast(message: "Share property successfully".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.onDismiss?(nil)
                    self.dismiss(animated: true)
                }
            }
        }
    }
}
