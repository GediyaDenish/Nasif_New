//
//  ArchivingVC.swift
//  Nasif
//
//  Created by Denish Gediya on 27/08/25.
//

import UIKit

class ArchivingVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tblArchiving: UITableView?
    @IBOutlet weak var lblNoData: UILabel?
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - Properties
    private var arrDeals: [Deal] = []
    private var pageInfo: DealsResponse?
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        configureRefreshControl()
        pageInfo = nil
        wsGetArchivingDeals()
    }
}

//MARK: - IBAction Mthonthd
extension ArchivingVC {
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Setup
private extension ArchivingVC {
    func configureUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle.text = "Archiving".localized
        self.lblNoData?.text = "No archiving data".localized
    }
    
    func configureTableView() {
        tblArchiving?.separatorStyle = .none
        tblArchiving?.delegate = self
        tblArchiving?.dataSource = self
        tblArchiving?.register(
            UINib(nibName: "DealListTVCell", bundle: nil),
            forCellReuseIdentifier: DealListTVCell.reuseIdentifier
        )
        tblArchiving?.refreshControl = refreshControl
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
    }
}

// MARK: - Refresh
private extension ArchivingVC {
    @objc func refreshData() {
        pageInfo = nil
        wsGetArchivingDeals()
    }
}

// MARK: - UITableView Delegate & DataSource
extension ArchivingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrDeals.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let page = self.pageInfo, page.hasNextPage, indexPath.row == self.arrDeals.count - 1 {
            self.wsGetArchivingDeals()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DealListTVCell", for: indexPath) as? DealListTVCell else {
            return UITableViewCell()
        }
        cell.configureProperty(with: arrDeals[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objDeals = arrDeals[indexPath.row]
        let storyboard = UIStoryboard(name: "Deal", bundle: nil)
        if let dealChatVC = storyboard.instantiateViewController(withIdentifier: "DealChatVC") as? DealChatVC {
            dealChatVC.objDeal = objDeals
            navigationController?.pushViewController(dealChatVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Networking
private extension ArchivingVC {
    func wsGetArchivingDeals() {
        Utility.showLoading()
        let currentPage = pageInfo?.page ?? 0
        let url = "\(WebService.DEALS)?page=\((currentPage) + 1)&size=20&sort=dealNo&archived=true"
        
        WebServices.Get(url: url, type: DealsResponse.self) { [weak self] response in
            Utility.hideLoading()
            guard let self else { return }
            DispatchQueue.main.async { self.refreshControl.endRefreshing() }
            
            guard let pageResponse = response else { return }
            DispatchQueue.main.async {
                if self.pageInfo == nil || pageResponse.totalPages == 1 {
                    self.arrDeals = pageResponse.content ?? []
                } else {
                    self.arrDeals.append(contentsOf: pageResponse.content ?? [])
                }
                self.pageInfo = pageResponse
                self.tblArchiving?.reloadData()
                
                let isEmpty = self.arrDeals.isEmpty
                self.tblArchiving?.isHidden = isEmpty
                self.lblNoData?.isHidden = !isEmpty
            }
        }
    }
}
