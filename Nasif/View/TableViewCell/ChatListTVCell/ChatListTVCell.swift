//
//  ChatListTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 07/08/25.
//

import UIKit
import CoreTelephony
import Contacts

class ChatListTVCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var img: UIImageView?
    @IBOutlet weak var lblTime: UILabel?
    @IBOutlet weak var lblMesg: UILabel?
    @IBOutlet weak var imgStatus: UIImageView?
    @IBOutlet weak var lblCount: UILabel?
    @IBOutlet weak var lblstatus: UILabel?
    @IBOutlet weak var vwUnRead: UIView?
    @IBOutlet weak var lblMesgType: UILabel?
    
    @IBOutlet weak var stackLeading: NSLayoutConstraint!
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    //MARK: -  View Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.InitConfig()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func formattedChatTime(_ dateString: String) -> String {
        // API date → Date
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        guard let messageDate = formatter.date(from: dateString) else {
            return ""
        }

        let calendar = Calendar(identifier: .gregorian)

        // 🔹 If message is today → show time only
        if calendar.isDateInToday(messageDate) {
            let timeFormatter = DateFormatter()
            timeFormatter.calendar = Calendar(identifier: .gregorian)
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            timeFormatter.dateFormat = "hh:mm a"
            return timeFormatter.string(from: messageDate)
        }

        // 🔹 Yesterday check
        if calendar.isDateInYesterday(messageDate) {
            return "Yesterday".localized
        }

        // 🔹 Older → Date format
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: messageDate)
    }

    
    func configureChat(with objChat: ChatMessage) {
        if objChat.isGroup == true {
            self.lblMesg?.text = objChat.groupName
            if let avatar = objChat.groupImage,
               let url = URL(string: avatar),
               !avatar.isEmpty {
                self.img?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            } else {
                self.img?.image = UIImage(named: "icn_contact_placeholder")
            }
            
        } else {
            if objChat.isGroup ?? false {
                lblMesg?.text = objChat.groupName
            } else {
                let name = objChat.oposition?.displayName
                lblMesg?.text = (name?.isEmpty == false) ? name : objChat.oposition?.mobile
            }
            if let avatar = objChat.oposition?.avatar,
               let url = URL(string: avatar),
               !avatar.isEmpty {
                self.img?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
            } else {
                self.img?.image = UIImage(named: "icn_contact_placeholder")
            }
        }
        
        let formattedTime = self.formattedChatTime(objChat.lastMessage?.createdAt ?? "")
        self.lblTime?.text = formattedTime
        if objChat.unRead == 0 {
            self.vwUnRead?.isHidden = true
        } else {
            self.vwUnRead?.isHidden = false
        }
        self.lblCount?.text = "\(objChat.unRead ?? 0)"
        
        if objChat.lastMessage?.type == "Text"  ||  objChat.lastMessage?.type == "Title"{
            self.imgStatus?.isHidden = true
            self.stackLeading.constant = 0
            self.imgWidth.constant = 0
            self.lblMesgType?.isHidden = true
            self.lblstatus?.text = objChat.lastMessage?.text?.localized
            self.lblstatus?.isHidden = false
        } else if objChat.lastMessage?.type == "Image" {
            self.imgStatus?.isHidden = false
            self.stackLeading.constant = 5
            self.imgWidth.constant = 14
            self.imgStatus?.image = UIImage(named: "icn_photo_icon")
            self.lblMesgType?.text = "Photo".localized
            self.lblMesgType?.isHidden = false
            self.lblstatus?.isHidden = true
        } else if objChat.lastMessage?.type == "File" {
            self.imgStatus?.isHidden = false
            self.stackLeading.constant = 5
            self.imgWidth.constant = 14
            self.lblMesgType?.text = "File".localized
            self.imgStatus?.image = UIImage(named: "icn_file_icon")
            self.lblMesgType?.isHidden = false
            self.lblstatus?.isHidden = true
        } else if objChat.lastMessage?.type == "Video" {
            self.imgStatus?.isHidden = false
            self.stackLeading.constant = 5
            self.imgWidth.constant = 14
            self.lblMesgType?.text = "Video".localized
            self.imgStatus?.image = UIImage(named: "icn_video")
            self.lblMesgType?.isHidden = false
            self.lblstatus?.isHidden = true
        } else if objChat.lastMessage?.type == "Property" {
            self.imgStatus?.isHidden = false
            self.stackLeading.constant = 5
            self.imgWidth.constant = 14
            self.lblMesgType?.text = "Property".localized
            self.imgStatus?.image = UIImage(named: "icn_listing")
            self.lblMesgType?.isHidden = false
            self.lblstatus?.isHidden = true
        }
    }    
}

// MARK: - UI helpers
fileprivate extension ChatListTVCell {
    func InitConfig() {
        self.selectionStyle = .none
        self.lblCount?.layer.cornerRadius = (self.lblCount?.frame.width ?? 0.0) / 2
        self.lblCount?.layer.masksToBounds = true
        self.img?.layer.cornerRadius = (self.img?.frame.width ?? 0.0) / 2
        self.img?.layer.masksToBounds = true
        
        self.vwUnRead?.layer.cornerRadius = 10
        self.vwUnRead?.layer.masksToBounds = true
        
    }
}
