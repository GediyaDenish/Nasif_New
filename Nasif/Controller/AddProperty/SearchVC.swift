//
//  SearchVC.swift
//  Nasif
//
//  Created by Denish Gediya on 08/07/25.
//

import UIKit

class SearchVC: UIViewController {
    // MARK: - IBOutlets (keep as in Interface Builder)
    @IBOutlet private weak var txtMinAge: UITextField?
    @IBOutlet private weak var txtMaxAge: UITextField?
    @IBOutlet private weak var txtLessArea: UITextField?
    @IBOutlet private weak var txtMoreArea: UITextField?
    @IBOutlet private weak var cvSelectType: UICollectionView?
    @IBOutlet private weak var txtCity: UITextField!
    @IBOutlet private weak var lblTitle: UILabel?
    @IBOutlet private weak var vwListingNumber: UIView?
    @IBOutlet private weak var txtListingNo: UITextField?
    @IBOutlet private var lblSubTitle: [UILabel]?
    @IBOutlet private var vwTxtBG: [UIView]?
    @IBOutlet private weak var cvRealEstateType: UICollectionView?
    @IBOutlet private weak var txtLessThan: UITextField?
    @IBOutlet private weak var txtMoreThan: UITextField?
    @IBOutlet private weak var cvBuildingFacing: UICollectionView?
    @IBOutlet private var lblSarTitle: [UILabel]?
    @IBOutlet private weak var cvNumberStreets: UICollectionView?
    @IBOutlet private weak var cvVillaSubtype: UICollectionView?
    @IBOutlet private weak var cvTypeOfLand: UICollectionView?
    @IBOutlet private weak var cvFloorNumber: UICollectionView?
    @IBOutlet private weak var cvHowManyFloors: UICollectionView?
    @IBOutlet private weak var cvBedRoom: UICollectionView?
    @IBOutlet private weak var cvBathRoom: UICollectionView?
    @IBOutlet private weak var cvLivingRoom: UICollectionView?
    @IBOutlet private weak var cvAvailableParking: UICollectionView?
    @IBOutlet private weak var cvExtraFeatures: UICollectionView?
    @IBOutlet private weak var cvAvailabilityList: UICollectionView?
    @IBOutlet private weak var btnSearch: UIButton?
    @IBOutlet private weak var vwBuildingFacing: UIView?
    @IBOutlet private weak var vwNumberOfStreets: UIView?
    @IBOutlet private weak var vwOldRealEstate: UIView?
    @IBOutlet private weak var vwVillaType: UIView?
    @IBOutlet private weak var vwTypeOfLand: UIView?
    @IBOutlet private weak var vwFloorNumber: UIView?
    @IBOutlet private weak var vwHowManyFloors: UIView?
    @IBOutlet private weak var vwBadroomNumber: UIView?
    @IBOutlet private weak var vwBathroomNumber: UIView?
    @IBOutlet private weak var vwLivingRoom: UIView?
    @IBOutlet private weak var vwAvailableParking: UIView?
    @IBOutlet weak var txtNeighbourhood: UITextField?
    
    @IBOutlet weak var lblCityTitle: UILabel!
    @IBOutlet weak var lblNeighbourhoodTitle: UILabel!
    @IBOutlet weak var lblRealTitle: UILabel!
    @IBOutlet weak var lblPriceTitle: UILabel!
    @IBOutlet weak var lblTotalSquareTitle: UILabel!
    @IBOutlet weak var lblBuildingTitle: UILabel!
    @IBOutlet weak var lblNumberStreetsTitle: UILabel!
    @IBOutlet weak var lblHowOldReal: UILabel!
    @IBOutlet weak var lblVillSubType: UILabel!
    @IBOutlet weak var lblTypeLand: UILabel!
    @IBOutlet weak var lblFloorNumberTitle: UILabel!
    @IBOutlet weak var lblHowManyFloor: UILabel!
    @IBOutlet weak var lblBedRoomTitle: UILabel!
    @IBOutlet weak var lblBathroomTitle: UILabel!
    @IBOutlet weak var lblLivingTitle: UILabel!
    @IBOutlet weak var lblAvailabelTitle: UILabel!
    @IBOutlet weak var lblExtraTitle: UILabel!
    @IBOutlet weak var lblAvailabilityList: UILabel!
    
    // MARK: - Data sources (private)
    private let arrSecondAvailabilityList = [
        "Apartment",
        "Building Complex",
        "Chalet",
        "Farm",
        "Floor",
        "Land",
        "Other",
        "Villa"
    ]
    private let arrBuildingFacing = ["East", "North", "South", "West"]
    private let arrVillSubtype = ["Duplex", "Toenhouse", "Villa"]
    private let arrTypeOfLand = ["Commercial", "Farming", "Raw Land", "Residential"]
    private let arrNumberStreets = ["1","2","3","4"]
    private let arrFloorNumber = ["0", "1", "2", "3", "+4"]
    private let arrTotalFloors = ["1", "2", "3", "4", "5", "+6"]
    private let arrBedroomNumber = ["1", "2", "3", "4", "5", "+6"]
    private let arrBathroomNumber = ["1", "2", "3", "4", "5", "+6"]
    private let arrLivingRoom = ["1", "2", "3", "4", "5", "+6"]
    private let arrAvailableParking = ["1", "2", "3", "4", "5", "+6"]
    private var arrExtraFeatures: [String] = [
        "AC", "Backyard", "Balcony", "Compound Complex", "Driver Room", "Furnished",
        "Housemaid Room", "Kitchen", "Laundry Room", "Private Entrance", "Top Floor",
        "Underground Parking"
    ]
    private var arrAvailabilityList: [String] = ["Available", "Reserved", "Sold"]
    private let arrSelectType: [String] = ["Rent", "Sale"]
    
    // MARK: - Selection state
    private var secondSelectedIndex: Int?
    private var secondBuildingFacing: Int?
    private var selectNumberStreets: Int?
    private var selectVillaSubtype: Int?
    private var selectTypeOfLandIndices: [Int] = []
    private var selectFloorsNumber: Int?
    private var selectHowManyFloors: Int?
    private var selectBedroomNumber: Int?
    private var selectBathroomNumber: Int?
    private var selectLivingRoom: Int?
    private var selectAvailableParking: Int?
    private var selectedExtraIndices: [Int] = []
    private var selectRealEstate: Int?
    private var selectSelectType: Int?
    var objCity: CityModel?
    
    // MARK: - Constants
    private let cellReuseId = "ListTypeCVCell"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfig()
    }
}

// MARK: - Actions
extension SearchVC {
    @IBAction func btnOnClickNeighbourhood(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddList", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddNeighborhoodsVC") as? AddNeighborhoodsVC {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.onDismiss = { [weak self] city in
                guard let self else { return }
                self.objCity = city
                self.txtNeighbourhood?.text  = self.objCity?.cityEn
                
                ListingFilterKeys.lng = self.objCity?.lon ?? 0.0
                ListingFilterKeys.lat = self.objCity?.lat ?? 0.0
                
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickSearch(_ sender: UIButton) {
        // Helper to safely fetch values
        func trimmed(_ s: String?) -> String? {
            guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
            return t
        }
        func positiveInt(from text: String?) -> Int? {
            guard let t = trimmed(text), let v = Int(t), v > 0 else { return nil }
            return v
        }
        
        // availableFor
        if let idx = selectSelectType, arrSelectType.indices.contains(idx) {
            let value = trimmed(arrSelectType[idx])
            ListingFilterKeys.availableFor = value
        } else {
            ListingFilterKeys.availableFor = nil
        }
        
        ListingFilterKeys.city = trimmed(txtCity?.text)
        ListingFilterKeys.neighbourhood = trimmed(txtNeighbourhood?.text)
        ListingFilterKeys.search = trimmed(txtListingNo?.text)
        
        ListingFilterKeys.minAge = positiveInt(from: txtMinAge?.text)
        ListingFilterKeys.maxAge = positiveInt(from: txtMaxAge?.text)
        ListingFilterKeys.minArea = positiveInt(from: txtLessArea?.text)
        ListingFilterKeys.maxArea = positiveInt(from: txtMoreArea?.text)
        ListingFilterKeys.minPrice = positiveInt(from: txtLessThan?.text)
        ListingFilterKeys.maxPrice = positiveInt(from: txtMoreThan?.text)
        
        if let idx = secondBuildingFacing, arrBuildingFacing.indices.contains(idx) {
            ListingFilterKeys.facing = trimmed(arrBuildingFacing[idx])
        } else { ListingFilterKeys.facing = nil }
        
        if let idx = selectVillaSubtype, arrVillSubtype.indices.contains(idx) {
            ListingFilterKeys.vilaType = trimmed(arrVillSubtype[idx])
        } else { ListingFilterKeys.vilaType = nil }
        
        if let idx = selectRealEstate, arrAvailabilityList.indices.contains(idx) {
            ListingFilterKeys.status = trimmed(arrAvailabilityList[idx])
        } else { ListingFilterKeys.status = nil }
        
        let selectedUses = selectTypeOfLandIndices.compactMap { i -> String? in
            guard arrTypeOfLand.indices.contains(i) else { return nil }
            return trimmed(arrTypeOfLand[i])
        }
        ListingFilterKeys.useFor = selectedUses.isEmpty ? nil : selectedUses.joined(separator: ",")
        
        let selectedExtra = selectedExtraIndices.compactMap { i -> String? in
            guard arrExtraFeatures.indices.contains(i) else { return nil }
            return trimmed(arrExtraFeatures[i])
        }
        ListingFilterKeys.extraFeatures = selectedExtra.isEmpty ? nil : selectedExtra.joined(separator: ",")
        
        if let idx = secondSelectedIndex, arrSecondAvailabilityList.indices.contains(idx) {
            ListingFilterKeys.type = trimmed(arrSecondAvailabilityList[idx])
        } else { ListingFilterKeys.type = nil }
        
        if let idx = selectFloorsNumber, arrFloorNumber.indices.contains(idx),
           let v = Int(arrFloorNumber[idx].trimmingCharacters(in: .whitespacesAndNewlines)) {
            ListingFilterKeys.floorNumber = v
        } else { ListingFilterKeys.floorNumber = nil }
        
        if let idx = selectBedroomNumber, arrBedroomNumber.indices.contains(idx),
           let v = Int(arrBedroomNumber[idx].trimmingCharacters(in: .whitespacesAndNewlines)) {
            ListingFilterKeys.totalBedrooms = v
        } else { ListingFilterKeys.totalBedrooms = nil }
        
        if let idx = selectBathroomNumber, arrBathroomNumber.indices.contains(idx),
           let v = Int(arrBathroomNumber[idx].trimmingCharacters(in: .whitespacesAndNewlines)) {
            ListingFilterKeys.totalBathrooms = v
        } else { ListingFilterKeys.totalBathrooms = nil }
        
        if let idx = selectLivingRoom, arrLivingRoom.indices.contains(idx),
           let v = Int(arrLivingRoom[idx].trimmingCharacters(in: .whitespacesAndNewlines)) {
            ListingFilterKeys.totalLivingrooms = v
        } else { ListingFilterKeys.totalLivingrooms = nil }
        
        if let idx = selectAvailableParking, arrAvailableParking.indices.contains(idx),
           let v = Int(arrAvailableParking[idx].trimmingCharacters(in: .whitespacesAndNewlines)) {
            ListingFilterKeys.availableParking = v
        } else { ListingFilterKeys.availableParking = nil }
        
        if let idx = selectHowManyFloors, arrTotalFloors.indices.contains(idx),
           let v = Int(arrTotalFloors[idx].trimmingCharacters(in: .whitespacesAndNewlines)) {
            ListingFilterKeys.totalFloors = v
        } else { ListingFilterKeys.totalFloors = nil }
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI setup
private extension SearchVC {
    func initConfig() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
        
        // style labels and backgrounds
        lblTitle?.font = FontHelper.font(size: 20.0, type: .Regular)
        lblSubTitle?.forEach {
            $0.textColor = .black
            $0.font = FontHelper.font(size: 15.0, type: .Regular)
        }
        lblSarTitle?.forEach {
            $0.textColor = .black
            $0.font = FontHelper.font(size: 12.0, type: .Regular)
        }
        vwTxtBG?.forEach {
            $0.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 8.0, borderWidth: 1.0)
        }
        vwListingNumber?.setRound(withBorderColor: UIColor.clear, andCornerRadious: 22.0, borderWidth: 0.0)
        btnSearch?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        btnSearch?.setupButton(borderColor: .clear, andCornerRadious: 8.0)
        
        // configure all collection views with helper
        configureCollectionView(cvSelectType, tag: .selectType, isScrollEnabled: false, flowDirection: .horizontal)
        configureCollectionView(cvRealEstateType, tag: .realEstateType, isScrollEnabled: false)
        configureCollectionView(cvBuildingFacing, tag: .buildingFacing, isScrollEnabled: false)
        configureCollectionView(cvNumberStreets, tag: .numberStreets, isScrollEnabled: true, flowDirection: .horizontal)
        configureCollectionView(cvVillaSubtype, tag: .villaSubtype, isScrollEnabled: false)
        configureCollectionView(cvTypeOfLand, tag: .typeOfLand, isScrollEnabled: false)
        configureCollectionView(cvFloorNumber, tag: .floorNumber, isScrollEnabled: false)
        configureCollectionView(cvHowManyFloors, tag: .howManyFloors, isScrollEnabled: false)
        configureCollectionView(cvBedRoom, tag: .bedRoom, isScrollEnabled: false)
        configureCollectionView(cvBathRoom, tag: .bathRoom, isScrollEnabled: false)
        configureCollectionView(cvLivingRoom, tag: .livingRoom, isScrollEnabled: false)
        configureCollectionView(cvAvailableParking, tag: .availableParking, isScrollEnabled: false)
        configureCollectionView(cvExtraFeatures, tag: .extraFeatures, isScrollEnabled: false, isPaging: false)
        configureCollectionView(cvAvailabilityList, tag: .availabilityList, isScrollEnabled: false)
        
        // set default visibility (if needed)
        manageViews(index: secondSelectedIndex ?? 0)
        
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle?.text = "Search".localized
        self.lblCityTitle?.text = "City".localized
        self.lblNeighbourhoodTitle?.text = "NeighborHood".localized
        self.lblRealTitle?.text = "Real estate type".localized
        self.lblPriceTitle?.text = "Price".localized
        self.lblTotalSquareTitle?.text = "Total square metres :".localized
        self.lblBuildingTitle?.text = "Building facing :".localized
        self.lblNumberStreetsTitle?.text = "Number of streets :".localized
        self.lblHowOldReal?.text = "How old is the real estate".localized
        self.lblVillSubType?.text = "Villa subtype :".localized
        self.lblTypeLand?.text = "Type of the land".localized
        self.lblFloorNumberTitle?.text = "Floor number".localized
        self.lblHowManyFloor?.text = "How many floors".localized
        self.lblBedRoomTitle?.text = "Bedroom number".localized
        self.lblBathroomTitle?.text = "Bathroom number".localized
        self.lblLivingTitle?.text = "Living room and sitting area number".localized
        self.lblAvailabelTitle?.text = "Available parking".localized
        self.lblExtraTitle?.text = "Extra features".localized
        self.lblAvailabilityList?.text = "Availability of the listing".localized
        self.btnSearch?.setTitle("Search".localized, for: .normal)
        self.txtLessArea?.placeholder = "Less than".localized
        self.txtLessThan?.placeholder = "Less than".localized
        self.txtMoreArea?.placeholder = "More than".localized
        self.txtMoreThan?.placeholder = "More than".localized
        self.txtListingNo?.placeholder = "Listing Number".localized
        self.txtCity?.placeholder = "All".localized
        self.txtNeighbourhood?.placeholder = "All".localized
    }
    
    enum CollectionTag: Int {
        case selectType = 1, realEstateType, buildingFacing, numberStreets, villaSubtype,
             typeOfLand, floorNumber, howManyFloors, bedRoom, bathRoom, livingRoom,
             availableParking, extraFeatures, availabilityList
    }
    
    func configureCollectionView(_ cv: UICollectionView?, tag: CollectionTag, isScrollEnabled: Bool, flowDirection: UICollectionView.ScrollDirection = .vertical, isPaging: Bool = false) {
        guard let cv = cv else { return }
        cv.tag = tag.rawValue
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = isScrollEnabled
        cv.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: cellReuseId)
        cv.semanticContentAttribute = .forceRightToLeft
        
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = flowDirection
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        } else if flowDirection == .horizontal {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            cv.collectionViewLayout = layout
        }
        
        if isPaging {
            cv.isPagingEnabled = true
        }
    }
}

// MARK: - CollectionView datasource/delegate
extension SearchVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func items(for collectionView: UICollectionView) -> [String] {
        switch CollectionTag(rawValue: collectionView.tag) {
        case .selectType: return arrSelectType
        case .realEstateType: return arrSecondAvailabilityList
        case .buildingFacing: return arrBuildingFacing
        case .numberStreets: return arrNumberStreets
        case .villaSubtype: return arrVillSubtype
        case .typeOfLand: return arrTypeOfLand
        case .floorNumber: return arrFloorNumber
        case .howManyFloors: return arrTotalFloors
        case .bedRoom: return arrBedroomNumber
        case .bathRoom: return arrBathroomNumber
        case .livingRoom: return arrLivingRoom
        case .availableParking: return arrAvailableParking
        case .extraFeatures: return arrExtraFeatures
        case .availabilityList: return arrAvailabilityList
        default: return []
        }
    }
    
    private func isSelected(indexPath: IndexPath, in collectionView: UICollectionView) -> Bool {
        switch CollectionTag(rawValue: collectionView.tag) {
        case .selectType: return selectSelectType == indexPath.item
        case .realEstateType: return secondSelectedIndex == indexPath.item
        case .buildingFacing: return secondBuildingFacing == indexPath.item
        case .numberStreets: return selectNumberStreets == indexPath.item
        case .villaSubtype: return selectVillaSubtype == indexPath.item
        case .typeOfLand: return selectTypeOfLandIndices.contains(indexPath.item)
        case .floorNumber: return selectFloorsNumber == indexPath.item
        case .howManyFloors: return selectHowManyFloors == indexPath.item
        case .bedRoom: return selectBedroomNumber == indexPath.item
        case .bathRoom: return selectBathroomNumber == indexPath.item
        case .livingRoom: return selectLivingRoom == indexPath.item
        case .availableParking: return selectAvailableParking == indexPath.item
        case .extraFeatures: return selectedExtraIndices.contains(indexPath.item)
        case .availabilityList: return selectRealEstate == indexPath.item
        default: return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items(for: collectionView).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as? ListTypeCVCell else {
            return UICollectionViewCell()
        }
        
        let title = items(for: collectionView)[indexPath.item]
        let selected = isSelected(indexPath: indexPath, in: collectionView)
        
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.masksToBounds = true
        cell.lblType?.textColor = selected ? .white : UIColor.themeBorderColor808080
        cell.contentView.backgroundColor = selected ? UIColor.black : .white
        cell.contentView.layer.borderColor = selected ? UIColor.clear.cgColor : UIColor.themeBorderColor808080.cgColor
        cell.contentView.layer.borderWidth = selected ? 0.0 : 1.0
        
        cell.configure(with: title.localized)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch CollectionTag(rawValue: collectionView.tag) {
        case .selectType:
            selectSelectType = indexPath.item
            collectionView.reloadData()
            
        case .realEstateType:
            secondSelectedIndex = indexPath.item
            collectionView.reloadData()
            manageViews(index: indexPath.item)
            
        case .buildingFacing:
            secondBuildingFacing = indexPath.item
            collectionView.reloadData()
            
        case .numberStreets:
            selectNumberStreets = indexPath.item
            collectionView.reloadData()
            
        case .villaSubtype:
            selectVillaSubtype = indexPath.item
            collectionView.reloadData()
            
        case .typeOfLand:
            if let idx = selectTypeOfLandIndices.firstIndex(of: indexPath.item) {
                selectTypeOfLandIndices.remove(at: idx)
            } else {
                selectTypeOfLandIndices.append(indexPath.item)
            }
            collectionView.reloadData()
            
        case .floorNumber:
            selectFloorsNumber = indexPath.item
            collectionView.reloadData()
            
        case .howManyFloors:
            selectHowManyFloors = indexPath.item
            collectionView.reloadData()
            
        case .bedRoom:
            selectBedroomNumber = indexPath.item
            collectionView.reloadData()
            
        case .bathRoom:
            selectBathroomNumber = indexPath.item
            collectionView.reloadData()
            
        case .livingRoom:
            selectLivingRoom = indexPath.item
            collectionView.reloadData()
            
        case .availableParking:
            selectAvailableParking = indexPath.item
            collectionView.reloadData()
            
        case .extraFeatures:
            if let idx = selectedExtraIndices.firstIndex(of: indexPath.item) {
                selectedExtraIndices.remove(at: idx)
            } else {
                selectedExtraIndices.append(indexPath.item)
            }
            collectionView.reloadData()
            
        case .availabilityList:
            selectRealEstate = indexPath.item
            collectionView.reloadData()
            
        default:
            break
        }
    }
    
    // MARK: - sizing
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let texts = items(for: collectionView)
        guard indexPath.item < texts.count else { return .zero }
        let text = texts[indexPath.item]
        
        switch CollectionTag(rawValue: collectionView.tag) {
        case .selectType, .availabilityList:
            let font = UIFont.systemFont(ofSize: 14)
            let width = text.size(withAttributes: [.font: font]).width + 32
            return CGSize(width: width, height: 36)
            
        case .realEstateType, .typeOfLand, .buildingFacing:
            let spacing: CGFloat = 10
            let totalSpacing = spacing * 3
            let availableWidth = max(collectionView.bounds.width - totalSpacing, 0)
            let itemWidth = floor(availableWidth / 4)
            return CGSize(width: itemWidth, height: 40)
            
        case .villaSubtype:
            let spacing: CGFloat = 10
            let totalSpacing = spacing * 2
            let availableWidth = max(collectionView.bounds.width - totalSpacing, 0)
            let itemWidth = floor(availableWidth / 3)
            return CGSize(width: itemWidth, height: 40)
            
        case .extraFeatures:
            let spacing: CGFloat = 10
            let totalSpacing = spacing * 2
            let availableWidth = max(collectionView.bounds.width - totalSpacing, 0)
            let itemWidth = floor(availableWidth / 3)
            return CGSize(width: itemWidth, height: 40)
            
        case .numberStreets, .floorNumber, .howManyFloors, .bedRoom, .bathRoom, .livingRoom, .availableParking:
            return CGSize(width: 46, height: 40)
            
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch CollectionTag(rawValue: collectionView.tag) {
        case .selectType, .availabilityList, .extraFeatures:
            return 10
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        switch CollectionTag(rawValue: collectionView.tag) {
        case .selectType:
            return centeredInset(for: arrSelectType, in: collectionView)
        case .availabilityList:
            return centeredInset(for: arrAvailabilityList, in: collectionView)
        default:
            return .zero
        }
    }
    
    private func centeredInset(for items: [String], in collectionView: UICollectionView) -> UIEdgeInsets {
        let font = UIFont.systemFont(ofSize: 14)
        let totalCellWidth = items.reduce(0) { $0 + $1.size(withAttributes: [.font: font]).width + 32 }
        let spacing: CGFloat = 10
        let totalSpacing = spacing * CGFloat(max(items.count - 1, 0))
        let totalWidth = totalCellWidth + totalSpacing
        let horizontalInset = max((collectionView.bounds.width - totalWidth) / 2, 0)
        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
}

// MARK: - View Visibility (manageViews)
private extension SearchVC {
    struct ViewVisibility {
        var buildingFacing = false
        var numberStreets = false
        var oldRealEstate = false
        var villaType = false
        var typeOfLand = false
        var floorNumber = false
        var howManyFloors = false
        var bedroomNumber = false
        var bathroomNumber = false
        var livingRoom = false
        var availableParking = false
    }
    
    func manageViews(index: Int) {
        // Map index -> visibility config
        let config: ViewVisibility
        switch index {
        case 0: // Land
            config = ViewVisibility(buildingFacing: true, numberStreets: true, typeOfLand: true)
        case 1: // Villa
            config = ViewVisibility(buildingFacing: true, numberStreets: true, oldRealEstate: true, villaType: true, bedroomNumber: true, bathroomNumber: true, livingRoom: true, availableParking: true)
        case 2: // Apartment
            config = ViewVisibility(oldRealEstate: true, floorNumber: true, bedroomNumber: true, bathroomNumber: true, livingRoom: true, availableParking: true)
        case 3: // Floor
            config = ViewVisibility(buildingFacing: true, numberStreets: true, oldRealEstate: true, floorNumber: true, bedroomNumber: true, bathroomNumber: true, livingRoom: true, availableParking: true)
        case 4: // Building complex
            config = ViewVisibility(buildingFacing: true, numberStreets: true, oldRealEstate: true, howManyFloors: true)
        case 5: // Chalet
            config = ViewVisibility(buildingFacing: true, numberStreets: true, oldRealEstate: true)
        case 6: // Farm
            config = ViewVisibility() // everything false
        case 7: // Other
            config = ViewVisibility()
        default:
            config = ViewVisibility()
        }
        
        vwBuildingFacing?.isHidden = !config.buildingFacing
        vwNumberOfStreets?.isHidden = !config.numberStreets
        vwOldRealEstate?.isHidden = !config.oldRealEstate
        vwVillaType?.isHidden = !config.villaType
        vwTypeOfLand?.isHidden = !config.typeOfLand
        vwFloorNumber?.isHidden = !config.floorNumber
        vwHowManyFloors?.isHidden = !config.howManyFloors
        vwBadroomNumber?.isHidden = !config.bedroomNumber
        vwBathroomNumber?.isHidden = !config.bathroomNumber
        vwLivingRoom?.isHidden = !config.livingRoom
        vwAvailableParking?.isHidden = !config.availableParking
    }
}
