//
//  ListShareVC.swift
//  Nasif
//
//  Created by Denish Gediya on 11/08/25.
//

import UIKit

class ListShareVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tblList: UITableView?
    @IBOutlet weak var lblTitle: UILabel?
    
    // MARK: - Variables
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension ListShareVC {
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI helpers
fileprivate extension ListShareVC {
    func InitConfig() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.tblList?.separatorStyle = .none
        self.tblList?.delegate = self
        self.tblList?.dataSource = self
        self.lblTitle?.text = "Listings Shared".localized
        self.tblList?.register(UINib(nibName: "ListingTVCell", bundle: nil), forCellReuseIdentifier: "ListingTVCell")
    }
}

// MARK: - TableView Delegate & DataSource
extension ListShareVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListingTVCell", for: indexPath) as? ListingTVCell else {
            return UITableViewCell()
        }
        cell.configure()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Deal", bundle: nil)
        if let dealDetailVC = storyboard.instantiateViewController(withIdentifier: "DealDetailVC") as? DealDetailVC {
            self.navigationController?.pushViewController(dealDetailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
