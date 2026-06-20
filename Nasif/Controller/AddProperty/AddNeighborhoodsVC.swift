//
//  AddNeighborhoodsVC.swift
//  Nasif
//
//  Created by Denish Gediya on 20/09/25.
//

import UIKit

class AddNeighborhoodsVC: UIViewController {
    
    @IBOutlet weak var vwclose: UIView!
    @IBOutlet weak var tblCity: UITableView!
    @IBOutlet weak var vwCity: UIView!
    
    var arrCity: [CityModel] = []
    var onDismiss: ((_ objCity: CityModel?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initConfig()
    }
    
    @IBAction func btnOnClickClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - UI Helpers
private extension AddNeighborhoodsVC {
    
    func initConfig() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
        vwclose.layer.cornerRadius = 25.0
        vwclose.layer.masksToBounds = true
        vwCity.layer.cornerRadius = 20.0
        vwCity.layer.masksToBounds = true
        setupTableView()
    }
    
    func setupTableView() {
        tblCity?.separatorStyle = .none
        tblCity?.delegate = self
        tblCity?.dataSource = self
        tblCity?.register(
            UINib(nibName: "CityTVCell", bundle: nil),
            forCellReuseIdentifier: "CityTVCell"
            
        )
        wsGetNeighborhoods()
    }
}

// MARK: - TableView Delegate & DataSource
extension AddNeighborhoodsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityTVCell", for: indexPath) as? CityTVCell else {
            return UITableViewCell()
        }
        cell.lblName?.text = self.arrCity[indexPath.row].cityEn
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.onDismiss?(self.arrCity[indexPath.row])
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Web Service Calls
private extension AddNeighborhoodsVC {
    
    func wsGetNeighborhoods() {
        Utility.showLoading()
        let url = "\(WebService.NEIGHBORHOODS)"
        
        WebServices.Get(url: url, type: [CityModel].self) { [weak self] response in
            Utility.hideLoading()
            guard let self else { return }
            guard let pageResponse = response else { return }
            self.arrCity = pageResponse
            self.tblCity.reloadData()
        }
    }
}
