//
//  EditDescriptionVC.swift
//  Nasif
//
//  Created by Denish Gediya on 17/11/25.
//

import UIKit

protocol delegateDesc {
    func desc(text: String)
}

class EditDescriptionVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var vwMain: UIView?
    @IBOutlet weak var txtDesc: UITextView?
    @IBOutlet weak var vwDesc: UIView?
    @IBOutlet weak var btnUpdate: UIButton?
    
    // MARK: - Variables
    var delegate: delegateDesc?
    var objChat: ChatMessage?
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension EditDescriptionVC {
    @IBAction func btnOnClickClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnOnClickUpdate(_ sender: UIButton) {
        if self.txtDesc?.text == "" {
            Utility.showToast(message: "Please enter group description".localized)
            return
        } else {
            wsUpdateGroupChat()
        }
    }
}

// MARK: - UI helpers
extension EditDescriptionVC {
    func InitConfig() {
        self.btnUpdate?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnUpdate?.setupButton(borderColor: .clear,andCornerRadious: 8.0)
        self.vwMain?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0.0)
        self.vwDesc?.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 0.0)
        self.setupLocalized()
        self.txtDesc?.text = self.objChat?.groupDescription
    }
    
    func setupLocalized() {
        self.btnUpdate?.setTitle("تعديل", for: .normal)
    }
}

// MARK: - Web Service Calls
extension EditDescriptionVC {
    
    func wsUpdateGroupChat() {
        Utility.showLoading()
        var dictParam: [String: Any] = [:]
        dictParam[PARAMS.GROUP_DESCRIPTION] = txtDesc?.text ?? ""
        WebServices.Put(url: "\(WebService.CHATS)\(self.objChat?.id ?? "")/", params: dictParam, type: ChatMessage.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            Utility.showToast(message: "Group update description successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.delegate?.desc(text: self.txtDesc?.text ?? "")
                self.dismiss(animated: true)
            }
        }
    }
}
