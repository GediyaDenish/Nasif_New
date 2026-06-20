//
//  ChatTVCell.swift
//  Nasif
//
//  Created by Denish Gediya on 14/08/25.
//

import UIKit
import AVKit
import AVFoundation

class ChatTVCell: UITableViewCell, LinkHandlerDelegate {
    func handleJoinGroup(groupId: String) {
           print("📨 Forwarding GroupID From Cell → VC")
           parentDelegate?.handleJoinGroup(groupId: groupId)
       }
    
    
    @IBOutlet weak var vwFirstMesg: UIView!
    @IBOutlet weak var vwSubFirstMesg: UIView!
    
    
    @IBOutlet var vwSubMenu: [UIView]!
    
    @IBOutlet weak var lblFirstMesgTime: UILabel!
    @IBOutlet weak var vwSubRightFirstMesg: UIView!
    @IBOutlet weak var lblFirstMesg: UILabel!
    @IBOutlet weak var btnRightPlay: UIButton!
    @IBOutlet weak var vwRightFirstMesg: UIView!
    @IBOutlet weak var lblRightFirstMesg: UILabel!
    @IBOutlet weak var lblRightFirstMesgTime: UILabel!
    
    @IBOutlet weak var btnLeftPlay: UIButton!
    @IBOutlet weak var lblvideoDate: UILabel!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var vwLeftVideo: UIView!
    @IBOutlet weak var vwSubVideoView: UIView!
    
    @IBOutlet weak var vwLeftMainVideoView: ChatBubbleView!
    @IBOutlet weak var lblVideoUploadName: UILabel!
    
    @IBOutlet weak var thumbnailImageViewRight: UIImageView!
    @IBOutlet weak var thumbnailImageViewLeft: UIImageView!
    
    @IBOutlet weak var lblRightvideoDate: UILabel!
    @IBOutlet weak var lblRightVideoTime: UILabel!
    @IBOutlet weak var vwRightVideo: UIView!
    @IBOutlet weak var vwSubRightVideoView: UIView!
    
    @IBOutlet weak var vwRightMainVideoView: ChatBubbleView!
    @IBOutlet weak var lblRightVideoUploadName: UILabel!
    
    @IBOutlet weak var vwLeftFile: UIView?
    @IBOutlet weak var vwLeftFileView: ChatBubbleView!
    @IBOutlet weak var vwSubAttachment: UIView!
    @IBOutlet weak var vwPDF: UIView!
    @IBOutlet weak var lblLeftFileName: UILabel?
    @IBOutlet weak var lblLeftFileTime: UILabel?
    @IBOutlet weak var lblLeftFileDate: UILabel?
    
    @IBOutlet weak var icnFile: UIImageView?
    @IBOutlet weak var icnDummyFile: UIImageView?
    @IBOutlet weak var vwLeftDeal: UIView?
    @IBOutlet weak var lblLeftDealName: UILabel?
    @IBOutlet weak var lblLeftDealCity: UILabel?
    @IBOutlet weak var lblLeftDealPrice: UILabel?
    @IBOutlet weak var lblLeftDealImage: UIImageView?
    @IBOutlet weak var lblLeftDealSubView: UIView?
    
    @IBOutlet weak var vwLeftImageDeal: UIView!
    @IBOutlet weak var vwLeft1: UIView!
    @IBOutlet weak var vwLeft2: UIView!
    @IBOutlet weak var vwLeft3: UIView!
    @IBOutlet weak var vwLeft4: UIView!
    @IBOutlet weak var vwLeft5: UIView!
    
    @IBOutlet private weak var lblLeftDealArea: UILabel!
    @IBOutlet weak var lblLeft2: UILabel!
    @IBOutlet weak var lblLeft3: UILabel!
    @IBOutlet weak var lblLeft4: UILabel!
    @IBOutlet weak var lblLeft5: UILabel!
    
    @IBOutlet weak var vwStatusLeft: UIView!
    @IBOutlet weak var lblLeftStatus: UILabel!
    @IBOutlet weak var lblLeftDealMainView: ChatBubbleView!
    @IBOutlet weak var vwLeftImage: UIView?
    
    @IBOutlet weak var vwLeftImageMainView: ChatBubbleView!
    @IBOutlet weak var vwLeftSubImageView: UIView?
    @IBOutlet weak var imgLeft: UIImageView?
    @IBOutlet weak var lblLeftImageTime: UILabel?
    @IBOutlet weak var lblLeftImageDate: UILabel?
    
    
    @IBOutlet weak var vwLeftMesgMainView: ChatBubbleView!
    @IBOutlet weak var lblLeftMesgTime: UILabel?
    
    @IBOutlet weak var lblLeftMesg: CopyableLabel!
    @IBOutlet weak var lblLeftMesgDate: UILabel?
    @IBOutlet weak var vwLeftMesg: UIView?
    
    @IBOutlet weak var icnRightImageFile: UIImageView?
    @IBOutlet weak var icnRightDummyFile: UIImageView?
    @IBOutlet weak var vwRightFile: UIView?
    
    @IBOutlet weak var vwRightFileView: ChatBubbleView!
    @IBOutlet weak var lblRightSendFileName: UILabel!
    @IBOutlet weak var vwRightSubAttachment: UIView!
    @IBOutlet weak var vwRightPDF: UIView!
    @IBOutlet weak var lblRightFileName: UILabel?
    @IBOutlet weak var lblRightFileTime: UILabel?
    @IBOutlet weak var lblRightFileDate: UILabel?
    
    @IBOutlet weak var vwRightDeal: UIView?
    @IBOutlet weak var lblRightDealName: UILabel?
    @IBOutlet weak var lblRightDealCity: UILabel?
    @IBOutlet weak var lblRightDealPrice: UILabel?
    @IBOutlet weak var lblRightDealImage: UIImageView?
    @IBOutlet weak var lblRightDealSubView: UIView?
    @IBOutlet weak var lblRightDealMainView: ChatBubbleView!
    
    @IBOutlet weak var vwRight1: UIView!
    @IBOutlet weak var vwRight2: UIView!
    @IBOutlet weak var vwRight3: UIView!
    @IBOutlet weak var vwRight4: UIView!
    @IBOutlet weak var vwRight5: UIView!
    
    @IBOutlet private weak var lblRightDealArea: UILabel!
    @IBOutlet weak var lblRight2: UILabel!
    @IBOutlet weak var lblRight3: UILabel!
    @IBOutlet weak var lblRight4: UILabel!
    @IBOutlet weak var lblRight5: UILabel!
    
    @IBOutlet weak var vwRightImage: UIView?
    @IBOutlet weak var vwRightImageMainView: ChatBubbleView!
    @IBOutlet weak var vwrightSubImageView: UIView?
    @IBOutlet weak var imgRight: UIImageView?
    @IBOutlet weak var lblImageTime: UILabel?
    @IBOutlet weak var lblImageDate: UILabel?
    
    @IBOutlet weak var vwRightMesgMainView: ChatBubbleView!
    @IBOutlet weak var lblRightMesgTime: UILabel?
    
    @IBOutlet weak var lblRightMesg: CopyableLabel!
    @IBOutlet weak var lblRightMesgDate: UILabel?
    @IBOutlet weak var vwRightMesg: UIView?
    
    @IBOutlet weak var lblSendFileName: UILabel!
    @IBOutlet weak var lblLeftSenderMesgName: UILabel!
    @IBOutlet weak var lblLeftImageSenderName: UILabel!
    @IBOutlet weak var lblLeftSenertPropertyName: UILabel!
    
    @IBOutlet weak var lblRightReciverMesgName: UILabel!
    @IBOutlet weak var lblRightImageReceiverName: UILabel!
    @IBOutlet weak var lblRightReceiverPropertyName: UILabel!
    
    @IBOutlet weak var lblRightPropertyTime: UILabel!
    @IBOutlet weak var lblLeftPropertyTime: UILabel!
    @IBOutlet weak var vwRightStatus: UIView!
    @IBOutlet weak var vwRightMainImageDeal: UIView!
    @IBOutlet weak var lblRightStatus: UILabel!
    
    private var videoURL: URL?
    weak var parentDelegate: LinkHandlerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        [vwRight1, vwRight2, vwRight3, vwRight4, vwRight5, vwLeft1, vwLeft2, vwLeft3, vwLeft4, vwLeft5].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
            $0?.backgroundColor = UIColor.themeD9D9D9
        }
        
        vwRightMainImageDeal.layer.cornerRadius = 10
        vwRightMainImageDeal.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                                    .layerMaxXMaxYCorner]
        vwRightMainImageDeal.layer.masksToBounds = true
        
        lblRightDealImage?.layer.cornerRadius = 10
        lblRightDealImage?.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                                  .layerMaxXMaxYCorner]
        lblRightDealImage?.layer.masksToBounds = true
        
        vwStatusLeft.layer.cornerRadius = 10
        vwStatusLeft.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        vwRightStatus.layer.cornerRadius = 10
        vwRightStatus.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        vwLeftImageDeal.layer.cornerRadius = 10
        vwLeftImageDeal.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                               .layerMaxXMaxYCorner]   // bottom-right
        vwLeftImageDeal.layer.masksToBounds = true
        
        lblLeftDealImage?.layer.cornerRadius = 10
        lblLeftDealImage?.layer.maskedCorners = [.layerMaxXMinYCorner,   // top-right
                                                 .layerMaxXMaxYCorner]   // bottom-right
        lblLeftDealImage?.layer.masksToBounds = true
        
        self.vwLeftFileView?.layer.cornerRadius = 10.0
        self.vwLeftFileView?.layer.masksToBounds = true
        
        self.lblLeftDealImage?.layer.cornerRadius = 10.0
        self.lblLeftDealImage?.layer.masksToBounds = true
        
        self.imgLeft?.layer.cornerRadius = 10.0
        self.imgLeft?.layer.masksToBounds = true
        
        self.imgRight?.layer.cornerRadius = 10.0
        self.imgRight?.layer.masksToBounds = true
        
        self.thumbnailImageViewLeft?.layer.cornerRadius = 10.0
        self.thumbnailImageViewLeft?.layer.masksToBounds = true
        
        self.thumbnailImageViewRight?.layer.cornerRadius = 10.0
        self.thumbnailImageViewRight?.layer.masksToBounds = true
        
        self.vwLeftFileView?.layer.cornerRadius = 10.0
        self.vwLeftFileView?.layer.masksToBounds = true
        
        self.vwSubAttachment?.layer.cornerRadius = 10.0
        self.vwSubAttachment?.layer.masksToBounds = true
        
        self.vwPDF?.layer.cornerRadius = 0.0
        self.vwPDF?.layer.masksToBounds = true
        
        self.vwRightFileView?.layer.cornerRadius = 10.0
        self.vwRightFileView?.layer.masksToBounds = true
        
        self.lblRightDealMainView?.layer.cornerRadius = 10.0
        self.lblRightDealMainView?.layer.masksToBounds = true
        
        self.vwRightImageMainView?.layer.cornerRadius = 10.0
        self.vwRightImageMainView?.layer.masksToBounds = true
        
        self.vwRightMesgMainView?.layer.cornerRadius = 10.0
        self.vwRightMesgMainView?.layer.masksToBounds = true
        
        self.vwLeftFileView?.layer.cornerRadius = 10.0
        self.vwLeftFileView?.layer.masksToBounds = true
        
        self.lblLeftDealMainView?.layer.cornerRadius = 10.0
        self.lblLeftDealMainView?.layer.masksToBounds = true
        
        self.vwLeftImageMainView?.layer.cornerRadius = 10.0
        self.vwLeftImageMainView?.layer.masksToBounds = true
        
        self.vwLeftMesgMainView?.layer.cornerRadius = 10.0
        self.vwLeftMesgMainView?.layer.masksToBounds = true
        
        self.vwLeftMainVideoView?.layer.cornerRadius = 10.0
        self.vwLeftMainVideoView?.layer.masksToBounds = true
        
        self.vwRightMainVideoView?.layer.cornerRadius = 10.0
        self.vwRightMainVideoView?.layer.masksToBounds = true
        
        self.lblLeftDealSubView?.layer.cornerRadius = 10.0
        self.lblLeftDealSubView?.layer.masksToBounds = true
        
        self.lblRightDealSubView?.layer.cornerRadius = 10.0
        self.lblRightDealSubView?.layer.masksToBounds = true
        
        self.vwRightSubAttachment?.layer.cornerRadius = 10.0
        self.vwRightSubAttachment?.layer.masksToBounds = true
        self.vwRightPDF?.layer.cornerRadius = 0.0
        self.vwRightPDF?.layer.masksToBounds = true
        
        // Gesture only once
        lblLeftMesg.isUserInteractionEnabled = true
        lblRightMesg.isUserInteractionEnabled = true
        
        lblLeftMesg.numberOfLines = 0
        lblLeftMesg.lineBreakMode = .byWordWrapping
        
        lblRightMesg.numberOfLines = 0
        lblRightMesg.lineBreakMode = .byWordWrapping
        
        self.setupBubble()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func btnOnClickLeftPlay(_ sender: UIButton) {
    }
    
    
    @IBAction func btnOnClickRightPlay(_ sender: UIButton) {
    }
    
    func setupBubble() {
        self.vwLeftMesgMainView.isFromCurrentUser = true
        self.vwLeftMesgMainView.bubbleColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        //  self.vwSubFirstMesg.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        self.vwLeftFileView.isFromCurrentUser = true
        self.vwLeftFileView.bubbleColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        self.lblLeftDealMainView.isFromCurrentUser = true
        self.lblLeftDealMainView.bubbleColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        self.vwLeftImageMainView.isFromCurrentUser = true
        self.vwLeftImageMainView.bubbleColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        self.vwLeftMainVideoView.isFromCurrentUser = true
        self.vwLeftMainVideoView.bubbleColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        self.vwRightMesgMainView.isFromCurrentUser = false
        self.vwRightMesgMainView.bubbleColor = UIColor(red: 217/255, green: 242/255, blue: 251/255, alpha: 1.0)
        
        //    self.vwSubRightFirstMesg.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        self.vwRightImageMainView.isFromCurrentUser = false
        self.vwRightImageMainView.bubbleColor = UIColor(red: 217/255, green: 242/255, blue: 251/255, alpha: 1.0)
        
        self.vwRightFileView.isFromCurrentUser = false
        self.vwRightFileView.bubbleColor = UIColor(red: 217/255, green: 242/255, blue: 251/255, alpha: 1.0)
        
        self.lblRightDealMainView.isFromCurrentUser = false
        self.lblRightDealMainView.bubbleColor = UIColor(red: 217/255, green: 242/255, blue: 251/255, alpha: 1.0)
        
        self.vwRightMainVideoView.isFromCurrentUser = false
        self.vwRightMainVideoView.bubbleColor = UIColor(red: 217/255, green: 242/255, blue: 251/255, alpha: 1.0)
        
        self.vwSubMenu.forEach({
            $0.layer.cornerRadius = 8.0
            $0.layer.masksToBounds = true
        })
        
    }
    
    func configure(with chat: ChatGroupMessage) {
        self.setupBubble()
        if UserDefaultsHelper.getUserFromDefaults()?.userId != chat.sender?.id {
            if chat.type == "Text"  {
                self.vwFirstMesg?.isHidden = true
                self.vwRightFirstMesg?.isHidden = true
                self.vwLeftMesg?.isHidden = false
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                self.lblLeftMesg?.text = chat.text?.localized
                lblLeftMesg.text = chat.text?.localized
                lblLeftMesg.linkDelegate = self
                DispatchQueue.main.async { self.lblLeftMesg.enableClickableLinks() }
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblLeftMesgTime?.text = formattedTime
                self.lblLeftMesgDate?.text = formatDateString(chat.createdAt ?? "")
                self.lblLeftSenderMesgName.text = chat.sender?.displayName
                self.lblLeftSenderMesgName.isHidden = false
            } else if chat.type == "Image" {
                self.vwFirstMesg?.isHidden = true
                self.vwRightFirstMesg?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = false
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                if let url = URL(string: chat.file ?? ""){
                    self.imgLeft?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_new_placeholder"))
                }
                self.lblLeftImageSenderName.text = chat.sender?.displayName
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblLeftImageTime?.text = formattedTime
                self.lblLeftImageDate?.text = formatDateString(chat.createdAt ?? "")
                self.lblLeftImageSenderName.isHidden = false
            } else if chat.type == "Video" {
                self.vwFirstMesg?.isHidden = true
                self.vwRightFirstMesg?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = false
                self.videoURL = URL(string: chat.file ?? "")
                btnLeftPlay.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
                if let videoURL = self.videoURL {
                    Utility.generateThumbnail(url: videoURL) { image in
                        if let thumbnail = image {
                            self.thumbnailImageViewLeft.image = thumbnail
                            self.thumbnailImageViewLeft.contentMode = .scaleAspectFill
                            self.thumbnailImageViewLeft.clipsToBounds = true
                        }
                    }
                }
                self.lblVideoUploadName.text = chat.sender?.displayName
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblVideoTime?.text = formattedTime
                self.lblvideoDate?.text = formatDateString(chat.createdAt ?? "")
                self.lblVideoUploadName.isHidden = false
            }else if chat.type == "File" {
                self.vwFirstMesg?.isHidden = true
                self.vwRightFirstMesg?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = false
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.icnFile?.isHidden = true
                self.icnDummyFile?.isHidden = false
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                if let path = chat.file, let url = URL(string: path) {
                    Utility.generatePDFThumbnail(from: url) { image in
                        self.icnFile?.isHidden = false
                        self.icnDummyFile?.isHidden = true
                        self.icnFile?.image = image
                    }
                } else {
                    print("❌ Invalid PDF URL")
                }
                self.lblSendFileName.text = chat.sender?.displayName
                self.lblLeftFileName?.text = chat.fileName
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblLeftFileTime?.text = formattedTime
                self.lblLeftFileDate?.text = formatDateString(chat.createdAt ?? "")
                self.lblSendFileName.isHidden = false
            } else if chat.type == "Title" {
                self.vwFirstMesg?.isHidden = false
                self.vwRightFirstMesg?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                self.lblFirstMesg?.text = chat.text?.localized
                let formattedTime = formatNewAPIDateToTime(chat.createdAt ?? "")
                self.lblFirstMesgTime?.text = formattedTime
            } else if chat.type == "Property" {
                self.vwFirstMesg?.isHidden = true
                self.vwRightFirstMesg?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = false
                self.vwLeftFile?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                self.lblLeftSenertPropertyName.text = chat.sender?.displayName
                if let type = chat.property?.type?.localized {
                    if chat.property?.availableFor == "Sale" {
                        self.lblLeftDealName?.text = "\(type) للبيع"
                    } else {
                        self.lblLeftDealName?.text = "\(type) للإيجار"
                    }
                } else {
                    self.lblLeftDealName?.text = chat.property?.type?.localized ?? "N/A"
                }
                self.lblLeftStatus.text = chat.property?.status?.localized
                if chat.property?.status == "Available" {
                    self.vwStatusLeft.backgroundColor = UIColor.themeBackgroundGreenColor
                } else if chat.property?.status == "Reserved" {
                    self.vwStatusLeft.backgroundColor = UIColor.themePurpor
                } else {
                    self.vwStatusLeft.backgroundColor = UIColor.themeBackgroundRedColor
                }
                self.lblLeftDealCity?.text = "\(chat.property?.city ?? "") - \(chat.property?.neighbourhood ?? "")"
                self.lblLeftDealArea?.text = "\(chat.property?.area ?? 0.0)"
                if chat.property?.type == "Land" {
                    self.vwLeft1.isHidden = false
                    self.vwLeft2.isHidden = true
                    self.vwLeft3.isHidden = true
                    self.vwLeft4.isHidden = true
                    self.vwLeft5.isHidden = true
                } else if chat.property?.type == "Villa" {
                    self.vwLeft1.isHidden = false
                    self.vwLeft2.isHidden = true
                    self.vwLeft4.isHidden = true
                    self.vwLeft5.isHidden = true
                    if chat.property?.totalBedrooms != 0 {
                        self.vwLeft3.isHidden = false
                        self.lblLeft3.text = "\(chat.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vwLeft3.isHidden = true
                    }
                } else if chat.property?.type == "Apartment" {
                    self.vwLeft1.isHidden = false
                    self.vwLeft2.isHidden = true
                    self.vwLeft4.isHidden = false
                    self.vwLeft5.isHidden = true
                    if chat.property?.totalBedrooms != 0 {
                        self.vwLeft3.isHidden = false
                        self.lblLeft3.text = "\(chat.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vwLeft3.isHidden = true
                    }
                    if chat.property?.totalBathrooms != 0 {
                        self.vwLeft4.isHidden = false
                        self.lblLeft4.text = "\(chat.property?.totalBathrooms ?? 0)"
                    } else {
                        self.vwLeft4.isHidden = true
                    }
                } else if chat.property?.type == "Floor" {
                    self.vwLeft1.isHidden = false
                    self.vwLeft2.isHidden = true
                    self.vwLeft5.isHidden = true
                    if chat.property?.totalBedrooms != 0 {
                        self.vwLeft3.isHidden = false
                        self.lblLeft3.text = "\(chat.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vwLeft3.isHidden = true
                    }
                    if chat.property?.totalBathrooms != 0 {
                        self.vwLeft4.isHidden = false
                        self.lblLeft4.text = "\(chat.property?.totalBathrooms ?? 0)"
                    } else {
                        self.vwLeft4.isHidden = true
                    }
                } else if chat.property?.type == "Building Complex" {
                    self.vwLeft1.isHidden = false
                    self.vwLeft2.isHidden = true
                    self.vwLeft3.isHidden = true
                    self.vwLeft4.isHidden = true
                    self.vwLeft5.isHidden = true
                } else if chat.property?.type == "Chalet" {
                    self.vwLeft1.isHidden = false
                    self.vwLeft2.isHidden = true
                    self.vwLeft3.isHidden = true
                    self.vwLeft4.isHidden = true
                    self.vwLeft5.isHidden = true
                } else if chat.property?.type == "Farm" {
                    self.vwLeft1.isHidden = false
                    self.vwLeft2.isHidden = true
                    self.vwLeft3.isHidden = true
                    self.vwLeft4.isHidden = true
                    self.vwLeft5.isHidden = true
                } else if chat.property?.type == "Other" {
                    self.vwLeft1.isHidden = false
                    self.vwLeft2.isHidden = true
                    self.vwLeft3.isHidden = true
                    self.vwLeft4.isHidden = true
                    self.vwLeft5.isHidden = true
                }
                self.lblLeftDealPrice?.text = formatPriceNew("\(chat.property?.price ?? 0)")
                if let urlString = chat.property?.coverImage, let url = URL(string: urlString) {
                    self.lblLeftDealImage?.sd_setImage(
                        with: url,
                        placeholderImage: UIImage(named: "icn_new_placeholder")
                    )
                } else {
                    self.lblLeftDealImage?.image = UIImage(named: "icn_new_placeholder")
                }
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblLeftPropertyTime?.text = formattedTime
                self.lblLeftSenertPropertyName.isHidden = false
            } else {
                self.vwFirstMesg?.isHidden = true
                self.vwRightFirstMesg?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
            }
        } else {
            if chat.type == "Text"  {
                self.vwRightMesg?.isHidden = false
                self.vwRightFirstMesg?.isHidden = true
                self.vwFirstMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                self.lblRightMesg?.text = chat.text?.localized
                lblRightMesg.text = chat.text?.localized
                lblRightMesg.linkDelegate = self
                DispatchQueue.main.async { self.lblRightMesg.enableClickableLinks() }
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblRightMesgTime?.text = formattedTime
                self.lblRightMesgDate?.text = formatDateString(chat.createdAt ?? "")
                self.lblRightReciverMesgName.text = chat.sender?.displayName
                self.lblRightReciverMesgName.textColor = UIColor.color(for: chat.sender?.displayName)
            } else if chat.type == "Image" {
                self.vwRightFirstMesg?.isHidden = true
                self.vwFirstMesg?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = false
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                if let url = URL(string: chat.file ?? ""){
                    self.imgRight?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_new_placeholder"))
                }
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblImageTime?.text = formattedTime
                self.lblImageDate?.text = formatDateString(chat.createdAt ?? "")
                self.lblRightImageReceiverName.text = chat.sender?.displayName
                self.lblRightImageReceiverName.textColor = UIColor.color(for: chat.sender?.displayName)
            } else if chat.type == "Video" {
                self.vwRightFirstMesg?.isHidden = true
                self.vwFirstMesg?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightVideo?.isHidden = false
                self.vwLeftVideo?.isHidden = true
                self.videoURL = URL(string: chat.file ?? "")
                btnRightPlay.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
                if let videoURL = self.videoURL {
                    Utility.generateThumbnail(url: videoURL) { image in
                        if let thumbnail = image {
                            self.thumbnailImageViewRight.image = thumbnail
                            self.thumbnailImageViewRight.contentMode = .scaleAspectFill
                            self.thumbnailImageViewRight.clipsToBounds = true
                        }
                    }
                }
                
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblRightVideoTime?.text = formattedTime
                self.lblRightvideoDate?.text = formatDateString(chat.createdAt ?? "")
                self.lblRightVideoUploadName.text = chat.sender?.displayName
                self.lblRightVideoUploadName.textColor = UIColor.color(for: chat.sender?.displayName)
                
            } else if chat.type == "File" {
                self.vwRightFirstMesg?.isHidden = true
                self.vwFirstMesg?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = false
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.icnRightImageFile?.isHidden = true
                self.icnRightDummyFile?.isHidden = false
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                if let path = chat.file, let url = URL(string: path) {
                    Utility.generatePDFThumbnail(from: url) { image in
                        self.icnRightImageFile?.isHidden = false
                        self.icnRightDummyFile?.isHidden = true
                        self.icnRightImageFile?.image = image
                    }
                } else {
                    print("❌ Invalid PDF URL")
                }
                self.lblRightSendFileName.text = chat.sender?.displayName
                self.lblRightSendFileName.textColor = UIColor.color(for: chat.sender?.displayName)
                
                self.lblRightFileName?.text = chat.fileName
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblRightFileTime?.text = formattedTime
                self.lblRightFileDate?.text = formatDateString(chat.createdAt ?? "")
            } else if chat.type == "Title" {
                self.vwRightFirstMesg?.isHidden = false
                self.vwFirstMesg?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                self.lblRightFirstMesg?.text = chat.text?.localized
                let formattedTime = formatNewAPIDateToTime(chat.createdAt ?? "")
                self.lblRightFirstMesgTime?.text = formattedTime
            } else if chat.type == "Property" {
                self.vwRightFirstMesg?.isHidden = true
                self.vwFirstMesg?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = false
                self.vwRightFile?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
                self.lblRightReceiverPropertyName.text = chat.sender?.displayName
                self.lblRightReceiverPropertyName.textColor = UIColor.color(for: chat.sender?.displayName)
                self.lblRightStatus.text = chat.property?.status?.localized
                if chat.property?.status == "Available" {
                    self.vwRightStatus.backgroundColor = UIColor.themeBackgroundGreenColor
                } else if chat.property?.status == "Reserved" {
                    self.vwRightStatus.backgroundColor = UIColor.themePurpor
                }  else {
                    self.vwRightStatus.backgroundColor = UIColor.themeBackgroundRedColor
                }
                
                if let type = chat.property?.type?.localized {
                    if chat.property?.availableFor == "Sale" {
                        self.lblRightDealName?.text = "\(type) للبيع"
                    } else {
                        self.lblRightDealName?.text = "\(type) للإيجار"
                    }
                } else {
                    self.lblRightDealName?.text = chat.property?.type?.localized ?? "N/A"
                }
                self.lblRightDealCity?.text = "\(chat.property?.city ?? "") - \(chat.property?.neighbourhood ?? "")"
                self.lblRightDealArea?.text = "\(chat.property?.area ?? 0.0)"
                if chat.property?.type == "Land" {
                    self.vwRight1.isHidden = false
                    self.vwRight2.isHidden = true
                    self.vwRight3.isHidden = true
                    self.vwRight4.isHidden = true
                    self.vwRight5.isHidden = true
                } else if chat.property?.type == "Villa" {
                    self.vwRight1.isHidden = false
                    self.vwRight2.isHidden = true
                    self.vwRight4.isHidden = true
                    self.vwRight5.isHidden = true
                    if chat.property?.totalBedrooms != 0 {
                        self.vwRight3.isHidden = false
                        self.lblRight3.text = "\(chat.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vwRight3.isHidden = true
                    }
                } else if chat.property?.type == "Apartment" {
                    self.vwRight1.isHidden = false
                    self.vwRight2.isHidden = true
                    self.vwRight5.isHidden = true
                    if chat.property?.totalBedrooms != 0 {
                        self.vwRight3.isHidden = false
                        self.lblRight3.text = "\(chat.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vwRight3.isHidden = true
                    }
                    if chat.property?.totalBathrooms != 0 {
                        self.vwRight4.isHidden = false
                        self.lblRight4.text = "\(chat.property?.totalBathrooms ?? 0)"
                    } else {
                        self.vwRight4.isHidden = true
                    }
                } else if chat.property?.type == "Floor" {
                    self.vwRight1.isHidden = false
                    self.vwRight2.isHidden = true
                    self.vwRight5.isHidden = true
                    if chat.property?.totalBedrooms != 0 {
                        self.vwRight3.isHidden = false
                        self.lblRight3.text = "\(chat.property?.totalBedrooms ?? 0)"
                    } else {
                        self.vwRight3.isHidden = true
                    }
                    if chat.property?.totalBathrooms != 0 {
                        self.vwRight4.isHidden = false
                        self.lblRight4.text = "\(chat.property?.totalBathrooms ?? 0)"
                    } else {
                        self.vwRight4.isHidden = true
                    }
                } else if chat.property?.type == "Building Complex" {
                    self.vwRight1.isHidden = false
                    self.vwRight2.isHidden = true
                    self.vwRight3.isHidden = true
                    self.vwRight4.isHidden = true
                    self.vwRight5.isHidden = true
                } else if chat.property?.type == "Chalet" {
                    self.vwRight1.isHidden = false
                    self.vwRight2.isHidden = true
                    self.vwRight3.isHidden = true
                    self.vwRight4.isHidden = true
                    self.vwRight5.isHidden = true
                } else if chat.property?.type == "Farm" {
                    self.vwRight1.isHidden = false
                    self.vwRight2.isHidden = true
                    self.vwRight3.isHidden = true
                    self.vwRight4.isHidden = true
                    self.vwRight5.isHidden = true
                } else if chat.property?.type == "Other" {
                    self.vwRight1.isHidden = false
                    self.vwRight2.isHidden = true
                    self.vwRight3.isHidden = true
                    self.vwRight4.isHidden = true
                    self.vwRight5.isHidden = true
                }
                
                self.lblRightDealPrice?.text = formatPriceNew("\(chat.property?.price ?? 0)")
                if let urlString = chat.property?.coverImage, let url = URL(string: urlString) {
                    self.lblRightDealImage?.sd_setImage(
                        with: url,
                        placeholderImage: UIImage(named: "icn_new_placeholder")
                    )
                } else {
                    self.lblRightDealImage?.image = UIImage(named: "icn_new_placeholder")
                }
                let formattedTime = formatAPIDateToTime(chat.createdAt ?? "")
                self.lblRightPropertyTime?.text = formattedTime
            } else {
                self.vwRightFirstMesg?.isHidden = true
                self.vwFirstMesg?.isHidden = true
                self.vwRightMesg?.isHidden = true
                self.vwRightImage?.isHidden = true
                self.vwRightDeal?.isHidden = true
                self.vwRightFile?.isHidden = true
                self.vwLeftMesg?.isHidden = true
                self.vwLeftImage?.isHidden = true
                self.vwLeftDeal?.isHidden = true
                self.vwLeftFile?.isHidden = true
                self.vwRightVideo?.isHidden = true
                self.vwLeftVideo?.isHidden = true
            }
        }
    }
}

extension ChatTVCell {
    
    @objc private func playTapped() {
        guard let url = videoURL else { return }
        
        let player = AVPlayer(url: url)
        let playerVC = VideoPlayerVC() // <-- custom controller
        playerVC.videoURL = url
        playerVC.player = player
        
        let nav = UINavigationController(rootViewController: playerVC)
        nav.modalPresentationStyle = .fullScreen
        
        if let topVC = UIApplication.topViewControllerNew() {
            topVC.present(nav, animated: true) {
                player.play()
            }
        }
    }
}

extension UIApplication {
    class func topViewControllerNew(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first?.windows.first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
            
            if let nav = base as? UINavigationController {
                return topViewController(base: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                return topViewController(base: tab.selectedViewController)
            }
            if let presented = base?.presentedViewController {
                return topViewController(base: presented)
            }
            return base
        }
}
