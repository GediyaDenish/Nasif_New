//
//  AddListVC.swift
//  Nasif
//
//  Created by Denish Gediya on 07/07/25.
//

import UIKit

class AddListVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vwAvailability: UIView!
    @IBOutlet weak var cvSelectType: UICollectionView?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var vwProgress: UIView?
    @IBOutlet weak var lblAvailabilityList: UILabel?
    @IBOutlet weak var cvAvailabilityList: UICollectionView?
    @IBOutlet weak var lblRealType: UILabel?
    @IBOutlet weak var cvSecondAvailabilityList: UICollectionView?
    @IBOutlet var lblSubTitle: [UILabel]?
    @IBOutlet var vwTxtBG: [UIView]?
    @IBOutlet weak var txtNorth: UITextField?
    @IBOutlet weak var txtEast: UITextField?
    @IBOutlet weak var txtWest: UITextField?
    @IBOutlet weak var txtSouth: UITextField?
    
    @IBOutlet weak var txtPrice: UITextField?
    @IBOutlet weak var txtTotalSquare: UITextField?
    @IBOutlet weak var txtEstateAge: UITextField?
    @IBOutlet weak var cvVilla: UICollectionView?
    @IBOutlet weak var cvIntended: UICollectionView?
    
    @IBOutlet weak var btnFloorNumberMinus: UIButton?
    @IBOutlet weak var lblTotalFloorNumber: UILabel?
    @IBOutlet weak var btnFloorNumberPlus: UIButton?
    
    @IBOutlet weak var btnAvailabelFloorMinus: UIButton?
    @IBOutlet weak var lblAvailabelFloor: UILabel?
    @IBOutlet weak var btnAvailabelFloorPlus: UIButton?
    
    @IBOutlet weak var btnBedroomNumberMinus: UIButton?
    @IBOutlet weak var lblBedroomNumber: UILabel?
    @IBOutlet weak var btnBedroomNumberPlus: UIButton?
    
    @IBOutlet weak var btnBathroomNumberMinus: UIButton!
    @IBOutlet weak var lblBathroomNumber: UILabel?
    @IBOutlet weak var btnBathroomNumberPlus: UIButton?
    
    @IBOutlet weak var btnLivingRoomMinus: UIButton?
    @IBOutlet weak var lblLivingRoom: UILabel?
    @IBOutlet weak var btnLivingRoomPlus: UIButton?
    
    @IBOutlet weak var btnAvailableParkingMinus: UIButton?
    @IBOutlet weak var lblAvailableParking: UILabel?
    @IBOutlet weak var btnAvailableParkingPlus: UIButton?
    
    @IBOutlet weak var cvService: UICollectionView?
    @IBOutlet weak var cvExtraFeatures: UICollectionView?
    @IBOutlet weak var btnNext: UIButton?
    
    @IBOutlet weak var vwMainVillatype: UIView!
    @IBOutlet weak var vwMainFloorNumber: UIView!
    @IBOutlet weak var vwMainAvailableFloors: UIView!
    @IBOutlet weak var vwMainBedroomNumber: UIView!
    @IBOutlet weak var vwMainBathroomNumber: UIView!
    @IBOutlet weak var vwMainLivingroom: UIView!
    @IBOutlet weak var vwMainAvailableParking: UIView!
    @IBOutlet weak var vwMainServices: UIView!
    @IBOutlet weak var vwMainExtraFeatures: UIView!
    @IBOutlet weak var vwMainRealextateAge: UIView!
    @IBOutlet weak var vwMainStreetWidthFacing: UIView!
    @IBOutlet weak var vwMainIntendedUse: UIView!
    
    @IBOutlet weak var vwAgeBg: UIView!
    @IBOutlet weak var vwNorthBg: UIView!
    @IBOutlet weak var vwEastBg: UIView!
    @IBOutlet weak var vwWestBg: UIView!
    @IBOutlet weak var vwSouthBg: UIView!
    
    @IBOutlet weak var switchAge: UISwitch!
    @IBOutlet weak var switchNorth: UISwitch!
    @IBOutlet weak var switchEast: UISwitch!
    @IBOutlet weak var switchWest: UISwitch!
    @IBOutlet weak var switchSouth: UISwitch!
    
    
    @IBOutlet weak var lblPriceTitle: UILabel!
    @IBOutlet weak var lblStreetTitle: UILabel!
    @IBOutlet weak var lblRealTitle: UILabel!
    @IBOutlet weak var lblTotalSquareTitle: UILabel!
    @IBOutlet weak var lblNorthTitle: UILabel!
    @IBOutlet weak var lblEastTitle: UILabel!
    @IBOutlet weak var lblWestTitle: UILabel!
    @IBOutlet weak var lblSouthTitle: UILabel!
    @IBOutlet weak var lblvillaTypeTitle: UILabel!
    @IBOutlet weak var lblIntendedUseTitle: UILabel!
    @IBOutlet weak var lblFloorNumberTitle: UILabel!
    @IBOutlet weak var lblAvailabelFloorTitle: UILabel!
    @IBOutlet weak var lblBedRoomTitle: UILabel!
    @IBOutlet weak var lblBathroomTitle: UILabel!
    @IBOutlet weak var lblLivingTitle: UILabel!
    @IBOutlet weak var lblAvailabelTitle: UILabel!
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var lblExtraTitle: UILabel!
    @IBOutlet weak var lblNewTitle: UILabel!
    
    @IBOutlet weak var txtDescription: UITextView?
    @IBOutlet weak var lblDesc: UILabel!
    
    // MARK: - Variables
    var isFromEdit: Bool = false
    var objProperty: Property?
    var arrAvailabilityList: [String] = ["Available", "Reserved", "Sold"]
    var indexPath: Int = 0
    
    var arrSelectType: [String] = ["Rent", "Sale"]
    var selectSelectType: Int?
    
    let arrSecondAvailabilityList: [String] = [
        "Land",
        "Villa",
        "Apartment",
        "Floor",
        "Building Complex",
        "Chalet",
        "Farm",
        "Other"
    ]
    var secondSelectedIndex: Int?
    
    var arrVillaList: [String] = ["Duplex", "Toenhouse", "Villa"]
    var selectVillaIndexPath: Int?
    
    var arrIntendedList: [String] = ["Commercial", "Farming", "Raw Land", "Residential"]
    var arrSelectIntendedList: [String] = []
    
    var arrService: [String] = [
        "Electricity",
        "Fiber-optic Internet",
        "Flood Disposal System",
        "Phone",
        "Running Water",
        "Sewage System"
    ]
    var arrSelectService: [String] = []
    
    var arrExtraFeatures: [String] = [ "AC",
                                       "Backyard",
                                       "Balcony",
                                       "Compound Complex",
                                       "Driver Room",
                                       "Furnished",
                                       "Housemaid Room",
                                       "Kitchen",
                                       "Laundry Room",
                                       "Private Entrance",
                                       "Top Floor",
                                       "Underground Parking"]
    
    var arrSelectExtraFeatures: [String] = []
    
    var floorNumber: Int = 0 {
        didSet {
            self.lblTotalFloorNumber?.text = "\(floorNumber)"
        }
    }
    
    var AvailableFloors: Int = 0 {
        didSet {
            self.lblAvailabelFloor?.text = "\(AvailableFloors)"
        }
    }
    
    var BedroomNumber: Int = 0 {
        didSet {
            self.lblBedroomNumber?.text = "\(BedroomNumber)"
        }
    }
    
    var BathroomNumber: Int = 0 {
        didSet {
            self.lblBathroomNumber?.text = "\(BathroomNumber)"
        }
    }
    
    var livingRoom: Int = 0 {
        didSet {
            self.lblLivingRoom?.text = "\(livingRoom)"
        }
    }
    
    var availableParking: Int = 0 {
        didSet {
            self.lblAvailableParking?.text = "\(availableParking)"
        }
    }
    var dictParam: [String: Any] = [:]
    
    //MARK: -  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.InitConfig()
    }
    
    @IBAction func switchAge(_ sender: UISwitch) {
        if sender.isOn {
            self.vwAgeBg.isHidden = true
        } else {
            self.vwAgeBg.isHidden = false
        }
    }
    
    @IBAction func switchNorth(_ sender: UISwitch) {
        if sender.isOn {
            self.vwNorthBg.isHidden = false
        } else {
            self.vwNorthBg.isHidden = true
        }
    }
    
    @IBAction func switchEast(_ sender: UISwitch) {
        if sender.isOn {
            self.vwEastBg.isHidden = false
        } else {
            self.vwEastBg.isHidden = true
        }
    }
    
    @IBAction func switchWest(_ sender: UISwitch) {
        if sender.isOn {
            self.vwWestBg.isHidden = false
        } else {
            self.vwWestBg.isHidden = true
        }
    }
    
    @IBAction func switchSouth(_ sender: UISwitch) {
        if sender.isOn {
            self.vwSouthBg.isHidden = false
        } else {
            self.vwSouthBg.isHidden = true
        }
    }
    
}

//MARK: - IBAction Mthonthd
extension AddListVC {
    @IBAction func btnOnClickAvailabelFloor(_ sender: UIButton) {
        if sender.tag == 0 {
            if AvailableFloors > 0 {
                AvailableFloors -= 1
            }
        } else {
            AvailableFloors += 1
        }
    }
    
    @IBAction func btnOnClickBedroomNumber(_ sender: UIButton) {
        if sender.tag == 0 {
            if BedroomNumber > 0 {
                BedroomNumber -= 1
            }
        } else {
            BedroomNumber += 1
        }
    }
    
    @IBAction func btnOnClickBathroomNumber(_ sender: UIButton) {
        if sender.tag == 0 {
            if BathroomNumber > 0 {
                BathroomNumber -= 1
            }
        } else {
            BathroomNumber += 1
        }
    }
    
    @IBAction func btnOnClickLivingRoom(_ sender: UIButton) {
        if sender.tag == 0 {
            if livingRoom > 0 {
                livingRoom -= 1
            }
        } else {
            livingRoom += 1
        }
    }
    
    @IBAction func btnOnClickAvailableParking(_ sender: UIButton) {
        if sender.tag == 0 {
            if availableParking > 0 {
                availableParking -= 1
            }
        } else {
            availableParking += 1
        }
    }
    
    @IBAction func btnOnClickNext(_ sender: UIButton) {
        self.view.endEditing(true)
        guard checkValidation() else { return }
        let storyboard = UIStoryboard(name: "AddList", bundle: nil)
        if let addLocationVC = storyboard.instantiateViewController(withIdentifier: "AddLocationVC") as? AddLocationVC {
            
            // MARK: - Dropdown Selections
            if let index = self.selectSelectType, self.arrSelectType.indices.contains(index) {
                dictParam[PARAMS.AVAILABLE_FOR] = self.arrSelectType[index]
            }
            
            let index = self.indexPath
            if self.arrAvailabilityList.indices.contains(index) {
                dictParam[PARAMS.STATUS] = self.arrAvailabilityList[index]
            }
            
            if let index = self.secondSelectedIndex, self.arrSecondAvailabilityList.indices.contains(index) {
                dictParam[PARAMS.TYPE] = self.arrSecondAvailabilityList[index]
            }
            
            if let index = self.selectVillaIndexPath, self.arrVillaList.indices.contains(index) {
                dictParam[PARAMS.VILA_TYPE] = self.arrVillaList[index]
            }
            
            //            if let index = self.selectedIndices, self.arrIntendedList.indices.contains(index) {
            //                dictParam[PARAMS.LAND_TYPE] = self.arrIntendedList[index]
            //            }
            
            let cleanPrice = txtPrice?.text?.replacingOccurrences(of: ",", with: "") ?? ""
            dictParam[PARAMS.PRICE] = cleanPrice
            let cleanSqure = txtTotalSquare?.text?.replacingOccurrences(of: ",", with: "") ?? ""
            dictParam[PARAMS.AREA] = cleanSqure
            dictParam[PARAMS.AGE]          = Int(self.txtEstateAge?.text ?? "") ?? 0
            dictParam[PARAMS.NORTH_FACING] = Int(self.txtNorth?.text ?? "") ?? 0
            dictParam[PARAMS.EAST_FACING]  = Int(self.txtEast?.text ?? "") ?? 0
            dictParam[PARAMS.WEST_FACING]  = Int(self.txtWest?.text ?? "") ?? 0
            dictParam[PARAMS.SOUTH_FACING] = Int(self.txtSouth?.text ?? "") ?? 0
            
            // MARK: - Int Values (always add, default 0)
            dictParam[PARAMS.FLOORS_NUMBER]     = self.floorNumber > 0 ? self.floorNumber : 0
            dictParam[PARAMS.TOTAL_FLOORS]      = self.AvailableFloors > 0 ? self.AvailableFloors : 0
            dictParam[PARAMS.TOTAL_BEDROOM]     = self.BedroomNumber > 0 ? self.BedroomNumber : 0
            dictParam[PARAMS.TOTAL_BATHROOM]    = self.BathroomNumber > 0 ? self.BathroomNumber : 0
            dictParam[PARAMS.TOTAL_LIVINGROOM]  = self.livingRoom > 0 ? self.livingRoom : 0
            dictParam[PARAMS.AVAILABLE_PARKING] = self.availableParking > 0 ? self.availableParking : 0
            Utility.addIfValid(&dictParam, key: PARAMS.DESCRIPTION, value: txtDescription?.text)
            
            // MARK: - Arrays (add only if not empty)
            if !self.arrSelectService.isEmpty {
                dictParam[PARAMS.SERVICES] = self.arrSelectService
            }
            if !self.arrSelectExtraFeatures.isEmpty {
                dictParam[PARAMS.EXTRA_FEATURES] = self.arrSelectExtraFeatures
            }
            
            if !self.arrSelectIntendedList.isEmpty {
                dictParam[PARAMS.useFor] = arrSelectIntendedList
            }
            
            
            // MARK: - Pass to next VC
            addLocationVC.dictParam = dictParam
            addLocationVC.isFromEdit = isFromEdit
            addLocationVC.objProperty = self.objProperty
            self.navigationController?.pushViewController(addLocationVC, animated: true)
        }
    }
}

// MARK: - UI helpers
extension AddListVC {
    func InitConfig() {
        self.txtDescription?.delegate = self
        
        self.vwProgress?.setRound(withBorderColor: .clear,andCornerRadious: 4.0,borderWidth: 0.0)
        self.lblTitle?.font = FontHelper.font(size: 20.0, type: FontType.Regular)
        self.lblAvailabilityList?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        self.lblRealType?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        self.lblDesc?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        self.lblNorthTitle?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        self.lblEastTitle?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        self.lblWestTitle?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        self.lblSouthTitle?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        self.txtSouth?.placeholder = "م"
        self.txtNorth?.placeholder = "م"
        self.txtEast?.placeholder = "م"
        self.txtWest?.placeholder = "م"
        
        self.lblSubTitle?.forEach {
            $0.textColor = .black
            $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        }
        self.vwTxtBG?.forEach({
            $0.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 8.0, borderWidth: 1.0)
        })
        
        let arrVw = [self.vwAgeBg, self.vwEastBg, self.vwWestBg, self.vwNorthBg, self.vwSouthBg]
        arrVw.forEach({
            $0?.setRound(withBorderColor: UIColor.themeBorderColor, andCornerRadious: 8.0, borderWidth: 1.0)
        })
        self.btnFloorNumberPlus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        self.btnFloorNumberMinus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        self.btnAvailabelFloorMinus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        self.btnAvailabelFloorPlus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        
        self.btnBedroomNumberMinus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        self.btnBedroomNumberPlus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        
        self.btnBathroomNumberMinus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        self.btnBathroomNumberPlus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        
        self.btnLivingRoomMinus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        self.btnLivingRoomPlus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        
        self.btnAvailableParkingMinus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        self.btnAvailableParkingPlus?.setupNewButton(borderColor: .clear,andCornerRadious: 10.0)
        
        self.btnNext?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        self.btnNext?.setupNewButton(borderColor: .clear,andCornerRadious: 8.0)
        
        if isFromEdit {
            self.vwAvailability.isHidden = false
            lblTitle?.text = "Update listing".localized
            let data = objProperty
            if let available = data?.availableFor,
               let index = arrSelectType.firstIndex(of: available) {
                self.selectSelectType = index
            }
            
            if let status = data?.status,
               let index = arrAvailabilityList.firstIndex(of: status) {
                self.indexPath = index
            }
            if let type = data?.type,
               let index = arrSecondAvailabilityList.firstIndex(of: type) {
                self.secondSelectedIndex = index
            }
            self.manageViews(indexPath: secondSelectedIndex ?? 0)
            self.txtPrice?.text = formatPriceNew("\(data?.price ?? 0)")
            self.txtTotalSquare?.text = formatPriceNew("\(data?.area ?? 0)")
            if data?.age != nil {
                self.switchAge?.isOn = false
                self.vwAgeBg.isHidden = false
                self.txtEstateAge?.text = "\(data?.age ?? 0)"
            } else {
                self.switchAge?.isOn = true
                self.vwAgeBg.isHidden = true
            }
            
            if data?.northFacing != nil {
                self.switchNorth?.isOn = true
                self.vwNorthBg.isHidden = false
                self.txtNorth?.text = "\(data?.northFacing ?? 0)"
            } else {
                self.switchNorth?.isOn = false
                self.vwNorthBg.isHidden = true
            }
            
            if data?.eastFacing != nil {
                self.switchEast?.isOn = true
                self.vwEastBg.isHidden = false
                self.txtEast?.text = "\(data?.eastFacing ?? 0)"
            } else {
                self.switchEast?.isOn = false
                self.vwEastBg.isHidden = true
            }
            
            if data?.westFacing != nil {
                self.switchWest?.isOn = true
                self.vwWestBg.isHidden = false
                self.txtWest?.text = "\(data?.westFacing ?? 0)"
            } else {
                self.switchWest?.isOn = false
                self.vwWestBg.isHidden = true
            }
            
            if data?.southFacing != nil {
                self.switchSouth?.isOn = true
                self.vwSouthBg.isHidden = false
                self.txtSouth?.text = "\(data?.southFacing ?? 0)"
            } else {
                self.switchSouth?.isOn = false
                self.vwSouthBg.isHidden = true
            }
            if let type = data?.vilaType {
                self.selectVillaIndexPath = arrVillaList.firstIndex(of: type) ?? 0
            }
            self.cvVilla?.reloadData()
            self.floorNumber = data?.floorNumber ?? 0
            self.AvailableFloors = data?.totalFloors ?? 0
            self.BedroomNumber = data?.totalBedrooms ?? 0
            self.BathroomNumber = data?.totalBathrooms ?? 0
            self.livingRoom = data?.totalLivingrooms ?? 0
            self.availableParking = data?.availableParking ?? 0
            self.txtDescription?.text = data?.description
            for obj in data?.services ?? [] {
                self.arrSelectService.append(obj)
            }
            self.cvService?.reloadData()
            
            for objExtra in data?.extraFeatures ?? [] {
                self.arrSelectExtraFeatures.append(objExtra)
            }
            self.cvExtraFeatures?.reloadData()
            
            for objIn in data?.useFor ?? [] {
                self.arrSelectIntendedList.append(objIn)
            }
            self.cvIntended?.reloadData()
        } else {
            self.vwAvailability.isHidden = true
            lblTitle?.text = "New listing".localized
        }
        
        self.setupCollectionView()
        self.setupLocalized()
        
        txtPrice?.keyboardType = .numberPad
        txtPrice?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        txtTotalSquare?.keyboardType = .numberPad
        txtTotalSquare?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let formatted = formatPriceNew(text)
        
        // Maintain cursor position
        let cursorOffset = textField.offset(from: textField.beginningOfDocument, to: textField.selectedTextRange?.start ?? textField.endOfDocument)
        
        textField.text = formatted
        
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorOffset + (formatted.count - text.count)) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    
    func setupLocalized() {
        //  self.lblTitle?.text = "New listing".localized
        self.lblDesc?.text = "Description:".localized
        self.lblAvailabilityList?.text = "Availability of the listing".localized
        self.lblRealType?.text = "Real estate type".localized
        self.lblPriceTitle?.text = "Price".localized
        self.lblTotalSquareTitle?.text = "Total square metres :".localized
        self.lblRealTitle?.text = "Real estate age".localized
        self.lblStreetTitle?.text = "Street width and facing".localized
        self.lblNorthTitle?.text = "North".localized
        self.lblWestTitle?.text = "West".localized
        self.lblEastTitle?.text = "East".localized
        self.lblSouthTitle?.text = "South".localized
        self.lblvillaTypeTitle?.text = "Villa type".localized
        self.lblIntendedUseTitle?.text = "intended use".localized
        self.lblFloorNumberTitle?.text = "Floor number".localized
        self.lblAvailabelFloorTitle?.text = "Available floors".localized
        self.lblBedRoomTitle?.text = "Bedroom number".localized
        self.lblBathroomTitle?.text = "Bathroom number".localized
        self.lblLivingTitle?.text = "Living room and sitting area number".localized
        self.lblAvailabelTitle?.text = "Available parking".localized
        self.lblServiceTitle?.text = "Services".localized
        self.lblExtraTitle?.text = "Extra features".localized
        self.lblNewTitle?.text = "New".localized
        self.btnNext?.setTitle("Next".localized, for: .normal)
    }
    
    
    func setupCollectionView() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.cvSelectType?.delegate = self
        self.cvSelectType?.dataSource = self
        self.cvSelectType?.showsHorizontalScrollIndicator = false
        self.cvSelectType?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvSelectType?.semanticContentAttribute = .forceRightToLeft
        
        self.cvAvailabilityList?.delegate = self
        self.cvAvailabilityList?.dataSource = self
        self.cvAvailabilityList?.showsHorizontalScrollIndicator = false
        self.cvAvailabilityList?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvAvailabilityList?.semanticContentAttribute = .forceRightToLeft
        
        self.cvVilla?.delegate = self
        self.cvVilla?.dataSource = self
        self.cvVilla?.showsHorizontalScrollIndicator = false
        self.cvVilla?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvVilla?.semanticContentAttribute = .forceRightToLeft
        
        self.cvIntended?.delegate = self
        self.cvIntended?.dataSource = self
        self.cvIntended?.showsHorizontalScrollIndicator = false
        self.cvIntended?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvIntended?.semanticContentAttribute = .forceRightToLeft
        
        self.cvService?.delegate = self
        self.cvService?.dataSource = self
        self.cvService?.showsHorizontalScrollIndicator = false
        self.cvService?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvService?.semanticContentAttribute = .forceRightToLeft
        
        
        if let layout = cvService?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
        
        self.cvSecondAvailabilityList?.delegate = self
        self.cvSecondAvailabilityList?.dataSource = self
        self.cvSecondAvailabilityList?.isScrollEnabled = false
        self.cvSecondAvailabilityList?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvSecondAvailabilityList?.semanticContentAttribute = .forceRightToLeft
        
        if let layout = cvSecondAvailabilityList?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
        
        self.cvExtraFeatures?.delegate = self
        self.cvExtraFeatures?.dataSource = self
        self.cvExtraFeatures?.isScrollEnabled = false
        self.cvExtraFeatures?.register(UINib(nibName: "ListTypeCVCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCVCell")
        self.cvExtraFeatures?.semanticContentAttribute = .forceRightToLeft
        
        if let layout = cvExtraFeatures?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
    }
    
    func checkValidation() -> Bool {
        if let selectedType = self.selectSelectType {
            if selectedType < 0 || !self.arrSelectType.indices.contains(selectedType) {
                Utility.showNewToast(message: "Please select Available Rent or Sale".localized)
                return false
            }
        } else {
            Utility.showNewToast(message: "Please select Available Rent or Sale".localized)
            return false
        }
        
        if let selectedTypeIndex = self.secondSelectedIndex {
            if selectedTypeIndex < 0 || !self.arrSecondAvailabilityList.indices.contains(selectedTypeIndex) {
                Utility.showNewToast(message: "Please select the type".localized)
                return false
            }
        } else {
            Utility.showNewToast(message: "Please select the type".localized)
            return false
        }
        
        if txtPrice?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            Utility.showNewToast(message: "Please enter Price".localized)
            return false
        }
        
        if txtTotalSquare?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            Utility.showNewToast(message: "Please enter Total Square Metres".localized)
            return false
        }
        
        return true
    }
}

//MARK: - IBAction Mthonthd
extension AddListVC {
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickFloorNumber(_ sender: UIButton) {
        if sender.tag == 0 {
            if floorNumber > 0 {
                floorNumber -= 1
            }
        } else {
            floorNumber += 1
        }
    }
}

// MARK: - Collectionview Delegate & Datasource
extension AddListVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvSelectType {
            return arrSelectType.count
        } else if collectionView == cvAvailabilityList {
            return arrAvailabilityList.count
        } else if collectionView == cvSecondAvailabilityList {
            return arrSecondAvailabilityList.count
        } else if collectionView == cvVilla {
            return arrVillaList.count
        } else if collectionView == cvIntended {
            return arrIntendedList.count
        } else if collectionView == cvService {
            return arrService.count
        } else if collectionView == cvExtraFeatures {
            return arrExtraFeatures.count
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListTypeCVCell", for: indexPath) as? ListTypeCVCell else {
            return UICollectionViewCell()
        }
        
        var isSelected: Bool = false
        var title: String = ""
        
        if collectionView == cvSelectType {
            title = arrSelectType[indexPath.item]
            isSelected = self.selectSelectType == indexPath.item
            
        } else if collectionView == cvAvailabilityList {
            title = arrAvailabilityList[indexPath.item]
            isSelected = self.indexPath == indexPath.item
            
        } else if collectionView == cvSecondAvailabilityList {
            title = arrSecondAvailabilityList[indexPath.item]
            isSelected = self.secondSelectedIndex == indexPath.item
            
        } else if collectionView == cvVilla {
            title = arrVillaList[indexPath.item]
            isSelected = self.selectVillaIndexPath == indexPath.item
        } else if collectionView == cvIntended {
            title = arrIntendedList[indexPath.item]
            isSelected = arrSelectIntendedList.contains(title)
        } else if collectionView == cvService {
            title = arrService[indexPath.item]
            isSelected = arrSelectService.contains(title)
        } else if collectionView == cvExtraFeatures {
            title = arrExtraFeatures[indexPath.item]
            isSelected = arrSelectExtraFeatures.contains(title)
        }
        cell.lblType?.textColor = isSelected ? .white : UIColor.themeBorderColor808080185
        cell.contentView.backgroundColor = isSelected ? UIColor.themePrimaryColor : .white
        cell.contentView.layer.borderColor = isSelected ? UIColor.clear.cgColor : UIColor.themeBorderColor808080185.cgColor
        cell.contentView.layer.borderWidth = isSelected ? 0.0 : 0.5
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.masksToBounds = true
        cell.configure(with: title.localized)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cvSelectType {
            self.selectSelectType = indexPath.item
            self.cvSelectType?.reloadData()
        } else if collectionView == cvAvailabilityList {
            self.indexPath = indexPath.item
            self.cvAvailabilityList?.reloadData()
        } else if collectionView == cvSecondAvailabilityList {
            self.secondSelectedIndex = indexPath.item
            self.manageViews(indexPath: indexPath.item)
            self.cvSecondAvailabilityList?.reloadData()
        } else if collectionView == cvVilla {
            self.selectVillaIndexPath = indexPath.item
            self.cvVilla?.reloadData()
        } else if collectionView == cvIntended {
            Utility.toggleSelection(item: self.arrIntendedList[indexPath.item], selectedArray: &arrSelectIntendedList)
            self.cvIntended?.reloadItems(at: [indexPath])
        } else if collectionView == cvService {
            Utility.toggleSelection(item: self.arrService[indexPath.item], selectedArray: &arrSelectService)
            self.cvService?.reloadItems(at: [indexPath])
        } else if collectionView == cvExtraFeatures {
            Utility.toggleSelection(item: self.arrExtraFeatures[indexPath.item], selectedArray: &arrSelectExtraFeatures)
            self.cvExtraFeatures?.reloadItems(at: [indexPath])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text: String
        if collectionView == cvSelectType  {
            text = arrSelectType[indexPath.item]
            let font = UIFont.systemFont(ofSize: 14)
            let width = text.size(withAttributes: [.font: font]).width + 32
            return CGSize(width: width, height: 36)
        } else if collectionView == cvAvailabilityList {
            text = arrAvailabilityList[indexPath.item]
            let font = UIFont.systemFont(ofSize: 14)
            let width = text.size(withAttributes: [.font: font]).width + 32
            return CGSize(width: width, height: 36)
        } else if collectionView == cvSecondAvailabilityList {
            text = arrSecondAvailabilityList[indexPath.item]
            let spacing: CGFloat = 10
            let totalSpacing = spacing * 3 // 4 items per row = 3 spaces
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemWidth = floor(availableWidth / 4) // 4 items in a row
            return CGSize(width: itemWidth, height: 40)
        } else if collectionView == cvVilla {
            text = arrVillaList[indexPath.item]
            let font = UIFont.systemFont(ofSize: 14)
            let width = text.size(withAttributes: [.font: font]).width + 32
            return CGSize(width: width, height: 36)
        } else if collectionView == cvService {
            text = arrService[indexPath.item]
            let spacing: CGFloat = 10
            let totalSpacing = spacing * 3 // 4 items per row = 3 spaces
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemWidth = floor(availableWidth / 3) // 4 items in a row
            return CGSize(width: itemWidth, height: 40)
        } else if collectionView == cvExtraFeatures {
            text = arrExtraFeatures[indexPath.item]
            let spacing: CGFloat = 10
            let totalSpacing = spacing * 3 // 4 items per row = 3 spaces
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemWidth = floor(availableWidth / 3) // 4 items in a row
            return CGSize(width: itemWidth, height: 40)
        } else {
            return CGSize(width: 63, height: 42)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == cvSelectType || collectionView == cvAvailabilityList || collectionView == cvVilla || collectionView == cvIntended || collectionView == cvService || collectionView == cvExtraFeatures {
            return 10
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == cvSelectType {
            var totalCellWidth: CGFloat = 0
            let font = UIFont.systemFont(ofSize: 14)
            
            for text in arrSelectType {
                totalCellWidth += text.size(withAttributes: [.font: font]).width + 32
            }
            
            let spacing: CGFloat = 10
            let totalSpacing = spacing * CGFloat(arrSelectType.count - 1)
            let totalWidth = totalCellWidth + totalSpacing
            
            let horizontalInset = max((collectionView.bounds.width - totalWidth) / 2, 0)
            return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        } else if collectionView == cvAvailabilityList {
            var totalCellWidth: CGFloat = 0
            let font = UIFont.systemFont(ofSize: 14)
            
            for text in arrAvailabilityList {
                totalCellWidth += text.size(withAttributes: [.font: font]).width + 32
            }
            
            let spacing: CGFloat = 10
            let totalSpacing = spacing * CGFloat(arrAvailabilityList.count - 1)
            let totalWidth = totalCellWidth + totalSpacing
            
            let horizontalInset = max((collectionView.bounds.width - totalWidth) / 2, 0)
            return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        } else if collectionView == cvSecondAvailabilityList || collectionView == cvService || collectionView == cvExtraFeatures {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else if collectionView == cvVilla {
            var totalCellWidth: CGFloat = 0
            let font = UIFont.systemFont(ofSize: 14)
            for text in arrVillaList {
                totalCellWidth += text.size(withAttributes: [.font: font]).width + 32
            }
            let spacing: CGFloat = 10
            let totalSpacing = spacing * CGFloat(arrVillaList.count - 1)
            let totalWidth = totalCellWidth + totalSpacing
            let horizontalInset = max((collectionView.bounds.width - totalWidth) / 2, 0)
            return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        } else {
            var totalCellWidth: CGFloat = 0
            let font = UIFont.systemFont(ofSize: 14)
            
            for text in arrIntendedList {
                totalCellWidth += text.size(withAttributes: [.font: font]).width + 32
            }
            let spacing: CGFloat = 10
            let totalSpacing = spacing * CGFloat(arrIntendedList.count - 1)
            let totalWidth = totalCellWidth + totalSpacing
            
            let horizontalInset = max((collectionView.bounds.width - totalWidth) / 2, 0)
            return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        }
    }
    
    func manageViews(indexPath: Int) {
        let indexPath = indexPath
        switch indexPath {
        case 2:
            //Apartment
            self.vwMainRealextateAge.isHidden = false
            self.vwMainStreetWidthFacing.isHidden = true
            self.vwMainVillatype.isHidden = true
            self.vwMainIntendedUse.isHidden = true
            self.vwMainFloorNumber.isHidden = false
            self.vwMainAvailableFloors.isHidden = false
            self.vwMainBedroomNumber.isHidden = false
            self.vwMainBathroomNumber.isHidden = false
            self.vwMainLivingroom.isHidden = false
            self.vwMainAvailableParking.isHidden = false
            self.vwMainServices.isHidden = false
            self.vwMainExtraFeatures.isHidden = false
        case 4:
            //Building Complex
            self.vwMainRealextateAge.isHidden = false
            self.vwMainStreetWidthFacing.isHidden = false
            self.vwMainVillatype.isHidden = true
            self.vwMainIntendedUse.isHidden = false
            self.vwMainFloorNumber.isHidden = true
            self.vwMainAvailableFloors.isHidden = false
            self.vwMainBedroomNumber.isHidden = true
            self.vwMainBathroomNumber.isHidden = true
            self.vwMainLivingroom.isHidden = true
            self.vwMainAvailableParking.isHidden = false
            self.vwMainServices.isHidden = false
            self.vwMainExtraFeatures.isHidden = false
        case 5:
            //Chalet
            self.vwMainRealextateAge.isHidden = false
            self.vwMainStreetWidthFacing.isHidden = false
            self.vwMainVillatype.isHidden = true
            self.vwMainIntendedUse.isHidden = true
            self.vwMainFloorNumber.isHidden = true
            self.vwMainAvailableFloors.isHidden = true
            self.vwMainBedroomNumber.isHidden = true
            self.vwMainBathroomNumber.isHidden = true
            self.vwMainLivingroom.isHidden = false
            self.vwMainAvailableParking.isHidden = true
            self.vwMainServices.isHidden = false
            self.vwMainExtraFeatures.isHidden = false
        case 6:
            //Farm
            self.vwMainRealextateAge.isHidden = false
            self.vwMainStreetWidthFacing.isHidden = false
            self.vwMainVillatype.isHidden = true
            self.vwMainIntendedUse.isHidden = false
            self.vwMainFloorNumber.isHidden = true
            self.vwMainAvailableFloors.isHidden = true
            self.vwMainBedroomNumber.isHidden = true
            self.vwMainBathroomNumber.isHidden = true
            self.vwMainLivingroom.isHidden = true
            self.vwMainAvailableParking.isHidden = true
            self.vwMainServices.isHidden = true
            self.vwMainExtraFeatures.isHidden = false
        case 3:
            //Floor
            self.vwMainRealextateAge.isHidden = false
            self.vwMainStreetWidthFacing.isHidden = false
            self.vwMainVillatype.isHidden = true
            self.vwMainIntendedUse.isHidden = true
            self.vwMainFloorNumber.isHidden = false
            self.vwMainAvailableFloors.isHidden = false
            self.vwMainBedroomNumber.isHidden = false
            self.vwMainBathroomNumber.isHidden = false
            self.vwMainLivingroom.isHidden = false
            self.vwMainAvailableParking.isHidden = false
            self.vwMainServices.isHidden = false
            self.vwMainExtraFeatures.isHidden = false
        case 0:
            //Land
            self.vwMainRealextateAge.isHidden = true
            self.vwMainStreetWidthFacing.isHidden = false
            self.vwMainVillatype.isHidden = true
            self.vwMainIntendedUse.isHidden = false
            self.vwMainFloorNumber.isHidden = true
            self.vwMainAvailableFloors.isHidden = true
            self.vwMainBedroomNumber.isHidden = true
            self.vwMainBathroomNumber.isHidden = true
            self.vwMainLivingroom.isHidden = true
            self.vwMainAvailableParking.isHidden = true
            self.vwMainServices.isHidden = true
            self.vwMainExtraFeatures.isHidden = true
        case 7:
            //Other
            self.vwMainRealextateAge.isHidden = true
            self.vwMainStreetWidthFacing.isHidden = true
            self.vwMainVillatype.isHidden = true
            self.vwMainIntendedUse.isHidden = true
            self.vwMainFloorNumber.isHidden = true
            self.vwMainAvailableFloors.isHidden = true
            self.vwMainBedroomNumber.isHidden = true
            self.vwMainBathroomNumber.isHidden = true
            self.vwMainLivingroom.isHidden = true
            self.vwMainAvailableParking.isHidden = true
            self.vwMainServices.isHidden = true
            self.vwMainExtraFeatures.isHidden = true
        default:
            //Villa
            self.vwMainRealextateAge.isHidden = false
            self.vwMainStreetWidthFacing.isHidden = false
            self.vwMainVillatype.isHidden = false
            self.vwMainIntendedUse.isHidden = false
            self.vwMainFloorNumber.isHidden = true
            self.vwMainAvailableFloors.isHidden = true
            self.vwMainBedroomNumber.isHidden = false
            self.vwMainBathroomNumber.isHidden = false
            self.vwMainLivingroom.isHidden = false
            self.vwMainAvailableParking.isHidden = false
            self.vwMainServices.isHidden = false
            self.vwMainExtraFeatures.isHidden = false
        }
    }
}

extension AddListVC : UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        let currentText = textView.text ?? ""
        
        // New text after replace
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // Limit = 1500 characters
        return updatedText.count <= 1500
    }
}
