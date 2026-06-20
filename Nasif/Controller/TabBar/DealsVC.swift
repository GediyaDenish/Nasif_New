//
//  DealsVC.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit

class DealsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tblListing: UITableView?
    @IBOutlet private weak var vwSubMenu: UIView?
    @IBOutlet private weak var txtSearch: UITextField?
    @IBOutlet private weak var vwSearch: UIView?
    @IBOutlet private weak var btnCreate: UIButton?
    @IBOutlet private weak var btnCancel: UIButton?
    @IBOutlet private weak var lblNoData: UILabel?
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - Properties
    private var arrDeals: [Deal] = []
    private var filteredDeals: [Deal] = []
    private var isSearching: Bool = false
    private var pageInfo: DealsResponse?
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        configureRefreshControl()
        
        // 🔍 Search text listener
        txtSearch?.addTarget(self, action: #selector(searchDeals), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        self.txtSearch?.text = ""
        vwSubMenu?.isHidden = true
        pageInfo = nil
        wsGetDeals()
    }
}

//MARK: - IBAction Methods
extension DealsVC {
    @IBAction func btnOnClickArchive(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Deal", bundle: nil)
        if let addMediaVC = storyboard.instantiateViewController(withIdentifier: "ArchivingVC") as? ArchivingVC {
            self.navigationController?.pushViewController(addMediaVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickNewDeal(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Deal", bundle: nil)
        if let dealListVC = storyboard.instantiateViewController(withIdentifier: "DealListVC") as? DealListVC {
            dealListVC.objPushType = .Deal
            self.navigationController?.pushViewController(dealListVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickCancel(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.vwSubMenu?.isHidden = true
    }
    
    @IBAction func btnOnClickAdd(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = true
        self.vwSubMenu?.isHidden = false
    }
}

// MARK: - UI Setup
private extension DealsVC {
    func configureUI() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = false
        
        vwSearch?.layer.cornerRadius = 25
        vwSearch?.clipsToBounds = true
        
        btnCreate?.applyRoundedStyle()
        btnCancel?.applyRoundedStyle()
        
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle.text = "Deals".localized
        self.btnCreate?.setTitle("Create a new deal".localized, for: .normal)
        self.btnCancel?.setTitle("Cancel".localized, for: .normal)
        self.lblNoData?.text = "No deal data".localized
    }
    
    func configureTableView() {
        tblListing?.separatorStyle = .none
        tblListing?.delegate = self
        tblListing?.dataSource = self
        tblListing?.register(
            UINib(nibName: "DealListTVCell", bundle: nil),
            forCellReuseIdentifier: DealListTVCell.reuseIdentifier
        )
        tblListing?.refreshControl = refreshControl
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
    }
}

// MARK: - Search Filter
extension DealsVC {
    @objc func searchDeals() {
        guard let keyword = txtSearch?.text?.lowercased(), !keyword.isEmpty else {
            isSearching = false
            filteredDeals = arrDeals
            tblListing?.reloadData()
            return
        }
        
        isSearching = true
        
        filteredDeals = arrDeals.filter { deal in
            let dealNumber = "\(deal.dealNo ?? 0)".lowercased()
            let displayName = deal.buyer?.displayName?.lowercased() ?? ""
            return dealNumber.contains(keyword) || displayName.contains(keyword)
        }
        
        tblListing?.reloadData()
    }
}

// MARK: - Refresh
private extension DealsVC {
    @objc func refreshData() {
        pageInfo = nil
        wsGetDeals()
    }
}

// MARK: - TableView Delegates
extension DealsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredDeals.count : arrDeals.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isSearching, let page = self.pageInfo, page.hasNextPage, indexPath.row == self.arrDeals.count - 1 {
            self.wsGetDeals()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DealListTVCell", for: indexPath) as? DealListTVCell else {
            return UITableViewCell()
        }
        
        let deal = isSearching ? filteredDeals[indexPath.row] : arrDeals[indexPath.row]
        cell.configureProperty(with: deal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDeal = isSearching ? filteredDeals[indexPath.row] : arrDeals[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Deal", bundle: nil)
        if let dealChatVC = storyboard.instantiateViewController(withIdentifier: "DealChatVC") as? DealChatVC {
            dealChatVC.objDeal = selectedDeal
            navigationController?.pushViewController(dealChatVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Networking
private extension DealsVC {
    func wsGetDeals() {
        Utility.showLoading()
        let currentPage = pageInfo?.page ?? 0
        let url = "\(WebService.DEALS)?page=\((currentPage) + 1)&size=20&sort=dealNo&archived=false"
        
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
                
                // 🔥 Always sort latest created deal on top
                self.arrDeals.sort { ($0.dealNo ?? 0) > ($1.dealNo ?? 0) }
                
                // Update search dataset
                self.filteredDeals = self.arrDeals
                
                self.pageInfo = pageResponse
                self.tblListing?.reloadData()
                
                let isEmpty = self.arrDeals.isEmpty
                self.tblListing?.isHidden = isEmpty
                self.lblNoData?.isHidden = !isEmpty
            }
        }
    }
}
