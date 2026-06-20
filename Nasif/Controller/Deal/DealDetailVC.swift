//
//  DealDetailVC.swift
//  Nasif
//
//  Created by Denish Gediya on 31/07/25.
//

import UIKit
import CoreTelephony
import Contacts

enum DealAction {
    case delete
    case exit
    case archive
}

class DealDetailVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet private weak var lblDealNumber: UILabel!
    @IBOutlet private weak var vwListingMain: UIView!
    @IBOutlet weak var vwsubListMain: UIView!
    @IBOutlet private weak var vwListingThumbImg: UIView!
    @IBOutlet private weak var imgListingThumb: UIImageView!
    @IBOutlet private weak var lblListingTitle: UILabel!
    @IBOutlet private weak var lblListingPlace: UILabel!
    @IBOutlet private weak var lblListingPrice: UILabel!
    @IBOutlet private weak var vwCompletion: UIView!
    @IBOutlet private weak var vwNegotiation: UIView!
    @IBOutlet private weak var vwInquiries: UIView!
    @IBOutlet private weak var lblDealManagersTitle: UILabel!
    @IBOutlet private weak var lblDealCreatorName: UILabel!
    @IBOutlet private weak var imgDealCreatorProfile: UIImageView!
    @IBOutlet private weak var lblSecondPersonName: UILabel!
    @IBOutlet private weak var imgSecondPersonProfile: UIImageView!
    @IBOutlet private weak var vwMainDelete: UIView!
    @IBOutlet private weak var btnConformDelete: UIButton!
    @IBOutlet private weak var btnCancel: UIButton!
    @IBOutlet private weak var stackExit: UIStackView?
    @IBOutlet private weak var btnDelete: UIButton!
    @IBOutlet private weak var btnArchive: UIButton!
    
    @IBOutlet weak var btnStep1: UIButton!
    @IBOutlet weak var btnStep2: UIButton!
    @IBOutlet weak var btnStep3: UIButton!
    @IBOutlet weak var btnStep4: UIButton!
    @IBOutlet weak var btnStep5: UIButton!
    @IBOutlet weak var btnStep6: UIButton!
    @IBOutlet weak var btnStep7: UIButton!
    
    @IBOutlet weak var stackDeal: UIStackView?
    
    @IBOutlet private weak var lblDealStepsTitle: UILabel?
    @IBOutlet weak var lblSendingTitle: UILabel?
    @IBOutlet weak var lblVisitTitle: UILabel?
    @IBOutlet weak var lblAgreementTitle: UILabel?
    @IBOutlet weak var lblDownPaymnetTitle: UILabel?
    @IBOutlet weak var lblTransferTitle: UILabel?
    @IBOutlet weak var lblPayingTitle: UILabel?
    @IBOutlet weak var lblSendingTheDetails: UILabel?
    @IBOutlet weak var lblGeneralDetalTitle: UILabel?
    @IBOutlet private weak var lblCompletion: UILabel!
    @IBOutlet private weak var lblNegotiation: UILabel!
    @IBOutlet private weak var lblInquiries: UILabel!
    @IBOutlet weak var lblExitDeal: UILabel!
    @IBOutlet weak var lblArchiveTitle: UILabel!
    @IBOutlet weak var lblDeleteDeal: UILabel!
    
    @IBOutlet weak var btnCompletion: UIButton!
    @IBOutlet weak var btnNegotiation: UIButton!
    @IBOutlet weak var btnInquiries: UIButton!
    
    @IBOutlet weak var vwStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    
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
    
    // MARK: - Properties
    var objDeal: Deal?
    private var stepButtons: [UIButton] = []
    var currentAction: DealAction = .delete // set this before calling
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keep the buttons in order (1..7)
        stepButtons = [btnInquiries, btnNegotiation, btnCompletion]
        
        // Initial setup: assign 1-based tags, targets, default states
        stepButtons.enumerated().forEach { idx, button in
            button.tag = idx + 1
            button.addTarget(self, action: #selector(stepButtonTapped(_:)), for: .touchUpInside)
            button.isSelected = false
            button.isUserInteractionEnabled = (idx == 0) // only step1 enabled by default
        }
        // By default enable step 1 (if no objDeal / subStatus)
        stepButtons.first?.isUserInteractionEnabled = true
        
        [vw1, vw2, vw3, vw4, vw5].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }
        
        vw1.backgroundColor = UIColor.themeD9D9D9
        vw2.backgroundColor = UIColor.themeD9D9D9
        vw3.backgroundColor = UIColor.themeD9D9D9
        vw4.backgroundColor = UIColor.themeD9D9D9
        vw5.backgroundColor = UIColor.themeD9D9D9
        
        setupUI()
        bindDealData()
        wsGetDeals() // will refresh objDeal + call updateUI after response
    }
    
    @IBAction func btnOnClickDeal(_ sender: UIButton) {
        navigateToDetail()
    }
    
    func navigateToDetail() {
        let detailVC = ListingDetailVC()
        detailVC.isFromPush = true
        detailVC.strProperty = objDeal?.property?.id ?? ""
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func btnOnClickStep(_ sender: UIButton) {
        if sender.tag == 0 {
            
        } else if sender.tag == 1 {
            
        } else {
            
        }
    }
}

// MARK: - Actions
private extension DealDetailVC {
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // Helper: disable/enable all buttons while request is in-flight
    private func setAllStepButtonsInteraction(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.stepButtons.forEach { $0.isUserInteractionEnabled = enabled }
        }
    }
    
    /// Main step button handler (1-based tags). Strict step-by-step rules:
    /// - Check only if tag == currentStatus + 1
    /// - Uncheck only if tag == currentStatus (i.e., last checked step)
    @objc private func stepButtonTapped(_ sender: UIButton) {
        let tag = sender.tag // 1-based step index (1..7)
        guard tag >= 1 && tag <= stepButtons.count else { return }
        
        let currentStatus = objDeal?.subStatus ?? 0
        
        if sender.isSelected {
            // UNCHECK: allow only if this is the LAST completed step
            guard tag == currentStatus else {
                // If user tapped other completed step, show message and sync
                Utility.showToast(message: "Please uncheck last completed step first".localized)
                wsGetDeals()
                return
            }
            
            let newStatus = tag
            setAllStepButtonsInteraction(false) // prevent double taps
            
            wsUpdateDeal(status: "\(newStatus)") { [weak self] success in
                guard let self = self else { return }
                if !success {
                    Utility.showToast(message: "Could not update. Please try again.".localized)
                    DispatchQueue.main.async {
                        self.updateUI(for: self.objDeal?.subStatus ?? 0)
                    }
                }
                // on success, wsUpdateDeal updates UI from server response
            }
            
        } else {
            // CHECK: allow only if this is immediate next step (no skipping)
            guard tag == currentStatus + 1 else {
                Utility.showToast(message: "Please complete previous step first".localized)
                return
            }
            
            let newStatus = tag
            setAllStepButtonsInteraction(false)
            
            wsUpdateDeal(status: "\(newStatus)") { [weak self] success in
                guard let self = self else { return }
                if !success {
                    Utility.showToast(message: "Could not update. Please try again.".localized)
                    DispatchQueue.main.async {
                        self.updateUI(for: self.objDeal?.subStatus ?? 0)
                    }
                }
                // on success, wsUpdateDeal updates UI from server response
            }
        }
    }
    
    
    
    @IBAction func btnOnClickExitDeal(_ sender: UIButton) {
        self.currentAction = .exit
        configureDeleteConfirmation(isDelete: false, message: "Confirm exiting the deal".localized)
    }
    
    @IBAction func btnOnClickDeleteDeal(_ sender: UIButton) {
        self.currentAction = .delete
        configureDeleteConfirmation(isDelete: true, message: "Confirm deleting the deal".localized)
    }
    
    @IBAction func btnOnClickArchive(_ sender: UIButton) {
        self.currentAction = .archive
        btnConformDelete.backgroundColor = UIColor.themeButton636363
        btnConformDelete.setTitle("Confirm archiving the deal".localized, for: .normal)
        vwMainDelete.isHidden = false
    }
    
    @IBAction func btnOnClickConformDelete(_ sender: UIButton) {
        confirmDealAction()
    }
    
    @IBAction func btnOnClickCancel(_ sender: UIButton) {
        vwMainDelete.isHidden = true
    }
}

// MARK: - UI Setup & Helpers
private extension DealDetailVC {
    
    func setupUI() {
        [vwCompletion, vwNegotiation, vwInquiries].forEach {
            $0?.layer.cornerRadius = 8
            $0?.layer.masksToBounds = true
        }
        
        vwStatus.layer.cornerRadius = 10
        vwStatus.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        imgListingThumb.layer.cornerRadius = 10
        imgListingThumb.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                               .layerMaxXMaxYCorner]   // bottom-right
        imgListingThumb.layer.masksToBounds = true
        
        vwsubListMain.layer.cornerRadius = 10.0
        vwsubListMain.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        vwsubListMain.layer.masksToBounds = true
        
        vwsubListMain.layer.borderColor = UIColor.black.cgColor
        vwsubListMain.layer.borderWidth = 1.0
        
        vwListingThumbImg.layer.cornerRadius = 10
        vwListingThumbImg.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                                 .layerMaxXMaxYCorner]   // bottom-right
        vwListingThumbImg.layer.masksToBounds = true
        vwListingThumbImg.layer.borderWidth = 1.5
        vwListingThumbImg.layer.borderColor = UIColor.theme999999.cgColor
        
        vwCompletion.layer.borderColor = UIColor.themeBackgroundGreenColor.cgColor
        vwCompletion.layer.borderWidth = 1.5
        
        vwNegotiation.layer.borderColor = UIColor.themeBackgroundRedColor.cgColor
        vwNegotiation.layer.borderWidth = 1.5
        
        vwInquiries.layer.borderColor = UIColor.themePrimaryColor.cgColor
        vwInquiries.layer.borderWidth = 1.5
        
        [btnConformDelete, btnCancel, vwListingThumbImg].forEach {
            $0?.layer.cornerRadius = 10
        }
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblDealStepsTitle?.text = "Deal Steps:".localized
        self.lblSendingTitle?.text = "Sending the Detailes".localized
        self.lblVisitTitle?.text = "Visit and inspect the property".localized
        self.lblAgreementTitle?.text = "Agreement on price".localized
        self.lblDownPaymnetTitle?.text = "Down payment".localized
        self.lblTransferTitle?.text = "Transfer Procedures".localized
        self.lblPayingTitle?.text = "Paying the remaining amount".localized
        self.lblSendingTheDetails?.text = "Sending the Detailes".localized
        self.lblGeneralDetalTitle?.text = "General Deal Step".localized
        self.lblCompletion?.text = "Completion".localized
        self.lblNegotiation?.text = "Negotiation".localized
        self.lblInquiries?.text = "Inquiries".localized
        self.lblDealManagersTitle?.text = "Deal Manager:".localized
        self.lblExitDeal?.text = "Exit the Deal".localized
        self.lblDeleteDeal?.text = "Delete the Deal".localized
        self.lblArchiveTitle?.text = "Archiving".localized
    }
    
    func bindDealData() {
        guard let deal = objDeal else {
            // no existing deal -> default state (only step 1 enabled)
            updateUI(for: 0)
            return
        }
        // wsGetCheckNumbers(objDeal: deal)
        lblDealNumber.text = "\("Details For Deal No".localized) \(deal.dealNo ?? 0)"
        lblDealCreatorName.text = deal.user?.displayName
        lblSecondPersonName.text = deal.buyer?.displayName
        
        if let type = deal.property?.type?.localized {
            if deal.property?.availableFor == "Sale" {
                self.lblListingTitle?.text = "\(type) للبيع"
            } else {
                self.lblListingTitle?.text = "\(type) للإيجار"
            }
        } else {
            self.lblListingTitle?.text = deal.property?.type?.localized ?? "N/A"
        }
        
        lblListingPlace.text = deal.property?.city
        lblStatus?.text = deal.property?.status?.localized
        lblListingPrice.text = formatPriceNew("\(deal.property?.price ?? 0)")
        lblSquare.text = "\(deal.property?.area ?? 0)"
        if deal.property?.type == "Land" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if deal.property?.type == "Villa" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
            if deal.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(deal.property?.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
        } else if deal.property?.type == "Apartment" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = false
            self.vw5.isHidden = true
            if deal.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(deal.property?.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
            if deal.property?.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(deal.property?.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if deal.property?.type == "Floor" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw5.isHidden = true
            if deal.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(deal.property?.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
            if deal.property?.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(deal.property?.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if deal.property?.type == "Building Complex" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if deal.property?.type == "Chalet" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if deal.property?.type == "Farm" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if deal.property?.type == "Other" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        }
        if let urlStr = deal.property?.coverImage, let url = URL(string: urlStr) {
            imgListingThumb.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_new_placeholder"))
        }
        
        if deal.property?.status == "Available" {
            self.vwStatus.backgroundColor = UIColor.themeBackgroundGreenColor
        } else if deal.property?.status == "Reserved" {
            self.vwStatus.backgroundColor = UIColor.themePurpor
        } else {
            self.vwStatus.backgroundColor = UIColor.themeBackgroundRedColor
        }
        
        // IMPORTANT: update UI according to server subStatus
        updateUI(for: deal.subStatus ?? 0)
    }
    
    func configureDeleteConfirmation(isDelete: Bool, message: String) {
        btnConformDelete.backgroundColor = UIColor.themeBackgroundRedColor
        btnConformDelete.setTitle(message, for: .normal)
        vwMainDelete.isHidden = false
    }
    
    private func wsGetCheckNumbers(objDeal: Deal) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            // 1️⃣ Fetch all device contacts
            let contacts = self.fetchContacts()
            
            // 2️⃣ Clean objChat mobile number (last 9 digits)
            if let chatMobile = objDeal.user?.mobile {
                let cleanedChatMobile = self.sanitizePhoneNumber(chatMobile)
                
                // 3️⃣ Try to find matching contact (last 8 or 9 digits)
                if let matchedContact = contacts.first(where: { contact in
                    let contactNumber = contact.phoneNumber
                    // Compare last 8 or last 9 digits
                    return contactNumber.suffix(8) == cleanedChatMobile.suffix(8) ||
                    contactNumber.suffix(9) == cleanedChatMobile.suffix(9)
                }) {
                    // 4️⃣ Update UI on main thread
                    DispatchQueue.main.async {
                        let name = matchedContact.name
                        self.lblDealCreatorName.text = (name.isEmpty == false) ? name : Utility.formattedPhoneNumber(objDeal.user?.mobile)
                    }
                    return
                }
            }
            
            if let chatBuyerMobile = objDeal.buyer?.mobile {
                let cleanedChatMobile = self.sanitizePhoneNumber(chatBuyerMobile)
                
                // 3️⃣ Try to find matching contact (last 8 or 9 digits)
                if let matchedContact = contacts.first(where: { contact in
                    let contactNumber = contact.phoneNumber
                    // Compare last 8 or last 9 digits
                    return contactNumber.suffix(8) == cleanedChatMobile.suffix(8) ||
                    contactNumber.suffix(9) == cleanedChatMobile.suffix(9)
                }) {
                    // 4️⃣ Update UI on main thread
                    DispatchQueue.main.async {
                        let name = matchedContact.name
                        self.lblSecondPersonName.text = (name.isEmpty == false) ? name : Utility.formattedPhoneNumber(objDeal.buyer?.mobile)
                    }
                    return
                }
            }
        }
    }
    
    func fetchContacts() -> [(name: String, phoneNumber: String)] {
        var contactList = [(name: String, phoneNumber: String)]()
        
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
        
        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                for number in contact.phoneNumbers {
                    let phoneNumber = number.value.stringValue
                    let cleanedNumber = sanitizePhoneNumber(phoneNumber)
                    contactList.append((name: fullName, phoneNumber: cleanedNumber))
                }
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
        
        return contactList
    }
    
    func sanitizePhoneNumber(_ number: String) -> String {
        // Remove all non-digit characters
        let digits = number.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        // Get last 9 digits
        return String(digits.suffix(9))
    }
    
    func updateUI(for step: Int) {
        guard !stepButtons.isEmpty else { return }
        let maxSteps = stepButtons.count
        let normalizedStep = max(0, min(step, maxSteps)) // clamp 0..maxSteps
        
        stepButtons.forEach { button in
            let t = button.tag // 1-based
            // Selected if <= normalizedStep
            button.isSelected = (t <= normalizedStep)
            
            // Interaction rules:
            if normalizedStep == 0 {
                // nothing completed yet -> only step 1 enabled
                button.isUserInteractionEnabled = (t == 1)
            } else {
                // allow uncheck only for last completed (t == normalizedStep)
                // allow check for immediate next (t == normalizedStep + 1)
                if t == normalizedStep || t == normalizedStep + 1 {
                    button.isUserInteractionEnabled = true
                } else {
                    button.isUserInteractionEnabled = false
                }
            }
            
            // Visual hint (optional) — selected vs not
            button.alpha = button.isSelected ? 1.0 : 0.6
        }
        
        // Section highlights
        [vwInquiries, vwNegotiation, vwCompletion].forEach { $0?.backgroundColor = .clear }
        lblInquiries.textColor = UIColor.themePrimaryColor
        lblNegotiation.textColor = UIColor.themeBackgroundRedColor
        lblCompletion.textColor = UIColor.themeBackgroundGreenColor
        
        if normalizedStep >= 1 { vwInquiries.backgroundColor = UIColor.themePrimaryColor; lblInquiries.textColor = .white }
        if normalizedStep >= 2 { vwNegotiation.backgroundColor = UIColor.themeBackgroundRedColor; lblNegotiation.textColor = .white }
        if normalizedStep >= 3 { vwCompletion.backgroundColor = UIColor.themeBackgroundGreenColor; lblCompletion.textColor = .white }
        
        // Show/hide deal actions as before
        if objDeal?.user?.id == UserDefaultsHelper.getUserFromDefaults()?.userId {
            self.stackExit?.isHidden = true
            self.stackDeal?.isHidden = false
        } else {
            self.stackExit?.isHidden = false
            self.stackDeal?.isHidden = true
        }
        
        if self.objDeal?.isExit == true {
            self.stackExit?.isHidden = true
            stepButtons.forEach { $0.isUserInteractionEnabled = false }
            self.btnArchive.isUserInteractionEnabled = false
            self.btnDelete.isUserInteractionEnabled = false
        }
    }
    
    
    func confirmDealAction() {
        let message: String
        let title: String
        switch currentAction {
        case .delete:
            message = "Are you sure you want to delete this deal?".localized
            title = "Delete".localized
        case .exit:
            message = "Are you sure you want to exit this deal?".localized
            title = "Exit".localized
        case .archive:
            message = "Are you sure you want to archive this deal?".localized
            title = "Archive".localized
        }
        
        showDeleteConfirmation(from: self, message: message, title: title) { [weak self] confirmed in
            guard let self, confirmed else { return }
            switch self.currentAction {
            case .delete: self.wsDeleteDeal()
            case .exit: self.wsDeleteExit()
            case .archive: self.wsArchivedDeal()
            }
        }
    }
}

// MARK: - Web Service Calls
private extension DealDetailVC {
    
    func wsGetDeals() {
        guard let dealID = objDeal?.id else {
            // No deal yet - keep default UI
            updateUI(for: 0)
            return
        }
        
        Utility.showLoading()
        WebServices.Get(url: "\(WebService.DEALS)\(dealID)/", type: Deal.self) { [weak self] response in
            Utility.hideLoading()
            guard let self else { return }
            guard let response else { return }
            
            DispatchQueue.main.async {
                self.objDeal = response
                self.bindDealData() // will call updateUI(for: response.subStatus)
            }
        }
    }
    
    func wsUpdateDeal(status: String, completion: @escaping (Bool) -> Void) {
        guard let dealID = objDeal?.id else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        Utility.showLoading()
        WebServices.Put(url: "\(WebService.DEALS)\(dealID)/status/\(status)/", params: [:], type: Deal.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            guard let response = response else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            // Update model and UI on main thread
            self.objDeal = response
            DispatchQueue.main.async {
                self.updateUI(for: response.subStatus ?? 0)
                completion(true)
            }
        }
    }
    
    func wsArchivedDeal() {
        guard let dealID = objDeal?.id else { return }
        
        Utility.showLoading()
        WebServices.Put(url: "\(WebService.DEALS)\(dealID)/archived/", params: [:], type: Deal.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            Utility.showToast(message: "Deal archived successfully".localized)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func wsDeleteDeal() {
        guard let dealID = objDeal?.id else { return }
        
        Utility.showLoading()
        WebServices.Delete(url: "\(WebService.DEALS)\(dealID)/", type: Deal.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            Utility.showToast(message: "Delete deal successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func wsDeleteExit() {
        guard let dealID = objDeal?.id else { return }
        Utility.showLoading()
        WebServices.Delete(url: "\(WebService.DEALS)\(dealID)/exit/", type: Deal.self) { [weak self] response in
            Utility.hideLoading()
            guard let self, response != nil else { return }
            Utility.showToast(message: "Exit deal successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
