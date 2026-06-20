//
//  SaveDetailVC.swift
//  Nasif
//
//  Created by Denish Gediya on 08/07/25.
//

import UIKit

class SaveDetailVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lblSaveTitle: UILabel?
    @IBOutlet weak var lblListNo: UILabel?
    @IBOutlet weak var lblListValue: UILabel?
    @IBOutlet weak var btnShare: UIButton?
    @IBOutlet weak var btnBackList: UIButton?
    
    // MARK: - Variables
    var objProperty: Property?
    
    //MARK: -  View Life
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension SaveDetailVC {
    @IBAction func btnOnClickShare(_ sender: UIButton) {
        let contactListVC = ContactListVC(nibName: "ContactListVC", bundle: nil)
        contactListVC.isFromDeal = false
        contactListVC.objProperty = self.objProperty
        contactListVC.onDismiss = { [weak self] _ in
            guard let self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.navigationController?.present(contactListVC, animated: true)
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UI helpers
extension SaveDetailVC {
    func InitConfig() {
        self.lblSaveTitle?.font = FontHelper.font(size: 32.0, type: FontType.Regular)
        self.lblListNo?.font = FontHelper.font(size: 20.0, type: FontType.Regular)
        self.lblListValue?.font = FontHelper.font(size: 14.0, type: FontType.Regular)
        
        self.btnShare?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnShare?.setupNewButton(borderColor: .clear,andCornerRadious: 8.0)
        
        self.btnBackList?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnBackList?.layer.cornerRadius = 8.0
        self.btnBackList?.layer.masksToBounds = true
        
        self.lblListValue?.text = "\(objProperty?.listingNo ?? 0)"
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblSaveTitle?.text = "SAVED".localized
        self.lblListNo?.text = "Listing No.".localized
        self.btnShare?.setTitle("Share".localized, for: .normal)
        self.btnBackList?.setTitle("Back to the listings".localized, for: .normal)
    }
}
