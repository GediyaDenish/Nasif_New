//
//  ListingDetailVC.swift
//  Nasif
//
//  Created by Denish Gediya on 07/07/25.
//

import UIKit
import MapKit
import Photos

class ListingDetailVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vwPropertyDeleteView: UIView!
    
    @IBOutlet weak var icnShow: UIImageView!
    @IBOutlet weak var vwBottomMenu1: UIView!
    @IBOutlet weak var lblHide: UILabel!
    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var lblDeleteMesgProperty: UILabel!
    @IBOutlet weak var vwInfrastructure: UIView!
    @IBOutlet weak var vwFeature: UIView!
    @IBOutlet weak var vwMainDesc: UIView!
    @IBOutlet weak var vwMainImage: UIView!
    @IBOutlet weak var vwBottomUserDetails: UIView!
    @IBOutlet weak var vwBottomMainDelete: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var vwStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnAllPhotos: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var lblTypeTitle: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var tblDetails: UITableView!
    @IBOutlet weak var lblFeatures: UILabel!
    @IBOutlet weak var cvFeatures: UICollectionView!
    @IBOutlet weak var heightFeatures: NSLayoutConstraint!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var vwDescription: UIView!
    @IBOutlet weak var lblDescriptionText: UILabel!
    @IBOutlet weak var lblInfraAvailable: UILabel!
    @IBOutlet weak var cvInfraAvailable: UICollectionView!
    
    @IBOutlet weak var heightInfra: NSLayoutConstraint!
    @IBOutlet weak var lblExtraDetails: UILabel!
    @IBOutlet weak var tblExtraDetails: UITableView!
    @IBOutlet weak var vwDelete: UIView!
    @IBOutlet weak var lblDelete: UILabel!
    @IBOutlet weak var lblDownloadMedia: UILabel!
    @IBOutlet weak var lblCopyDetails: UILabel!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var vwMainDelete: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnConfirmDelete: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblChat: UILabel!
    @IBOutlet weak var lblListingCreaterName: UILabel!
    @IBOutlet weak var lblListingCreatorNumber: UILabel!
    @IBOutlet weak var cvImages: UICollectionView!
    @IBOutlet weak var pagerImages: UIPageControl!
    @IBOutlet weak var tblDetailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblExtraDetailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNoMoreData: UILabel!
    @IBOutlet weak var vwPage: UIView!
    
    
    @IBOutlet var vwBG: [UIView]!
    
    
    
    // MARK: - Variables
    var objProperty: Property?
    var strProperty: String = ""
    var isFromPush: Bool = false
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
}

//MARK: - IBAction Mthonthd
extension ListingDetailVC {
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickEdit(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddList", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "AddListVC") as? AddListVC {
            editVC.isFromEdit = true
            editVC.objProperty = self.objProperty
            self.navigationController?.pushViewController(editVC, animated: true)
        }
    }
    
    @IBAction func btnOnClickAllPhotos(_ sender: UIButton) {
        let customVC = ImagePreviewVC()
        customVC.isFromHide = false
        customVC.arrImages = self.objProperty?.images ?? []
        self.navigationController?.pushViewController(customVC, animated: true)
    }
    
    @IBAction func btnOnClickLocation(_ sender: UIButton) {
        openLocationFromProperty()
    }
    
    @IBAction func btnOnClickDelete(_ sender: UIButton) {
        showFullScreenView()
    }
    
    @IBAction func btnOnClickHide(_ sender: UIButton) {
        self.wsHideProperty()
    }
    
    @IBAction func btnOnClickDownloadMedia(_ sender: UIButton) {
        downloadAndSaveAllImages()
    }
    
    @IBAction func btnOnClickCopyDetails(_ sender: UIButton) {
        let message = generateCopyText()
        openWhatsappWithText(message)
        
    }
    
    @IBAction func btnOnClickShare(_ sender: UIButton) {
        let contactListVC = ContactListVC(nibName: "ContactListVC", bundle: nil)
        contactListVC.isFromDeal = false
        contactListVC.objProperty = self.objProperty
        contactListVC.onDismiss = { [weak self] _ in
            guard let self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.navigationController?.present(contactListVC, animated: true)
    }
    
    @IBAction func btnOnClickDeleteConfirm(_ sender: UIButton) {
        self.hideFullScreenView()
        showDeleteConfirmation(from: self, message: "Are you sure you want to delete this property?".localized, title: "Delete".localized) { confirmed in
            if confirmed {
                self.wsDeleteProperty()
            } else {
                self.hideFullScreenView()
            }
        }
    }
    
    @IBAction func btnOnClickCancel(_ sender: UIButton) {
        hideFullScreenView()
    }
    
    @IBAction func btnOnClickChat(_ sender: UIButton) {
        if let id = objProperty?.userDetail?.id {
            wsAddChat(members: [id])
        }
    }
}

// MARK: - UI helpers
fileprivate extension ListingDetailVC {
    
    func InitConfig() {
        self.configureFonts()
        self.configureButtonsAndViews()
        self.configureCollectionViews()
        self.configureTables()
        self.wsGetPropertyDetail()
        self.setupLocalizations()
    }
    
    func setupLocalizations() {
        self.lblDetails.text = "Details".localized
        self.lblChat.text = "Chat".localized
        self.lblNoMoreData.text = ""
        self.lblDeleteMesgProperty.text = "This property deleted.".localized
        self.lblExtraDetails.text = "Extra Detailes".localized
        self.lblFeatures.text = "Features :".localized
        self.lblDescription.text = "Description :".localized
        self.lblInfraAvailable.text = "infrastructure  available :".localized
        self.lblDownloadMedia.text = "Download Media".localized
        self.lblCopyDetails.text = "Copy Details".localized
        self.lblShare.text = "إرسال العرض".localized
        self.lblDelete.text = "Delete".localized
        self.btnAllPhotos.setTitle("All Photos".localized, for: .normal)
        self.btnEdit.setTitle("Edit".localized, for: .normal)
        self.btnConfirmDelete.setTitle("Confirm Offer Deletion".localized, for: .normal)
        self.btnCancel.setTitle("Cancel".localized, for: .normal)
    }
    
    private func configureFonts() {
        // btnEdit?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        //lblStatus?.font = FontHelper.font(size: 10.0, type: .Regular)
        btnAllPhotos?.titleLabel?.font = FontHelper.font(size: 12.0, type: .Regular)
        lblTypeTitle?.font = FontHelper.font(size: 24.0, type: .Regular)
        lblCity?.font = FontHelper.font(size: 14.0, type: .Regular)
        lblPrice?.font = FontHelper.font(size: 20.0, type: .Regular)
        lblDetails?.font = FontHelper.font(size: 20.0, type: .Regular)
        lblFeatures?.font = FontHelper.font(size: 20.0, type: .Regular)
        lblDescription?.font = FontHelper.font(size: 20.0, type: .Regular)
        lblDescriptionText?.font = FontHelper.font(size: 16.0, type: .Regular)
        lblInfraAvailable?.font = FontHelper.font(size: 20.0, type: .Regular)
        lblExtraDetails?.font = FontHelper.font(size: 20.0, type: .Regular)
        lblDelete?.font = FontHelper.font(size: 14.0, type: .Regular)
        lblCopyDetails.text = "Copy \nDetails"
        lblDownloadMedia.text = "Download \nMedia"
        btnConfirmDelete?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        btnCancel?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        lblChat?.font = FontHelper.font(size: 10.0, type: .Regular)
        lblListingCreaterName?.font = FontHelper.font(size: 16.0, type: .Regular)
        lblListingCreatorNumber?.font = FontHelper.font(size: 10.0, type: .Regular)
    }
    
    func openLocationFromProperty() {
        guard let data = objProperty,
              data.location.coordinates.count >= 2 else {
            Utility.showToast(message: "Location data not available.".localized)
            return
        }
        
        let lon = data.location.coordinates.first!
        let lat = data.location.coordinates.last!
        
        // ✅ Always get a valid name
        let placeName: String = {
            if let city = data.city, !city.isEmpty {
                return city
            }
            return "\(data.area)"   // Convert Int -> String
        }()
        
        let encodedName = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? placeName
        
        let latStr = String(format: "%.6f", lat)
        let lonStr = String(format: "%.6f", lon)
        
        // ✅ Google Maps App
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            let urlString = "comgooglemaps://?q=\(latStr),\(lonStr)(\(encodedName))&center=\(latStr),\(lonStr)&zoom=18"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
                return
            }
        }
        
        // ✅ Google Maps Browser
        if let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(latStr),\(lonStr)") {
            UIApplication.shared.open(webURL)
            return
        }
        
        // ✅ Apple Maps
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        let mapItem = MKMapItem(placemark: .init(coordinate: coordinate))
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ])
    }
    
    private func configureButtonsAndViews() {
        vwStatus?.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 0)
        btnAllPhotos?.setupNewButton(borderColor: .clear, andCornerRadious: 5.0)
        btnLocation?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0)
        btnLocation?.applyShadow(color: UIColor.black.withAlphaComponent(0.4), radius: 10, offset: .zero, opacity: 0.7)
        
        vwDescription?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 10.0, borderWidth: 1.0)
        
        vwDelete?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0)
        vwMainImage?.setRound(withBorderColor: .clear, andCornerRadious: 35.0, borderWidth: 0)
        vwDelete?.applyShadow(color: UIColor.black.withAlphaComponent(0.4), radius: 10, offset: .zero, opacity: 0.7)
        
        btnConfirmDelete?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0)
        btnCancel?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0)
        self.vwBG?.forEach({
            $0.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 8.0, borderWidth: 1.0)
        })
    }
    
    private func configureCollectionViews() {
        // Images collection view
        setupCollectionViewLayout()
        
        cvImages?.delegate = self
        cvImages?.dataSource = self
        cvImages?.isPagingEnabled = true
        cvImages?.showsHorizontalScrollIndicator = false
        cvImages?.register(UINib(nibName: "ImagesCVCell", bundle: nil), forCellWithReuseIdentifier: "ImagesCVCell")
        
        // Features collection view
        self.cvFeatures?.delegate = self
        self.cvFeatures?.dataSource = self
        self.cvFeatures?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvFeatures?.semanticContentAttribute = .forceRightToLeft
        
        self.cvInfraAvailable?.delegate = self
        self.cvInfraAvailable?.dataSource = self
        self.cvInfraAvailable?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvInfraAvailable?.semanticContentAttribute = .forceRightToLeft
        
    }
    
    private func configureTables() {
        tblDetails?.delegate = self
        tblDetails?.dataSource = self
        tblDetails?.register(UINib(nibName: "DetailTVCell", bundle: nil), forCellReuseIdentifier: "DetailTVCell")
        
        tblExtraDetails?.delegate = self
        tblExtraDetails?.dataSource = self
        tblExtraDetails?.register(UINib(nibName: "DetailTVCell", bundle: nil), forCellReuseIdentifier: "DetailTVCell")
    }
    
    func setupCollectionViewLayout() {
        if let layout = cvImages.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: cvImages.frame.width, height: cvImages.frame.height)
            layout.sectionInset = .zero
            cvImages.contentInset = .zero
        }
    }
    
    func showFullScreenView() {
        vwMainDelete.alpha = 0.0
        vwMainDelete.isHidden = false
        
        UIView.animate(withDuration: 0.6) {
            self.vwMainDelete.alpha = 1.0
        }
        
        animateButtonsIn()
    }
    
    func animateButtonsIn() {
        btnConfirmDelete.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        btnCancel.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        btnConfirmDelete.alpha = 0.0
        btnCancel.alpha = 0.0
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseInOut) {
            self.btnConfirmDelete.transform = .identity
            self.btnCancel.transform = .identity
            self.btnConfirmDelete.alpha = 1.0
            self.btnCancel.alpha = 1.0
        }
    }
    
    func hideFullScreenView() {
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
            self.btnConfirmDelete.alpha = 0.0
            self.btnCancel.alpha = 0.0
            self.btnConfirmDelete.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            self.btnCancel.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.vwMainDelete.alpha = 0.0
            }) { _ in
                self.vwMainDelete.isHidden = true
            }
        }
    }
    
    func updateInfraHeight() {
        self.cvInfraAvailable.reloadData()
        self.cvInfraAvailable.layoutIfNeeded()
        
        // Dynamic height based on content
        let contentHeight = self.cvInfraAvailable.collectionViewLayout.collectionViewContentSize.height
        self.heightInfra.constant = contentHeight
        
        self.view.layoutIfNeeded()
    }
    
    func updateFeaturesHeight() {
        self.cvFeatures.reloadData()
        self.cvFeatures.layoutIfNeeded()
        
        // Dynamic height based on content
        let contentHeight = self.cvFeatures.collectionViewLayout.collectionViewContentSize.height
        self.heightFeatures.constant = contentHeight
        
        self.view.layoutIfNeeded()
    }
    
}

// MARK: - Collectionview Delegate & Datasource
extension ListingDetailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvImages {
            return objProperty?.images?.count ?? 0
        } else if collectionView == cvFeatures {
            return objProperty?.extraFeatures?.count ?? 0
        } else {
            return self.objProperty?.services?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvImages {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCVCell", for: indexPath) as? ImagesCVCell else {
                return UICollectionViewCell()
            }
            if let url = URL(string: objProperty?.images?[indexPath.item] ?? ""){
                cell.imgImages?.sd_setImage(with: url, placeholderImage: UIImage(named: "Image"))
                cell.imgImages?.contentMode = .scaleAspectFill
            }
            return cell
        } else if collectionView == cvFeatures {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListTypeCVCell", for: indexPath) as? ListTypeCVCell else {
                return UICollectionViewCell()
            }
            
            cell.contentView.layer.masksToBounds = true
            cell.lblType?.textColor = UIColor.themeBorderColor808080
            cell.contentView.backgroundColor = .white
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.cornerRadius = 10.0
            cell.contentView.layer.masksToBounds = true
            if let feature = objProperty?.extraFeatures?[indexPath.item] {
                cell.configure(with: feature.localized)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListTypeCVCell", for: indexPath) as? ListTypeCVCell else {
                return UICollectionViewCell()
            }
            
            cell.contentView.layer.masksToBounds = true
            cell.lblType?.textColor = UIColor.themeBorderColor808080
            cell.contentView.backgroundColor = .white
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.cornerRadius = 10.0
            cell.contentView.layer.masksToBounds = true
            if let services = objProperty?.services?[indexPath.item] {
                cell.configure(with: services.localized)
            }
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pagerImages.currentPage = page
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvImages {
            return CGSize(width: self.cvImages.frame.width, height: self.cvImages.frame.height)
        } else {
            let spacing: CGFloat = 10
            let totalSpacing = spacing * 2
            let availableWidth = max(collectionView.bounds.width - totalSpacing, 0)
            let itemWidth = floor(availableWidth / 3)
            return CGSize(width: itemWidth, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - Tableview Delegate & Datasource
extension ListingDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func arrayToString(_ arr: [String]?) -> String? {
        guard let arr = arr, !arr.isEmpty else { return nil }
        
        let localizedArr = arr.map { $0.localized }
        return localizedArr.joined(separator: ", ")
    }
    
    
    // MARK: - Table Data Sources
    var detailItems: [(title: String, value: String?, icon: String)] {
        guard let data = objProperty else { return [] }
        
        var items: [(String, String?, String)] = [
            ("Area", stringIfPositive(data.area, unit: " م²"), "icn_area"),
            ("Facing", {
                let directions = [
                    (data.northFacing ?? 0) != 0 ? "North".localized : nil,
                    (data.eastFacing ?? 0) != 0 ? "East".localized : nil,
                    (data.westFacing ?? 0) != 0 ? "West".localized : nil,
                    (data.southFacing ?? 0) != 0 ? "South".localized : nil
                ].compactMap { $0 }
                return directions.isEmpty ? nil : directions.joined(separator: " ")
            }(), "icn_facing"),
            
            ("Street Width", nil, "icn_street"),
            ("Floor No.", stringIfPositive(data.floorNumber), "icn_floor"),
            ("Intended Use", arrayToString(data.useFor), "icn_Intended"),
            ("Age of the Property", stringIfPositive(data.age, unit: " years"), "icn_age_property"),
            ("Bedrooms", stringIfPositive(data.totalBedrooms), "icn_bedrooms"),
            ("Bathrooms", stringIfPositive(data.totalBathrooms), "icn_bathrooms"),
            ("Living & Seating Areas", stringIfPositive(data.totalLivingrooms), "icn_living"),
            ("Number of Floors", stringIfPositive(data.totalFloors), "icn_floor"),
            ("Price per Meter", Formatter.calculatePricePerMeter(price: data.price, area: data.area), "icn_price _meter")
        ]
        
        /// condition : Only add if property type == "villa"
        if data.type?.lowercased() == "villa" {
            items.insert(("Villa Type", stringIfNotEmpty(data.vilaType), "icn_villa_type"), at: 3)
        }
        
        return items.filter { ($0.1?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) }
    }
    
    var extraDetailItems: [(title: String, value: String?)] {
        guard let data = objProperty else { return [] }
        
        if data.userDetail?.id == UserDefaultsHelper.getUserFromDefaults()?.userId {
            let items: [(String, String?)] = [
                ("Advertiser's Role", data.advertisersRole),
                ("Plan Number", data.planNumber),
                ("Plot Number", data.plotNumber),
                ("Fal License Number", data.falLicenseNumber),
                ("Advertisement License Number", data.licenseNumber),
                ("Listing No.", objProperty?.listingNo.map { String($0) }), // ✅ Int? → String?
                ("Owner's Name", data.ownerName),
                ("Owner's Phone", Utility.formattedPhoneNumber(data.ownerNumber))
            ]
            return items.filter { ($0.1?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) }
        } else {
            let items: [(String, String?)] = [
                ("Advertiser's Role", data.advertisersRole),
                ("Plan Number", data.planNumber),
                ("Plot Number", data.plotNumber),
                ("Fal License Number", data.falLicenseNumber),
                ("Advertisement License Number", data.licenseNumber),
                ("Listing No.", objProperty?.listingNo.map { String($0) })
            ]
            return items.filter { ($0.1?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) }
        }
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblDetails {
            tblDetailHeightConstraint.constant = CGFloat(detailItems.count * 35)
            return detailItems.count
        } else {
            tblExtraDetailHeightConstraint.constant = CGFloat(extraDetailItems.count * 35)
            return extraDetailItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTVCell", for: indexPath) as? DetailTVCell else {
            return UITableViewCell()
        }
        
        if tableView == tblDetails {
            let item = detailItems[indexPath.row]
            cell.lblPerameter.text = item.title.localized
            if item.title == "Price per Meter" {
                cell.icnSAR.isHidden = false
            } else {
                cell.icnSAR.isHidden = true
            }
            cell.lblValue.text = item.value?.localized
            cell.imgIcon.image = UIImage(named: item.icon)
        } else {
            let item = extraDetailItems[indexPath.row]
            cell.lblPerameter.text = item.title.localized
            cell.lblValue.text = item.value?.localized
            cell.imgIcon.isHidden = indexPath.row != 5
            if indexPath.row == 5 {
                cell.imgIcon.image = UIImage(named: "icn_copy")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
}

// MARK: - Helpers
extension ListingDetailVC {
    
    func stringIfPositive(_ value: Int?, unit: String? = nil) -> String? {
        guard let v = value, v > 0 else { return nil }
        return unit == nil ? "\(v)" : "\(v)\(unit!)"
    }
    
    func stringIfPositive(_ value: Int, unit: String? = nil) -> String? {
        return value > 0 ? (unit == nil ? "\(value)" : "\(value)\(unit!)") : nil
    }
    
    func stringIfNotEmpty(_ value: String?) -> String? {
        guard let v = value, !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return v
    }
}

extension ListingDetailVC {
    
    func downloadAndSaveAllImages() {
        guard let images = objProperty?.images, !images.isEmpty else {
            Utility.showToast(message: "No images found.".localized)
            return
        }
        
        // 🔄 Show loader
        DispatchQueue.main.async {
            Utility.showLoading()
        }
        
        // ✅ iOS 14+ new API, fallback for older
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                self.handlePhotoAuthStatus(status: status, images: images)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                self.handlePhotoAuthStatus(status: status, images: images)
            }
        }
    }
    
    private func handlePhotoAuthStatus(status: PHAuthorizationStatus, images: [String]) {
        guard status == .authorized || status == .limited else {
            DispatchQueue.main.async {
                Utility.hideLoading()
                Utility.showToast(message: "Photo access denied.".localized)
            }
            return
        }
        
        let group = DispatchGroup()
        var savedCount = 0
        var failedCount = 0
        
        for item in images {
            guard let imageURL = URL(string: item) else {
                print("❌ Invalid URL: \(item)")
                failedCount += 1
                continue
            }
            
            print("⬇️ Downloading from: \(imageURL)")
            group.enter()
            
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    print("❌ Download error: \(error.localizedDescription)")
                    failedCount += 1
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("❌ Invalid image data at: \(imageURL)")
                    failedCount += 1
                    return
                }
                
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(
                        image,
                        self,
                        #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                        nil
                    )
                    savedCount += 1
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            Utility.hideLoading()
            let message = "✅ Saved: \(savedCount) | ❌ Failed: \(failedCount)"
            print("📢 All downloads complete: \(message)")
            Utility.showToast(message: message.localized)
        }
    }
    
    // 📌 Callback from UIImageWriteToSavedPhotosAlbum
    @objc private func image(_ image: UIImage,
                             didFinishSavingWithError error: Error?,
                             contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("❌ Error saving image: \(error.localizedDescription)")
        } else {
            print("✅ Image saved successfully")
        }
    }
}


// MARK: - Web Service Calls
fileprivate extension ListingDetailVC {
    
    func wsAddChat(members: [String]) {
        Utility.showLoading()
        var params: [String: Any] = [:]
        params[PARAMS.MEMBERS] = members
        let url = "\(WebService.CHATS)"
        WebServices.Post(url: url, params: params, type: ChatMessage.self) { [weak self] response in
            guard let self = self else { return }
            Utility.hideLoading()
            guard response != nil else { return }
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            if let chatDetailVC = storyboard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC {
                chatDetailVC.objChat = response
                chatDetailVC.isFromNewPush = false
                self.navigationController?.pushViewController(chatDetailVC, animated: true)
            }
        }
    }
    
    func wsGetPropertyDetail() {
        Utility.showLoading()
        
        var propertyId = ""
        
        if self.isFromPush {
            propertyId = self.strProperty
        } else {
            propertyId = self.objProperty?.id ?? ""
        }
        
        let url = "\(WebService.PROPERTY)\(propertyId)"
        
        WebServices.Get(url: url, type: Property.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else { return }
            guard response != nil else { return }
            guard let property = response else { return }
            self.objProperty = property
            self.updateUserDetailsUI(property: property)
            self.updatePropertyInfoUI(property: property)
            self.updateVisibility(property: property)
            self.reloadAllData()
        }
    }
    
    // MARK: - UI Update Helpers
    
    private func updateUserDetailsUI(property: Property) {
        pagerImages.numberOfPages = property.images?.count ?? 0
        pagerImages.currentPage = 0
        
        lblListingCreaterName.text = property.userDetail?.displayName
        lblListingCreatorNumber.text = Utility.formattedPhoneNumber(property.userDetail?.mobile)
        if let url = URL(string: property.userDetail?.avatar ?? "") {
            imgUser?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_contact_placeholder"))
        }
        if self.isFromPush {
            btnEdit.isHidden = true
            vwBottomMainDelete.isHidden = true
            vwBottomUserDetails.isHidden = true
        } else {
            let isCurrentUser = property.userDetail?.id == UserDefaultsHelper.getUserFromDefaults()?.userId
            vwBottomMainDelete.isHidden = !isCurrentUser
            vwBottomUserDetails.isHidden = isCurrentUser
            btnEdit.isHidden = !isCurrentUser
        }
        
        if property.userDetail?.id != UserDefaultsHelper.getUserFromDefaults()?.userId {
            vwBottomMenu1.isHidden = false
        } else {
            vwBottomMenu1.isHidden = true
        }
        if property.status == "Available" {
            self.vwStatus.backgroundColor = UIColor.themeBackgroundGreenColor
        } else if property.status == "Reserved" {
            self.vwStatus.backgroundColor = UIColor.themePurpor
        } else {
            self.vwStatus.backgroundColor = UIColor.themeBackgroundRedColor
        }
        self.lblStatus.text = property.status?.localized
        
        if property.isHidden == true {
            self.icnShow.image = UIImage(named: "icn_show")
            self.lblHide.textColor = UIColor.themePrimaryColor
            self.lblHide.text = "حفظ العرض"
        } else {
            self.icnShow.image = UIImage(named: "icn_hide")
            self.lblHide.textColor = UIColor.red
            self.lblHide.text = "إخفاء العرض"
        }
    }
    
    private func updatePropertyInfoUI(property: Property) {
        if let type = property.type?.localized {
            if property.availableFor == "Sale" {
                self.lblTypeTitle?.text = "\(type) للبيع"
            } else {
                self.lblTypeTitle?.text = "\(type) للإيجار"
            }
        } else {
            self.lblTypeTitle?.text = property.type?.localized ?? "N/A"
        }
        
        lblCity.text = "\(property.city ?? "") - \(property.neighbourhood ?? "")"
        lblPrice.text = formatPriceNew("\(property.price)")
        
        let hasDescription = !(property.description?.isEmpty ?? true)
        vwMainDesc.isHidden = !hasDescription
        lblDescriptionText.text = hasDescription ? property.description : ""
    }
    
    func openWhatsappWithText(_ text: String) {
        let allowed = CharacterSet.urlQueryAllowed
        guard let encoded = text.addingPercentEncoding(withAllowedCharacters: allowed),
              let url = URL(string: "whatsapp://send?text=\(encoded)")
        else {
            Utility.showToast(message: "Unable to encode text".localized)
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            Utility.showToast(message: "WhatsApp not installed".localized)
        }
    }
    
    
    func generateCopyText() -> String {
        guard let data = objProperty else { return "" }
        
        var copyText = ""
        
        // Title (Sale / Rent)
        if let type = data.type?.localized {
            copyText += "📌 \(type) \(data.availableFor == "Sale" ? "للبيع" : "للإيجار")\n"
        }
        
        // City
        copyText += "\n🌍 الموقع:\n\(data.city ?? "-") - \(data.neighbourhood ?? "-")\n"
        
        // Price
        copyText += "\n💰 السعر:\n\(formatPriceNew("\(data.price)"))\n"
        
        // Description
        if let desc = data.description, !desc.isEmpty {
            copyText += "\n📝 الوصف:\n\(desc)\n"
        }
        
        // Specifications
        copyText += "\n📐 المواصفات:\n"
        for item in detailItems {
            if let v = item.value, !v.isEmpty {
                copyText += "• \(item.title.localized): \(v)\n"
            }
        }
        
        // Extra Details
        if !extraDetailItems.isEmpty {
            copyText += "\n📎 تفاصيل إضافية:\n"
            for item in extraDetailItems {
                if let v = item.value, !v.isEmpty {
                    copyText += "• \(item.title.localized): \(v)\n"
                }
            }
        }
        
        return copyText
    }
    
    
    private func updateVisibility(property: Property) {
        let hasImages = !(property.images?.isEmpty ?? true)
        let hasExtraFeatures = !(property.extraFeatures?.isEmpty ?? true)
        let hasServices = !(property.services?.isEmpty ?? true)
        
        cvImages.isHidden = !hasImages
        vwFeature.isHidden = !hasExtraFeatures
        vwInfrastructure.isHidden = !hasServices
        lblNoMoreData.isHidden = hasImages
        btnAllPhotos.isHidden = !hasImages
        vwPage.isHidden = !hasImages
        if property.isDeleted == true {
            self.vwPropertyDeleteView.isHidden = false
        } else {
            self.vwPropertyDeleteView.isHidden = true
        }
    }
    
    private func reloadAllData() {
        cvImages.reloadData()
        
        DispatchQueue.main.async {
            self.cvFeatures?.reloadData()
            self.updateFeaturesHeight()
        }
        
        DispatchQueue.main.async {
            self.cvInfraAvailable?.reloadData()
            self.updateInfraHeight()
        }
        
        tblDetails.reloadData()
        tblExtraDetails.reloadData()
    }
    
    func wsDeleteProperty() {
        Utility.showLoading()
        guard let propertyId = self.objProperty?.id else {
            Utility.hideLoading()
            Utility.showToast(message: "Property ID not found".localized)
            return
        }
        let url = "\(WebService.PROPERTY)\(propertyId)/"
        WebServices.Delete(url: url, type: Property.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else { return }
            guard response != nil else { return }
            Utility.showToast(message: "Delete Property Successfully".localized)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func wsHideProperty() {
        Utility.showLoading()
        guard let propertyId = self.objProperty?.id else {
            Utility.hideLoading()
            Utility.showToast(message: "Property ID not found".localized)
            return
        }
        let url = "\(WebService.PROPERTY)\(propertyId)/hide-show/"
        
        WebServices.Put(url: url, params: [:], type: Property.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else { return }
            guard response != nil else { return }
            if response?.isHidden == true {
                self.icnShow.image = UIImage(named: "icn_show")
                self.lblHide.textColor = UIColor.themePrimaryColor
                self.lblHide.text = "حفظ العرض"
            } else {
                self.icnShow.image = UIImage(named: "icn_hide")
                self.lblHide.textColor = UIColor.red
                self.lblHide.text = "إخفاء العرض"
            }
        }
    }
}
