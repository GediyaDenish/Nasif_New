//
//  AdminTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 08/10/25.
//

import UIKit

class AdminTVCell: UITableViewCell {

    @IBOutlet weak var lblStatus: UILabel?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var icnProfile: UIImageView?
    @IBOutlet weak var icnArrow: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.icnProfile?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 14.0, borderWidth: 0.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
