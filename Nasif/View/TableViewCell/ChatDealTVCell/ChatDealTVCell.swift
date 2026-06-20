//
//  ChatDealTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 06/08/25.
//

import UIKit

class ChatDealTVCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var vwMainAttachment: UIView?
    @IBOutlet weak var vwSubAttachment: UIView?
    @IBOutlet weak var vwPDF: UIView?
    @IBOutlet weak var lblPDFDate: UILabel?
    @IBOutlet weak var lblPDFTime: UILabel?
    @IBOutlet weak var vwMessage: UIView?
    @IBOutlet weak var lblMesg: UILabel?
    @IBOutlet weak var lblMesgTime: UILabel?
    @IBOutlet weak var lblMesgDate: UILabel?
    @IBOutlet weak var vwMainImage: UIView?
    @IBOutlet weak var img: UIImageView?
    @IBOutlet weak var lblImageDate: UILabel?
    @IBOutlet weak var lblImageTime: UILabel?
    @IBOutlet weak var icnFile: UIImageView?
    @IBOutlet weak var icnDummyFile: UIImageView?
    @IBOutlet weak var lblPdfName: UILabel?
    @IBOutlet weak var lblMesgUser: UILabel?
    @IBOutlet weak var lblFileUser: UILabel?
    @IBOutlet weak var lblImageUser: UILabel?
    
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
extension ChatDealTVCell {
    func InitConfig() {
        self.vwMainAttachment?.layer.cornerRadius = 10.0
        self.vwMainAttachment?.layer.masksToBounds = true
        self.vwSubAttachment?.layer.cornerRadius = 10.0
        self.vwSubAttachment?.layer.masksToBounds = true
        self.vwPDF?.layer.cornerRadius = 0.0
        self.vwPDF?.layer.masksToBounds = true
        self.vwMessage?.layer.cornerRadius = 10.0
        self.vwMessage?.layer.masksToBounds = true
        self.vwMainImage?.layer.cornerRadius = 10.0
        self.vwMainImage?.layer.masksToBounds = true
        self.img?.layer.cornerRadius = 10.0
        self.img?.layer.masksToBounds = true
    }
    
    func configure(with chat: DealContent) {
        
        if chat.type == "Text"  {
            self.vwMainAttachment?.isHidden = true
            self.vwMessage?.isHidden = false
            self.vwMainImage?.isHidden = true
            self.lblMesg?.textColor = UIColor.black
        } else if chat.type == "Image" {
            self.vwMainAttachment?.isHidden = true
            self.vwMessage?.isHidden = true
            self.vwMainImage?.isHidden = false
            if let url = URL(string: chat.file ?? ""){
                self.img?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_new_placeholder"))
            }
        } else if chat.type == "File" {
            self.vwMainAttachment?.isHidden = false
            self.vwMessage?.isHidden = true
            self.vwMainImage?.isHidden = true
            self.icnFile?.isHidden = true
            self.icnDummyFile?.isHidden = false
            self.lblPdfName?.text = chat.fileName
            if let path = chat.file, let url = URL(string: path) {
                Utility.generatePDFThumbnail(from: url) { image in
                    self.icnFile?.isHidden = false
                    self.icnDummyFile?.isHidden = true
                    self.icnFile?.image = image
                }
            } else {
                print("❌ Invalid PDF URL")
            }
        } else if chat.type == "Title" {
            self.vwMainAttachment?.isHidden = true
            self.vwMessage?.isHidden = false
            self.vwMainImage?.isHidden = true
            self.lblMesg?.textColor = UIColor.themePrimaryColor
        } else {
            self.vwMainAttachment?.isHidden = true
            self.vwMessage?.isHidden = true
            self.vwMainImage?.isHidden = true
        }
        
        self.lblMesg?.text = chat.text?.localized
        self.lblFileUser?.text = chat.sender.displayName
        self.lblImageUser?.text = chat.sender.displayName
        self.lblMesgUser?.text = chat.sender.displayName
        
        let formattedTime = formatAPIDateToTime(chat.createdAt)
        self.lblMesgTime?.text = formattedTime
        self.lblImageTime?.text = formattedTime
        self.lblPDFTime?.text = formattedTime
        
        self.lblMesgDate?.text = formatDateString(chat.createdAt)
        self.lblImageDate?.text = formatDateString(chat.createdAt)
        self.lblPDFDate?.text = formatDateString(chat.createdAt)
        
    }
}
