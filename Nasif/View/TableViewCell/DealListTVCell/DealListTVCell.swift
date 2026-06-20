//
//  DealListTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 29/07/25.
//

import UIKit

class DealListTVCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwStatus: UIView?
    @IBOutlet weak var lblTime: UILabel?
    @IBOutlet weak var lblstatus: UILabel?
    @IBOutlet weak var lblID: UILabel?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblSubTitle: UILabel?
    @IBOutlet weak var img: UIImageView?
    @IBOutlet weak var lblPrice: UILabel?
    @IBOutlet weak var lblMesg: UILabel?
    @IBOutlet weak var vwMain: UIView?
    @IBOutlet weak var vwTopMenu: UIView!
    @IBOutlet weak var vwMainSquare: UIView!
    @IBOutlet weak var vwUnRead: UIView?
    @IBOutlet weak var icnMesg: UIImageView?
    @IBOutlet weak var lblRead: UILabel?
    @IBOutlet weak var lblMesgType: UILabel?
    @IBOutlet weak var stackMain: UIStackView?
    
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
    
    @IBOutlet weak var lblDealName: UILabel!
    @IBOutlet weak var imgDealName: UIImageView!
    
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
extension DealListTVCell {
    func InitConfig() {
        self.selectionStyle = .none
        
        [vw1, vw2, vw3, vw4, vw5].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }
        
        self.vw1.backgroundColor = UIColor.themeD9D9D9
        self.vw2.backgroundColor = UIColor.themeD9D9D9
        self.vw3.backgroundColor = UIColor.themeD9D9D9
        self.vw4.backgroundColor = UIColor.themeD9D9D9
        self.vw5.backgroundColor = UIColor.themeD9D9D9
        
        self.stackMain?.setRound(withBorderColor: .clear,andCornerRadious: 15.0,borderWidth: 0.0)
        
        self.vwMainSquare.layer.cornerRadius = 10.0
        self.vwMainSquare.layer.masksToBounds = true
        
        self.img?.layer.cornerRadius = 10.0
        self.img?.layer.masksToBounds = true
        
        self.vwUnRead?.layer.cornerRadius = 10
        self.vwUnRead?.layer.masksToBounds = true
        
        self.imgDealName?.layer.cornerRadius = (self.imgDealName?.frame.width ?? 0.0) / 2
        self.imgDealName?.layer.masksToBounds = true
    }
    
    func configureProperty(with objProperty: Deal) {
        self.lblID?.text = " صفقة \(objProperty.dealNo ?? 0) #"
        if objProperty.buyer?.displayName == nil || objProperty.buyer?.displayName == "" {
            self.lblDealName.text = objProperty.buyer?.mobile
        } else {
            self.lblDealName.text = objProperty.buyer?.displayName
        }
        if let avatar = objProperty.buyer?.avatar,
           let url = URL(string: avatar),
           !avatar.isEmpty {
            self.imgDealName?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
        } else {
            self.imgDealName?.image = UIImage(named: "icn_contact_placeholder")
        }
        if let type = objProperty.property?.type?.localized {
            if objProperty.property?.availableFor == "Sale" {
                self.lblTitle?.text = "\(type) للبيع"
            } else {
                self.lblTitle?.text = "\(type) للإيجار"
            }
        } else {
            self.lblTitle?.text = objProperty.property?.type?.localized ?? "N/A"
        }
        if objProperty.status == "Inquiries" {
            self.lblstatus?.text = "Inquiries".localized
            self.vwStatus?.backgroundColor = UIColor.themePrimaryColor
        } else if objProperty.status == "Negotiations"{
            self.lblstatus?.text = "Negotiations".localized
            self.vwStatus?.backgroundColor = UIColor.themeBackgroundRedColor
        } else {
            self.lblstatus?.text = "Completion".localized
            self.vwStatus?.backgroundColor = UIColor.themeBackgroundGreenColor
        }
        self.lblSubTitle?.text = "\(objProperty.property?.city ?? "") - \(objProperty.property?.neighbourhood ?? "")"
        self.lblPrice?.text = formatPriceNew("\(objProperty.property?.price ?? 0)")
        self.lblSquare?.text = "\(objProperty.property?.area ?? 0)"
        if objProperty.property?.type == "Land" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if objProperty.property?.type == "Villa" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
            if objProperty.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(objProperty.property?.totalBedrooms ?? 0)"
            } else if objProperty.property?.totalBedrooms == nil {
                self.vw3.isHidden = true
            } else {
                self.vw3.isHidden = true
            }
        } else if objProperty.property?.type == "Apartment" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw4.isHidden = false
            self.vw5.isHidden = true
            if objProperty.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(objProperty.property?.totalBedrooms ?? 0)"
            } else if objProperty.property?.totalBedrooms == nil {
                self.vw3.isHidden = true
            } else {
                self.vw3.isHidden = true
            }
            if objProperty.property?.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(objProperty.property?.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if objProperty.property?.type == "Floor" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw5.isHidden = true
            if objProperty.property?.totalBedrooms != 0 {
                self.vw3.isHidden = false
                self.lbl3.text = "\(objProperty.property?.totalBedrooms ?? 0)"
            } else if objProperty.property?.totalBedrooms == nil {
                self.vw3.isHidden = true
            } else {
                self.vw3.isHidden = true
            }
            if objProperty.property?.totalBathrooms != 0 {
                self.vw4.isHidden = false
                self.lbl4.text = "\(objProperty.property?.totalBathrooms ?? 0)"
            } else {
                self.vw4.isHidden = true
            }
        } else if objProperty.property?.type == "Building Complex" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if objProperty.property?.type == "Chalet" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if objProperty.property?.type == "Farm" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        } else if objProperty.property?.type == "Other" {
            self.vw1.isHidden = false
            self.vw2.isHidden = true
            self.vw3.isHidden = true
            self.vw4.isHidden = true
            self.vw5.isHidden = true
        }
        
        if let url = URL(string: objProperty.property?.coverImage ?? ""){
            self.img?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_new_placeholder"))
        }
        let formattedTime = formatAPIDateToTime(objProperty.lastMessage?.createdAt ?? "")
        self.lblTime?.text = formattedTime
        if objProperty.unReadMsg == 0 {
            self.vwUnRead?.isHidden = true
        } else {
            self.vwUnRead?.isHidden = false
        }
        self.lblRead?.text = "\(objProperty.unReadMsg ?? 0)"
        
        if objProperty.lastMessage?.type == "Text"  ||  objProperty.lastMessage?.type == "Title"{
            self.icnMesg?.image = UIImage(named: "icn_done")
            self.lblMesgType?.isHidden = true
            self.lblMesg?.text = objProperty.lastMessage?.text?.localized
            self.lblMesg?.isHidden = false
            self.icnMesg?.isHidden = true
        } else if objProperty.lastMessage?.type == "Image" {
            self.icnMesg?.image = UIImage(named: "icn_photo_icon")
            self.lblMesgType?.text = "Photo".localized
            self.lblMesgType?.isHidden = false
            self.lblMesg?.isHidden = true
            self.icnMesg?.isHidden = false
        } else if objProperty.lastMessage?.type == "File" {
            self.lblMesgType?.text = "File".localized
            self.icnMesg?.image = UIImage(named: "icn_file_icon")
            self.lblMesgType?.isHidden = false
            self.lblMesg?.isHidden = true
            self.icnMesg?.isHidden = false
        }
    }
}
