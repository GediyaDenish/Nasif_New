//
//  ListTypeCVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 01/07/25.
//

import UIKit

class ListTypeCVCell: UICollectionViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwType: UIView?
    @IBOutlet weak var lblType: UILabel?
    
    //MARK: -  View Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with text: String) {
        self.lblType?.font = FontHelper.font(size: 12.0, type: FontType.Regular)
        lblType?.text = text
    }
    
    func configures(with text: String, isSelected: Bool) {
        self.lblType?.font = UIFont.boldSystemFont(ofSize: 12.0)
        lblType?.text = text
        lblType?.textColor = isSelected ? .black : UIColor.darkGray
        contentView.backgroundColor = isSelected ? .white : .clear
    }
}
