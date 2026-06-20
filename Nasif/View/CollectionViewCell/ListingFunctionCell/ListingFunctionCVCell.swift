//
//  ListingFunctionCVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit

class ListingFunctionCVCell: UICollectionViewCell {
    
    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        vwMain.layer.cornerRadius = 10
        vwMain.layer.masksToBounds = true
    }

}
