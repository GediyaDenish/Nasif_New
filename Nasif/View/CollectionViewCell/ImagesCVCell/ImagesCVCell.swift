//
//  ImagesCVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 08/07/25.
//

import UIKit

class ImagesCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imgImages: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgImages.contentMode = .scaleAspectFit
    }

}
