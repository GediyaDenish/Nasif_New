//
//  AutoCompleteTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 09/07/25.
//

import UIKit

class AutoCompleteTVCell: UITableViewCell {

    @IBOutlet weak var imgLocation: UIImageView?
    @IBOutlet weak var lblAddress: UILabel?
    @IBOutlet weak var lblSubAddress: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - SET CELL DATA
    func setCellData(place: (title: String, subTitle: String, address: String, placeid: String)) {
        lblAddress?.text = place.title
        lblSubAddress?.text = place.subTitle
    }
    
}
