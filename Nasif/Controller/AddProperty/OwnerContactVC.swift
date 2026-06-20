//
//  OwnerContactVC.swift
//  Nasif
//
//  Created by Denish Gediya on 08/07/25.
//

import UIKit
import ContactsUI

class OwnerContactVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet var lblSubTitle: [UILabel]?
    @IBOutlet var vwTxtBG: [UIView]?
    @IBOutlet weak var txtAdvertiser: UITextField?
    @IBOutlet weak var txtPlanNumber: UITextField?
    @IBOutlet weak var txtPlotNumber: UITextField?
    @IBOutlet weak var txtLicenseNumber: UITextField?
    @IBOutlet weak var txtAdvertisementLicenseNumber: UITextField?
    @IBOutlet weak var txtOwnersName: UITextField?
    @IBOutlet weak var txtOwnersNumber: UITextField?
    
    @IBOutlet weak var btnNext: UIButton?
    @IBOutlet weak var btnContactImport: UIButton?
    @IBOutlet weak var lblAdvertiserRoleTitle: UILabel!
    @IBOutlet weak var lblPlanNumberTitle: UILabel!
    @IBOutlet weak var lblPlotNumberTitle: UILabel!
    @IBOutlet weak var lblFalLicenseTitle: UILabel!
    @IBOutlet weak var lblAdvertisementLicenseTitle: UILabel!
    @IBOutlet weak var lblOwnersTitle: UILabel!
    @IBOutlet weak var lblOwnersNumberTitel: UILabel!
    
    
    // MARK: - Variables
    public var dictParam: [String: Any] = [:]
    var isFromEdit: Bool = false
    var objProperty: Property?
    var arrImages: [UIImage] = []
    var thumbImage: UIImage?
    
    // MARK: - View Life
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureIfEditing()
    }
}

// MARK: - IBAction
extension OwnerContactVC {
    @IBAction func btnOnClickContactImport(_ sender: UIButton) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        present(contactPicker, animated: true)
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickNext(_ sender: UIButton) {
        isFromEdit ? updateListing() : saveListing()
    }
}

// MARK: - UI Setup
private extension OwnerContactVC {
    func setupUI() {
        
        lblSubTitle?.forEach {
            $0.textColor = .black
            $0.font = FontHelper.font(size: 15.0, type: .Regular)
        }
        
        vwTxtBG?.forEach {
            $0.setRound(withBorderColor: UIColor.themeBorderColor,
                        andCornerRadious: 8.0,
                        borderWidth: 1.0)
        }
        
        [btnNext, btnContactImport].forEach {
            $0?.setupNewButton(borderColor: .clear, andCornerRadious: 8.0)
            $0?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        }
        self.txtOwnersNumber?.delegate = self
        self.txtOwnersNumber?.keyboardType = .numberPad
        setupLocalized()
    }
    
    func setupLocalized() {
        self.lblAdvertiserRoleTitle?.text = "Advertiser's Role:".localized
        self.lblPlanNumberTitle?.text = "Plan Number:".localized
        self.lblPlotNumberTitle?.text = "Plot Number:".localized
        self.lblFalLicenseTitle?.text = "Fal License Number:".localized
        self.lblAdvertisementLicenseTitle?.text = "Advertisement License Number:".localized
        self.lblOwnersTitle?.text = "Owners Name".localized
        self.lblOwnersNumberTitel?.text = "Owners Number".localized
        self.btnNext?.setTitle("SAVE".localized, for: .normal)
    }
    
    func configureIfEditing() {
        guard isFromEdit, let data = objProperty else { return }
        txtAdvertiser?.text = data.advertisersRole ?? ""
        txtPlanNumber?.text = data.planNumber ?? ""
        txtPlotNumber?.text = data.plotNumber ?? ""
        txtLicenseNumber?.text = data.falLicenseNumber ?? ""
        txtAdvertisementLicenseNumber?.text = data.licenseNumber ?? ""
        txtOwnersName?.text = data.ownerName
        txtOwnersNumber?.text = data.ownerNumber
        btnNext?.setTitle("Update".localized, for: .normal)
    }
}

// MARK: - CNContactPickerDelegate
extension OwnerContactVC: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            txtOwnersNumber?.text = cleanPhoneNumber(phoneNumber)
            let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "\(contact.givenName) \(contact.familyName)"
            txtOwnersName?.text = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    
    private func cleanPhoneNumber(_ number: String) -> String {
        let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+"))
        return number.components(separatedBy: allowedCharacters.inverted).joined()
    }
}

// MARK: - Web Service Calls
private extension OwnerContactVC {
    
    func prepareParams() {
        Utility.addIfValid(&dictParam, key: PARAMS.ADVERTISER_ROLE, value: txtAdvertiser?.text)
        Utility.addIfValid(&dictParam, key: PARAMS.PLAN_NUMBER, value: txtPlanNumber?.text)
        Utility.addIfValid(&dictParam, key: PARAMS.PLOT_NUMBER, value: txtPlotNumber?.text)
        Utility.addIfValid(&dictParam, key: PARAMS.FAL_LICENSE_NUMBER, value: txtLicenseNumber?.text)
        Utility.addIfValid(&dictParam, key: PARAMS.ADVERTISEMENT_LICENSE_NUMBER, value: txtAdvertisementLicenseNumber?.text)
        Utility.addIfValid(&dictParam, key: PARAMS.OWNERS_NAME, value: txtOwnersName?.text)
        let cleanedNumber = sanitizePhoneNumber(txtOwnersNumber?.text ?? "")
        Utility.addIfValid(&dictParam, key: PARAMS.OWNERS_NUMBER, value: cleanedNumber)
    }
    
    func sanitizePhoneNumber(_ number: String) -> String {
        // Remove all non-digit characters
        let digits = number.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        // Get last 9 digits
        return String(digits.suffix(9))
    }
    
    func saveListing() {
        prepareParams()
        Utility.showLoading()
        
        WebServices.Post(url: WebService.PROPERTY, params: dictParam, type: Property.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else { return }
            guard response != nil else { return }
            if let data = response {
                self.handleListingResponse(data, successMessage: "Add Property successfully".localized)
            }
        }
    }
    
    func updateListing() {
        prepareParams()
        Utility.showLoading()
        
        let url = "\(WebService.PROPERTY)\(objProperty?.id ?? "")"
        WebServices.Put(url: url, params: dictParam, type: Property.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else { return }
            guard response != nil else { return }
            if let data = response {
                self.handleListingResponse(data, successMessage: "Update Property successfully".localized)
            }
        }
    }
    
    func handleListingResponse(_ data: Property, successMessage: String) {
        Utility.showNewToast(message: successMessage)
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "AddList", bundle: nil)
            if let saveDetailVC = storyboard.instantiateViewController(withIdentifier: "SaveDetailVC") as? SaveDetailVC {
                saveDetailVC.objProperty = data
                self.navigationController?.pushViewController(saveDetailVC, animated: true)
            }
        }
    }
}

extension OwnerContactVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Only for phone textfield
        guard textField == txtOwnersNumber else { return true }
        
        // Current text
        let currentText = textField.text ?? ""
        
        // New text after change
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // ✅ Allow only numbers
        let allowedCharacterSet = CharacterSet.decimalDigits
        if string.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
            return false
        }
        
        // ✅ Allow max 9 digits
        return updatedText.count <= 9
    }
}
