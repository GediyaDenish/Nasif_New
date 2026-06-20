//
//  AddImageTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 08/07/25.
//

import UIKit

class AddImageTVCell: UITableViewCell {

    @IBOutlet weak var vwBG: UIView?
    @IBOutlet weak var imgProperty: UIImageView?
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var vwImgMain: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.vwBG?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 8.0, borderWidth: 0.0)
        self.vwImgMain?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 8.0, borderWidth: 0.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
