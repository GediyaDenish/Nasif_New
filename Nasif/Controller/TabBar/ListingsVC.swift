//
//  ListingsVC.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseMessaging

class ListingsVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var cvType: UICollectionView?
    @IBOutlet private weak var vwType: UIView?
    @IBOutlet private weak var vwListing: UIView?
    @IBOutlet private weak var tblListing: UITableView?
    @IBOutlet private weak var lblTitle: UILabel?
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var vwMap: UIView?
    @IBOutlet private weak var lblNoData: UILabel?
    @IBOutlet private var vwMenu: [UIView]?
    @IBOutlet private weak var tblMapListing: UITableView?
    @IBOutlet private weak var mapTableHeight: NSLayoutConstraint?
    @IBOutlet weak var vwSelect: UIView!
    @IBOutlet weak var cvSelectType: UICollectionView!
    
    // MARK: - Properties
    private let arrOptions = ["All", "Land", "Villa", "Apartment","Floor", "Building Complex", "Chalet", "Farm","Other"]
    private var selectedIndex: Int = 0
    private let locationManager = CLLocationManager()
    private var mapTypeIndex = 0
    private var arrProperty: [Property] = []
    private var arrMapProperty: [Property] = []
    private var currentLat: Double?
    private var currentLng: Double?
    private let defaultRadiusInMeters: Int = 1000*50000 //1000 = meter 5 = KM
    private var pageInfo: PropertyResponse?
    private let refreshControl = UIRefreshControl()
    var arrSelectType: [String] = [ "All", "Rent", "Sale"]
    var selectSelectType: Int = 0
    var addPinView: UIView?
    var selectedMarker: GMSMarker?
    var originalMarkerIcon: UIImage?
    var selectedProperty: Property?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMap()
        configureRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        configureCollectionAndTables()
        toggleMapView(showMap: false)
        setupLocationManager()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionMapTableIfNeeded()
    }
}

// MARK: - IBActions
private extension ListingsVC {
    
    @IBAction func btnOnClickSearch(_ sender: UIButton) {
        navigate(to: "SearchVC")
    }
    
    @IBAction func btnOnClickAdd(_ sender: UIButton) {
        navigate(to: "AddListVC")
    }
    
    @IBAction func btnOnClickMode(_ sender: UIButton) {
        mapTypeIndex = (mapTypeIndex + 1) % 4
        mapView.mapType = GMSMapViewType(rawValue: UInt(mapTypeIndex)) ?? .normal
        print("Current map type: \(mapView.mapType.rawValue)")
    }
    
    @IBAction func btnOnClickZoom(_ sender: UIButton) {
        guard let location = locationManager.location else {
            print("📍 User location not available yet.")
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 15.0)
        mapView.animate(to: camera)
    }
    
    @IBAction func btnOnClickMenu(_ sender: UIButton) {
        toggleMapView(showMap: true)
        resetMapListingView()
    }
    
    @IBAction func btnOnClickMap(_ sender: UIButton) {
        toggleMapView(showMap: false)
    }
    
    func navigate(to identifier: String) {
        let storyboard = UIStoryboard(name: "AddList", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func toggleMapView(showMap: Bool) {
        vwMap?.isHidden = showMap
        vwListing?.isHidden = !showMap
    }
}

// MARK: - Configuration
private extension ListingsVC {
    
    func configureUI() {
        vwMenu?.forEach {
            $0.layer.cornerRadius = 22.5
            $0.layer.masksToBounds = true
        }
        lblTitle?.font = FontHelper.font(size: 20.0, type: .Regular)
        vwType?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0)
        vwSelect?.setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0)
        getProfile()
        setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle?.text = "Listings".localized
        self.lblNoData?.text = "No property data".localized
    }
    
    // MARK: - Setup
    func configureCollectionAndTables() {
        // cvSelectType (Segmented style)
        cvSelectType?.delegate = self
        cvSelectType?.dataSource = self
        cvSelectType?.showsHorizontalScrollIndicator = false
        cvSelectType?.register(UINib(nibName: "ListTypeCVCell", bundle: nil),
                               forCellWithReuseIdentifier: "ListTypeCVCell")
        cvSelectType?.semanticContentAttribute = .forceRightToLeft
        cvSelectType?.layer.cornerRadius = 18
        cvSelectType?.layer.masksToBounds = true
        
        cvType?.delegate = self
        cvType?.dataSource = self
        cvType?.showsHorizontalScrollIndicator = false
        cvType?.register(UINib(nibName: "ListTypeCVCell", bundle: nil),
                         forCellWithReuseIdentifier: "ListTypeCVCell")
        cvType?.semanticContentAttribute = .forceRightToLeft
        cvType?.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        // Default selection for cvType
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let cv = self.cvType else { return }
            let indexPath = IndexPath(item: 0, section: 0)
            self.selectedIndex = 0
            cv.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            self.collectionView(cv, didSelectItemAt: indexPath)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let cv = self.cvSelectType else { return }
            let indexPath = IndexPath(item: 0, section: 0)
            self.selectSelectType = 0
            cv.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            self.collectionView(cv, didSelectItemAt: indexPath)
        }
        
        // TableView - List
        configureTable(tblListing, addRefresh: true)
        
        // TableView - Map
        configureTable(tblMapListing, addRefresh: false)
        tblMapListing?.isHidden = true
        mapTableHeight?.constant = 0
    }
    
    func configureTable(_ tableView: UITableView?, addRefresh: Bool) {
        tableView?.separatorStyle = .none
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UINib(nibName: "ListingTVCell", bundle: nil),
                            forCellReuseIdentifier: "ListingTVCell")
        if addRefresh {
            tableView?.refreshControl = refreshControl
        }
    }
    
    func configureMap() {
        mapTypeIndex = Int(GMSMapViewType.normal.rawValue)
        mapView.mapType = .normal
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = false
        mapView?.delegate = self
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshCall(_:)), for: .valueChanged)
        refreshControl.tintColor = .gray
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func positionMapTableIfNeeded() {
        guard let mapTable = tblMapListing, let map = vwMap else { return }
        let height: CGFloat = 150
        mapTable.frame = CGRect(x: 0,
                                y: map.frame.height - height,
                                width: map.frame.width,
                                height: height)
    }
}

// MARK: - Refresh
private extension ListingsVC {
    @objc func refreshCall(_ sender: Any) {
        pageInfo = nil
        wsGetProperties()
    }
}

// MARK: - CollectionView
extension ListingsVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvSelectType {
            return arrSelectType.count
        } else {
            return arrOptions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ListTypeCVCell",
            for: indexPath
        ) as? ListTypeCVCell else {
            return UICollectionViewCell()
        }
        
        var isSelected = false
        
        if collectionView == cvSelectType {
            isSelected = (self.selectSelectType == indexPath.item)
            cell.configures(with: arrSelectType[indexPath.item].localized, isSelected: isSelected)
        } else {
            cell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
            isSelected = (selectedIndex == indexPath.item)
            cell.configures(with: arrOptions[indexPath.item].localized, isSelected: isSelected)
        }
        
        // 👉 Corner radius only if selected
        if isSelected {
            cell.contentView.backgroundColor = .white
            cell.contentView.layer.cornerRadius = 18
            cell.contentView.layer.masksToBounds = true
            cell.lblType?.textColor = .black
        } else {
            cell.contentView.backgroundColor = .clear
            cell.contentView.layer.cornerRadius = 0
            cell.lblType?.textColor = UIColor.themeSelect
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvSelectType {
            self.selectSelectType = indexPath.item
            resetFilter()
            ListingFilterKeys.availableFor =
            (arrSelectType[indexPath.item] == "All") ? nil : arrSelectType[indexPath.item]
            // ListingFilterKeys.type = nil
        } else {
            selectedIndex = indexPath.item
            resetFilter()
            ListingFilterKeys.type =
            (arrOptions[indexPath.item] == "All") ? nil : arrOptions[indexPath.item]
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
        pageInfo = nil
        wsGetProperties()
        resetMapListingView()
        collectionView.reloadData()
    }
    
    // Sizes
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == cvSelectType {
            let numberOfItems = arrSelectType.count
            let totalWidth = collectionView.bounds.width
            let width = totalWidth / CGFloat(numberOfItems)
            return CGSize(width: width, height: 36)
        } else {
            let text = arrOptions[indexPath.item].localized
            let font = UIFont.systemFont(ofSize: 14)
            let padding: CGFloat = 32
            let textWidth = text.size(withAttributes: [.font: font]).width
            return CGSize(width: textWidth + padding, height: 36)
        }
    }
    
    // Spacing
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

// MARK: - TableView
extension ListingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView == tblMapListing ? arrMapProperty.count : arrProperty.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let page = self.pageInfo, page.hasNextPage, indexPath.row == self.arrProperty.count - 1 {
            self.wsGetProperties()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListingTVCell", for: indexPath) as? ListingTVCell else {
            return UITableViewCell()
        }
        let property = (tableView == tblMapListing)
        ? arrMapProperty[indexPath.row]
        : arrProperty[indexPath.row]
        cell.configureProperty(with: property)
        if tableView == tblMapListing {
            cell.btnClose.isHidden = true
            cell.btnClose.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            cell.vwMain.backgroundColor = .white
        } else {
            cell.btnClose.isHidden = true
            if property.user == UserDefaultsHelper.getUserFromDefaults()?.userId {
                cell.vwMain.backgroundColor = UIColor.white
                cell.vwSubMain.layer.cornerRadius = 10.0
                cell.vwSubMain.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                cell.vwSubMain.layer.masksToBounds = true
                cell.vwSubMain.layer.borderColor = UIColor.themePrimaryColor.cgColor
                cell.vwSubMain.layer.borderWidth = 1.5
            } else {
                cell.vwMain.backgroundColor = .white
                cell.vwSubMain.layer.borderColor = UIColor.clear.cgColor
                cell.vwSubMain.layer.borderWidth = 0.0
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let property = (tableView == tblMapListing)
        ? arrMapProperty[indexPath.row]
        : arrProperty[indexPath.row]
        navigateToDetail(for: property)
    }
    
    func navigateToDetail(for property: Property) {
        let detailVC = ListingDetailVC()
        detailVC.isFromPush = false
        detailVC.objProperty = property
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Location
extension ListingsVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLat = location.coordinate.latitude
        currentLng = location.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 15.0)
        mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
        
        toggleMapView(showMap: false)
        pageInfo = nil
        wsGetProperties()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("❌ Location Error: \(error.localizedDescription)")
    }
}

// MARK: - Map Helpers
private extension ListingsVC {
    
    func formatPrice(_ price: Int) -> String {
        let value = Double(price)
        if value >= 1_000_000 { return String(format: "%.1f مليون", value / 1_000_000) }
        if value >= 1_000 { return String(format: "%.0f ألف", value / 1_000) }
        return "\(price)"
    }
    
    func addPropertyMarkers() {
        mapView.clear()
        arrProperty.forEach { property in
            let coords = property.location.coordinates
            guard coords.count >= 2, coords[0] != 0, coords[1] != 0 else { return }
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0]))
            if property.user == UserDefaultsHelper.getUserFromDefaults()?.userId {
                marker.icon = createPriceMarkerImage(price: formatPrice(property.price),
                                                     color: UIColor.themePrimaryColor,icon: UIImage(named: "icn_sar_white"))
            } else {
                marker.icon = createPriceMarkerImage(price: formatPrice(property.price),
                                                     color: UIColor.black,icon:  UIImage(named: "icn_sar_white"))
            }
            marker.userData = property
            marker.map = mapView
        }
        zoomToFitAllMarkers()
    }
    
    func zoomToFitAllMarkers() {
        guard !arrProperty.isEmpty else { return }
        var bounds = GMSCoordinateBounds()
        arrProperty.forEach { property in
            let coords = property.location.coordinates
            guard coords.count >= 2, coords[0] != 0, coords[1] != 0 else { return }
            bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0]))
        }
        
        // apply camera update
        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
        mapView.animate(with: update)
        
        // after animation - fix normal zoom
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self = self else { return }
            if self.mapView.camera.zoom > 15 {   // 15 = normal *max*
                let camera = GMSCameraPosition(target: self.mapView.camera.target, zoom: 15)
                self.mapView.animate(to: camera)
            }
        }
    }
    
    func createPriceMarkerImage(price: String, color: UIColor, icon: UIImage? = nil) -> UIImage? {
        
        let bubble = UIView()
        bubble.backgroundColor = color
        bubble.layer.cornerRadius = 12
        bubble.layer.masksToBounds = true
        
        let label = UILabel()
        label.text = price
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        
        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: icon == nil ? 0 : 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = icon == nil ? 0 : 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        bubble.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12)
        ])
        
        // layout once to get correct size
        bubble.setNeedsLayout()
        bubble.layoutIfNeeded()
        
        let bubbleSize = bubble.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        bubble.frame = CGRect(origin: .zero, size: bubbleSize)
        
        // container with bubble + triangle
        let containerHeight = bubbleSize.height + 8
        let container = UIView(frame: CGRect(x: 0, y: 0, width: bubbleSize.width, height: containerHeight))
        bubble.frame.origin = .zero
        container.addSubview(bubble)
        
        // triangle draw
        let trianglePath = UIBezierPath()
        let triangleWidth: CGFloat = 14
        trianglePath.move(to: CGPoint(x: (bubbleSize.width - triangleWidth)/2, y: bubbleSize.height))
        trianglePath.addLine(to: CGPoint(x: (bubbleSize.width + triangleWidth)/2, y: bubbleSize.height))
        trianglePath.addLine(to: CGPoint(x: bubbleSize.width/2, y: containerHeight))
        trianglePath.close()
        
        let triangleLayer = CAShapeLayer()
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = color.cgColor
        container.layer.addSublayer(triangleLayer)
        
        // safe renderer
        let renderer = UIGraphicsImageRenderer(size: container.bounds.size)
        let image = renderer.image { _ in
            container.drawHierarchy(in: container.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    func resetMapListingView() {
        arrMapProperty.removeAll()
        tblMapListing?.reloadData()
        tblMapListing?.isHidden = true
        mapTableHeight?.constant = 0
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    // MARK: - Button Action
    @objc func buttonTapped() {
        print("Button was tapped!")
        self.tblMapListing?.isHidden = true
    }
}

// MARK: - GMSMapViewDelegate
extension ListingsVC: GMSMapViewDelegate {
    
    @objc func closePopup() {
        
        // remove popup container
        addPinView?.removeFromSuperview()
        addPinView = nil
        
        // reset selected marker icon to original icon
        if let marker = selectedMarker, let icon = originalMarkerIcon {
            marker.icon = icon
        }
        
        // clear selection
        selectedMarker = nil
    }
    
    @objc func nextScreen() {
        guard let property = selectedProperty else { return }
        addPinView?.removeFromSuperview()
        navigateToDetail(for: property)
    }
    
    // MARK: - PIN TAP
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        guard let property = marker.userData as? Property else { return false }
        selectedProperty = property
        // Reset previous marker icon
        if let previous = selectedMarker, let icon = originalMarkerIcon {
            previous.icon = icon
        }
        
        selectedMarker = marker
        originalMarkerIcon = marker.icon
        
        // Highlight tapped pin (gray)
        marker.icon = createPriceMarkerImage(
            price: formatPrice(property.price),
            color: UIColor.lightGray,
            icon: UIImage(named: "icn_sar_white")
        )
        
        // Move map camera to marker
        let camera = GMSCameraPosition(target: marker.position, zoom: mapView.camera.zoom)
        mapView.animate(to: camera)
        
        // Remove old popup
        addPinView?.removeFromSuperview()
        
        // Load popup content view (AddPinView)
        let card = Bundle.main.loadNibNamed("AddPinView", owner: self, options: nil)!.first as! AddPinView
        card.configureWith(property: property)
        card.btnClose.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        card.btnNext.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
        // Popup card size
        let popupWidth = UIScreen.main.bounds.width - 20   // 10 + 10
        let popupHeight: CGFloat = 140
        let arrowHeight: CGFloat = 10
        
        // Container = card + arrow
        let containerHeight = popupHeight + arrowHeight
        let container = UIView(frame: CGRect(x: 10, y: 0, width: popupWidth, height: containerHeight))
        container.backgroundColor = .clear
        
        // Add card inside
        card.frame = CGRect(x: 0, y: 0, width: popupWidth, height: popupHeight)
        container.addSubview(card)
        
        // Add arrow pointer
        //        let arrow = createArrow(width: popupWidth, color: .white)
        //        arrow.frame.origin.y = popupHeight
        //        container.addSubview(arrow)
        
        addPinView = container
        
        // marker → screen point
        let point = mapView.projection.point(for: marker.position)
        
        // popup should appear above marker with visible marker margin
        let extraGap: CGFloat = 30   // this makes pin visible below popup
        
        var containerY = point.y - containerHeight - extraGap
        
        // Safe area protection
        let topSafe = (view.window?.safeAreaInsets.top ?? 20) + 10
        if containerY < topSafe { containerY = topSafe }
        
        container.frame.origin.y = containerY
        
        // Animation
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        
        mapView.addSubview(container)
        
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.6,
            options: .curveEaseOut,
            animations: {
                container.alpha = 1
                container.transform = .identity
            })
        
        return true
    }
    
    // MARK: - TAP OUTSIDE → REMOVE POPUP
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        addPinView?.removeFromSuperview()
        
        if let marker = selectedMarker, let icon = originalMarkerIcon {
            marker.icon = icon
        }
        
        selectedMarker = nil
    }
    
    // MARK: - FOLLOW MARKER WHEN MOVING MAP
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        guard let marker = selectedMarker, let container = addPinView else { return }
        
        let point = mapView.projection.point(for: marker.position)
        
        let extraGap: CGFloat = 30
        let popupHeight = container.frame.height
        
        let newY = point.y - popupHeight - extraGap
        
        UIView.animate(withDuration: 0.12) {
            container.frame.origin.y = newY
            container.frame.origin.x = 10
        }
    }
}

// MARK: - Web Service
private extension ListingsVC {
    
    func wsGetProperties() {
        Utility.showLoading()
        let pageValue = pageInfo?.page ?? 0
        var lat = 0.0
        var lng = 0.0
        if ListingFilterKeys.lng != nil ||  ListingFilterKeys.lat != nil {
            lat = ListingFilterKeys.lat ?? 0.0
            lng = ListingFilterKeys.lng ?? 0.0
        } else{
            lat = currentLat ?? 0.0
            lng = currentLng ?? 0.0
        }
        var url = "\(WebService.PROPERTY)shared/?page=\((pageValue) + 1)&size=20&sort=price&lng=\(lng)&lat=\(lat)&distance=\(defaultRadiusInMeters)"
        url += getFilter()
        
        WebServices.Get(url: url, type: PropertyResponse.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else { return }
            guard response != nil else { return }
            DispatchQueue.main.async { self.refreshControl.endRefreshing() }
            
            guard let pageResponse = response else { return }
            DispatchQueue.main.async {
                if self.pageInfo == nil || pageResponse.totalPages == 1 {
                    self.arrProperty = pageResponse.content
                } else {
                    self.arrProperty.append(contentsOf: pageResponse.content)
                }
                self.pageInfo = pageResponse
                self.tblListing?.reloadData()
                self.addPropertyMarkers()
                self.tblListing?.isHidden = self.arrProperty.isEmpty
                self.lblNoData?.isHidden = !self.arrProperty.isEmpty
            }

        }
    }
    
    func getProfile() {
        WebServices.Get(url: WebService.PROFILE, type: UserModel.self) { [weak self] (response: UserModel?) in
            guard let self = self else { return }
            guard let response = response else { return }
            let topic = response.id.replacingOccurrences(of: "-", with: "")
            UserDefaultsHelper.shared.topic = topic
            Messaging.messaging().subscribe(toTopic: topic)
            if response.displayName != "" {
                UserDefaultsHelper.shared.displayName = response.displayName
            }
        }
    }
}
