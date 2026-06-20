//
//  TermsVC.swift
//  Nasif
//
//  Created by Denish Gediya on 22/09/25.
//

import UIKit

class TermsVC: UIViewController {

    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var lblText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vwMain.layer.cornerRadius = 20.0
        self.vwMain.layer.masksToBounds = true
    }
    
    @IBAction func btnOnClickClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

}
