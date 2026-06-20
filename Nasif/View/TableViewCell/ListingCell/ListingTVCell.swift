//
//  ListingTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit

class ListingTVCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var vwMain: UIView!
    @IBOutlet private weak var vwMainImg: UIView!
    @IBOutlet private weak var imgPropertyThumbnail: UIImageView!
    @IBOutlet private weak var vwStatus: UIView!
    @IBOutlet private weak var lblStatus: UILabel!
    @IBOutlet private weak var lblPropertyType: UILabel!
    @IBOutlet private weak var lblArea: UILabel!
    @IBOutlet private weak var lblPrice: UILabel!
    
    @IBOutlet weak var vwPropertyType: UIView!
    @IBOutlet weak var lblNewPropertyType: UILabel!
    
    @IBOutlet weak var vw1: UIView!
    @IBOutlet weak var vw2: UIView!
    @IBOutlet weak var vw3: UIView!
    @IBOutlet weak var vw4: UIView!
    @IBOutlet weak var vw5: UIView!
    
    @IBOutlet private weak var lblSquare: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    
    @IBOutlet weak var vwSubMain: UIView!
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
    }
}

// MARK: - Setup
extension ListingTVCell {
    func setupUI() {
        //        lblStatus.font        = FontHelper.font(size: 10.0, type: .Regular)
        //        lblPropertyType.font  = FontHelper.font(size: 15.0, type: .Regular)
        //        lblArea.font          = FontHelper.font(size: 10.0, type: .Regular)
        //        lblPrice.font         = FontHelper.font(size: 16.0, type: .Regular)
        
        // Apply rounded corners
        [vwMain, vw1, vw2, vw3, vw4, vw5].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }
        
        vwStatus.layer.cornerRadius = 10
        vwStatus.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        vwPropertyType.layer.cornerRadius = 10
        vwPropertyType.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        vwMainImg.layer.cornerRadius = 10
        vwMainImg.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                         .layerMaxXMaxYCorner]   // bottom-right
        vwMainImg.layer.masksToBounds = true
        
        imgPropertyThumbnail.layer.cornerRadius = 10
        imgPropertyThumbnail.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                                    .layerMaxXMaxYCorner]   // bottom-right
        imgPropertyThumbnail.layer.masksToBounds = true
    }
}

// MARK: - Configuration
extension ListingTVCell {
    func configure() {
        self.selectionStyle = .none
        vwMain.backgroundColor = UIColor.white
        vw1.backgroundColor = UIColor.themeD9D9D9
        vw2.backgroundColor = UIColor.themeD9D9D9
        vw3.backgroundColor = UIColor.themeD9D9D9
        vw4.backgroundColor = UIColor.themeD9D9D9
        vw5.backgroundColor = UIColor.themeD9D9D9
        vwMain.layer.borderWidth = 1.0
        vwMain.layer.borderColor = UIColor.lightGray.cgColor
        lblPrice.textColor = UIColor(named: "Primary_Color")
    }
    
    func configureShareProperty(with property: Property,indexPath: IndexPath, selectedIndexPath: IndexPath?) {
        //  vwStatus.isHidden = true
//        if property.status == "Available" {
//            self.vwStatus.backgroundColor = UIColor.themeBackgroundGreenColor
//        } else if property.status == "Reserved" {
//            self.vwStatus.backgroundColor = UIColor.themePurpor
//        } else {
//            self.vwStatus.backgroundColor = UIColor.themeBackgroundRedColor
//        }
        vwMain.backgroundColor = .white
        vwMain.layer.borderWidth = 1.0
        lblPrice.textColor = UIColor(named: "Primary_Color")
        
        // Selection state
        let isSelected = (indexPath == selectedIndexPath)
        vwMain.layer.borderColor = (isSelected ? UIColor.systemBlue : UIColor.lightGray).cgColor
        if property.type == "Land" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if property.type == "Villa" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
            if property.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(property.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
        } else if property.type == "Apartment" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = false
            self.vw5.isHidden = true
            if property.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(property.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
            if property.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(property.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if property.type == "Floor" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw5.isHidden = true
            if property.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(property.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
            if property.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(property.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if property.type == "Building Complex" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if property.type == "Chalet" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if property.type == "Farm" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if property.type == "Other" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        }
        
        if let type = property.type?.localized {
            self.lblNewPropertyType?.text = type
//            if property.availableFor == "Sale" {
//                self.lblPropertyType?.text = "\(type) للبيع"
//            } else {
//                self.lblPropertyType?.text = "\(type) للإيجار"
//            }
        } else {
            //self.lblPropertyType?.text = property.type?.localized ?? "N/A"
            self.lblNewPropertyType?.text = property.type?.localized ?? "N/A"
        }
        
        self.lblPropertyType?.text = "Project Name"
        lblArea.text = "\(property.city ?? "") - \(property.neighbourhood ?? "")"
        lblPrice.text = formatPriceNew("\(property.price)")
        lblSquare.text = "\(property.area)"
        lblStatus.text = property.status?.localized
        
        let placeholder = UIImage(named: "icn_new_placeholder")
        imgPropertyThumbnail.sd_cancelCurrentImageLoad()
        imgPropertyThumbnail.image = placeholder
        
        if let urlString = property.coverImage,
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            imgPropertyThumbnail.sd_setImage(
                with: url,
                placeholderImage: placeholder,
                options: [.retryFailed, .refreshCached]
            )
        }
    }
    
    func configureProperty(with property: Property) {
        lblStatus.text = property.status?.localized
//        if property.status == "Available" {
//            self.vwStatus.backgroundColor = UIColor.themeBackgroundGreenColor
//        } else if property.status == "Reserved" {
//            self.vwStatus.backgroundColor = UIColor.themePurpor
//        } else {
//            self.vwStatus.backgroundColor = UIColor.themeBackgroundRedColor
//        }
        
        if property.type == "Land" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if property.type == "Villa" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
            if property.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(property.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
        } else if property.type == "Apartment" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = false
            self.vw5.isHidden = true
            if property.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(property.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
            if property.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(property.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if property.type == "Floor" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw5.isHidden = true
            if property.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(property.totalBedrooms ?? 0)"
            } else {
                self.vw3.isHidden = true
            }
            if property.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(property.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if property.type == "Building Complex" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if property.type == "Chalet" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if property.type == "Farm" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if property.type == "Other" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        }
        if let type = property.type?.localized {
            self.lblNewPropertyType?.text = type
//            if property.availableFor == "Sale" {
//                self.lblPropertyType?.text = "\(type) للبيع"
//            } else {
//                self.lblPropertyType?.text = "\(type) للإيجار"
//            }
        } else {
            self.lblNewPropertyType?.text = property.type?.localized ?? "N/A"
            //self.lblPropertyType?.text = property.type?.localized ?? "N/A"
        }
        
        self.lblPropertyType?.text = "Project Name"
        // Other Details
        lblArea?.text = "\(property.city ?? "") - \(property.neighbourhood ?? "")"
        lblSquare?.text = "\(property.area)"
        lblPrice?.text = formatPriceNew("\(property.price)")
        let placeholder = UIImage(named: "icn_new_placeholder")
        imgPropertyThumbnail.sd_cancelCurrentImageLoad()
        imgPropertyThumbnail.image = placeholder
        
        if let urlString = property.coverImage,
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            imgPropertyThumbnail.sd_setImage(
                with: url,
                placeholderImage: placeholder,
                options: [.retryFailed, .refreshCached]
            )
        }
    }
}
