//
//  DealListVC.swift
//  Nasif
//
//  Created by Denish Gediya on 29/07/25.
//

import UIKit

enum navigationType: String {
    case Chat
    case GroupChat
    case Deal
    case Profile
}

final class DealListVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tblDeal: UITableView?
    @IBOutlet private weak var txtSearch: UITextField?
    @IBOutlet private weak var vwSearch: UIView?
    @IBOutlet private weak var btnNext: UIButton?
    @IBOutlet private weak var lblNoData: UILabel?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var vwNext: UIView?
    
    // MARK: - Properties
    private var dictParam: [String: Any] = [:]
    private var arrShareProperty: [Property] = []
    private var selectedIndexPath: IndexPath?
    private var pageInfo: PropertyResponse?
    private let refreshControl = UIRefreshControl()
    var objChat: ChatMessage?
    var objPushType: navigationType = .Deal
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfig()
    }
}

// MARK: - Actions
private extension DealListVC {
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickNext(_ sender: UIButton) {
        guard let selectedIndexPath else {
            Utility.showToast(message: "Please select property".localized)
            return
        }
        let obj = arrShareProperty[selectedIndexPath.row]
        if self.objPushType == .Chat {
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            if let chatDetailVC = storyboard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC {
                chatDetailVC.objChat = self.objChat
                chatDetailVC.objProperty = obj
                chatDetailVC.isFromPush = true
                chatDetailVC.isFromNewPush = false
                self.navigationController?.pushViewController(chatDetailVC, animated: true)
            }
        } else if self.objPushType == .Deal {
            let contactListVC = ContactListVC(nibName: "ContactListVC", bundle: nil)
            contactListVC.isFromDeal = true
            contactListVC.objProperty = obj
            contactListVC.onDismiss = { [weak self] deal in
                guard let self else { return }
                let storyboard = UIStoryboard(name: "Deal", bundle: nil)
                if let dealChatVC = storyboard.instantiateViewController(withIdentifier: "DealChatVC") as? DealChatVC {
                    dealChatVC.objDeal = deal
                    self.navigationController?.pushViewController(dealChatVC, animated: true)
                }
            }
            navigationController?.present(contactListVC, animated: true)
        } else if self.objPushType == .GroupChat {
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            if let groupChatDetailVC = storyboard.instantiateViewController(withIdentifier: "GroupChatDetailVC") as? GroupChatDetailVC {
                groupChatDetailVC.objChat = self.objChat
                groupChatDetailVC.objProperty = obj
                groupChatDetailVC.isFromPush = true
                self.navigationController?.pushViewController(groupChatDetailVC, animated: true)
            }
        }
    }
}

// MARK: - UI Helpers
private extension DealListVC {
    
    func initConfig() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
        
        self.setupLocalized()
        setupSearchView()
        setupTableView()
        setupNextButton()
        configureRefreshControl()
        pageInfo = nil
        wsGetShareList()
    }
    
    func setupLocalized() {
        if self.objPushType == .Profile {
            self.vwNext?.isHidden = true
            self.lblTitle?.text = "Listings Shared".localized
        } else {
            self.vwNext?.isHidden = false
            self.lblTitle?.text = "Choose the listing".localized
        }
        self.btnNext?.setTitle("Next".localized, for: .normal)
        self.lblNoData?.text = "No list Data".localized
    }
    
    func setupSearchView() {
        vwSearch?.layer.cornerRadius = 25.0
        vwSearch?.layer.masksToBounds = true
    }
    
    func setupTableView() {
        tblDeal?.separatorStyle = .none
        tblDeal?.delegate = self
        tblDeal?.dataSource = self
        tblDeal?.allowsMultipleSelection = false
        tblDeal?.register(
            UINib(nibName: "ListingTVCell", bundle: nil),
            forCellReuseIdentifier: "ListingTVCell"
            
        )
        tblDeal?.refreshControl = refreshControl
    }
    
    func setupNextButton() {
        btnNext?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        btnNext?.setupButton(borderColor: .clear, andCornerRadious: 8.0)
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshCall(_:)), for: .valueChanged)
        refreshControl.tintColor = .gray
    }
}

// MARK: - Refresh
private extension DealListVC {
    @objc func refreshCall(_ sender: Any) {
        pageInfo = nil
        wsGetShareList()
    }
}

// MARK: - TableView Delegate & DataSource
extension DealListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrShareProperty.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let page = self.pageInfo, page.hasNextPage, indexPath.row == self.arrShareProperty.count - 1 {
            self.wsGetShareList()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListingTVCell", for: indexPath) as? ListingTVCell else {
            return UITableViewCell()
        }
        let objProperty = arrShareProperty[indexPath.row]
        cell.configureShareProperty(with: objProperty, indexPath: indexPath, selectedIndexPath: selectedIndexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.objPushType != .Profile {
            let previous = selectedIndexPath
            selectedIndexPath = indexPath
            
            var toReload: [IndexPath] = [indexPath]
            if let previous, previous != indexPath { toReload.append(previous) }
            tableView.reloadRows(at: toReload, with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Web Service Calls
private extension DealListVC {
    
    func wsGetShareList() {
        Utility.showLoading()
        let pageValue = pageInfo?.page ?? 0
        let url = "\(WebService.PROPERTY)my/?page=\((pageValue) + 1)&size=20"
        
        WebServices.Get(url: url, type: PropertyResponse.self) { [weak self] response in
            Utility.hideLoading()
            guard let self else { return }
            DispatchQueue.main.async { self.refreshControl.endRefreshing() }
            guard let pageResponse = response else { return }
            DispatchQueue.main.async {
                if self.pageInfo == nil || pageResponse.totalPages == 1 {
                    self.arrShareProperty = pageResponse.content
                } else {
                    self.arrShareProperty.append(contentsOf: pageResponse.content)
                }
                self.pageInfo = pageResponse
                self.tblDeal?.reloadData()
                let isEmpty = self.arrShareProperty.isEmpty
                self.tblDeal?.isHidden = isEmpty
                self.lblNoData?.isHidden = !isEmpty
            }
        }
    }
}
