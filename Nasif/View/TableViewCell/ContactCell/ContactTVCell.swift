//
//  ContactTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 04/08/25.
//

import UIKit

class ContactTVCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwMain: UIView?
    @IBOutlet weak var btnInvite: UIButton?
    @IBOutlet weak var imgContact: UIImageView?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var vwInvite: UIView?
    @IBOutlet weak var vwCheck: UIView?
    @IBOutlet weak var btnCheck: UIButton?
    @IBOutlet weak var lblBottom: UILabel?
    
    //MARK: -  View Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.InitConfig()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - UI helpers
fileprivate extension ContactTVCell {
    func InitConfig() {
        self.selectionStyle = .none
        btnInvite?.setTitle("Invite".localized, for: .normal)
    }
}
