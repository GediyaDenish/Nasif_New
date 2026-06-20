//
//  AddPinView.swift
//  Nasif
//
//  Created by Denish Gediya on 17/11/25.
//

import UIKit

class AddPinView: UIView {
    
    // MARK: - IBOutlet
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var vwMainImg: UIView!
    @IBOutlet weak var imgPropertyThumbnail: UIImageView!
    @IBOutlet weak var vwStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblPropertyType: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var vwMainSub: UIView!
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
    
    @IBOutlet weak var vwPropertyType: UIView!
    @IBOutlet weak var lblNewPropertyType: UILabel!
    
    //MARK: -  View Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

// MARK: - Setup
extension AddPinView {
    
    func setupUI() {
        [vwMain, vw1, vw2, vw3, vw4, vw5].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }
        
        //        vwMainSub.layer.cornerRadius = 10.0
        //        vwMainSub.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        //        vwMainSub.layer.masksToBounds = true
        //
        //        vwMainSub.layer.borderColor = UIColor.black.cgColor
        //        vwMainSub.layer.borderWidth = 1.0
        
        vw1.backgroundColor = UIColor.themeD9D9D9
        vw2.backgroundColor = UIColor.themeD9D9D9
        vw3.backgroundColor = UIColor.themeD9D9D9
        vw4.backgroundColor = UIColor.themeD9D9D9
        vw5.backgroundColor = UIColor.themeD9D9D9
        
        vwPropertyType.layer.cornerRadius = 10
        vwPropertyType.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        vwStatus.layer.cornerRadius = 10
        vwStatus.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        vwMainImg.layer.cornerRadius = 10
        vwMainImg.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                         .layerMaxXMaxYCorner]   // bottom-right
        vwMainImg.layer.masksToBounds = true
        //        vwMainImg.layer.borderWidth = 1.5
        //        vwMainImg.layer.borderColor = UIColor.theme999999.cgColor
        
        imgPropertyThumbnail.layer.cornerRadius = 10
        imgPropertyThumbnail.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                                    .layerMaxXMaxYCorner]   // bottom-right
        imgPropertyThumbnail.layer.masksToBounds = true
    }
    
    func configureWith(property: Property, priceFormatter: ((Int) -> String)? = nil) {
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
        
//        if property.status == "Available" {
//            self.vwStatus.backgroundColor = UIColor.themeBackgroundGreenColor
//        } else if property.status == "Reserved" {
//            self.vwStatus.backgroundColor = UIColor.themePurpor
//        } else {
//            self.vwStatus.backgroundColor = UIColor.themeBackgroundRedColor
//        }
        
        let placeholder = UIImage(named: "icn_new_placeholder")
        imgPropertyThumbnail.sd_cancelCurrentImageLoad()
        if let urlString = property.coverImage, let url = URL(string: urlString) {
            imgPropertyThumbnail.sd_setImage(with: url, placeholderImage: placeholder, options: [.retryFailed, .refreshCached])
        } else {
            imgPropertyThumbnail.image = placeholder
        }
        
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
    }
}

