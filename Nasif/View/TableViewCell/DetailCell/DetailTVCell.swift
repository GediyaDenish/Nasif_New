//
//  DetailTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 07/07/25.
//

import UIKit

class DetailTVCell: UITableViewCell {

    @IBOutlet weak var icnSAR: UIImageView!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblPerameter: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblValue?.font = FontHelper.font(size: 12.0, type: FontType.Regular)
        self.lblPerameter?.font = FontHelper.font(size: 12.0, type: FontType.Regular)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
