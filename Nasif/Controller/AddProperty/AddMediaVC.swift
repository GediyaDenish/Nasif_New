//
//  AddMediaVC.swift
//  Nasif
//
//  Created by Denish Gediya on 08/07/25.
//

import UIKit

class AddMediaVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet var lblSubTitle: [UILabel]?
    @IBOutlet weak var vwAddImage: UIView?
    @IBOutlet weak var lblAddThumbnail: UILabel?
    @IBOutlet weak var lblAddSubThumbnail: UILabel?
    @IBOutlet weak var tblImage: ContentSizedTableView?
    @IBOutlet weak var tblHeight: NSLayoutConstraint?
    @IBOutlet weak var btnNext: UIButton?
    @IBOutlet weak var imgMain: UIImageView?
    @IBOutlet weak var vwThumbMain: UIView?
    @IBOutlet weak var vwImageMain: UIView?
    
    @IBOutlet weak var lblThumbnailImageTitle: UILabel!
    @IBOutlet weak var lblOtherPicture: UILabel!
    
    
    // MARK: - Constants
    private enum Constants {
        static let rowHeight: CGFloat = 65
        static let selectedRowHeight: CGFloat = 80
    }
    
    // MARK: - Properties
    var dictParam: [String: Any] = [:]
    var isFromEdit = false
    var objProperty: Property?
    
    private let imagePicker = ImagePicker()
    private var arrSelectedImages: [UIImage] = []
    private var arrExtraImages: [String] = []
    private var arrSelected: [String] = []
    private var thumbImage: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        configureDataIfEditing()
    }
}

// MARK: - Actions
extension AddMediaVC {
    
    @IBAction private func btnOnClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func btnOnClickAdd(_ sender: UIButton) {
        imagePicker.pickImage(self, "", type: .multiple, allowVideo: false, multiHandler: { images in
            for img in images {
                self.handleNewImage(img)
            }
        })
    }
    
    @IBAction private func btnOnClickAddImage(_ sender: UIButton) {
        imagePicker.pickImage(self, "", type: .single, allowVideo: false) { image, url in
            self.handleThumbnailImage(image)
        }
    }
    
    @IBAction private func btnOnClickNext(_ sender: UIButton) {
        navigateToOwnerContact()
    }
}

// MARK: - Setup
private extension AddMediaVC {
    
    func setupUI() {
        lblTitle?.font = FontHelper.font(size: 20, type: .Regular)
        
        [btnNext, btnAdd].forEach {
            $0?.titleLabel?.font = FontHelper.font(size: 16, type: .Regular)
            $0?.setupNewButton(borderColor: .clear, andCornerRadious: 8)
        }
        
        vwThumbMain?.setRound(withBorderColor: .themeBorderColor,
                              andCornerRadious: 8,
                              borderWidth: 1)
        
        lblAddThumbnail?.font = FontHelper.font(size: 14, type: .Regular)
        lblAddSubThumbnail?.applyStyle(size: 12, color: .themeSelect)
        
        lblSubTitle?.forEach {
            $0.textColor = .black
            $0.font = FontHelper.font(size: 16, type: .Regular)
        }
        
        // imagePicker.viewController = self
        
        setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle?.text = "Media".localized
        self.lblThumbnailImageTitle?.text = "Thumbnail image".localized
        self.lblAddThumbnail?.text = "ADD thumbnail image".localized
        self.lblAddSubThumbnail?.text = "chose only one image here".localized
        self.lblOtherPicture?.text = "other pictures".localized
        self.btnNext?.setTitle("Next".localized, for: .normal)
        self.btnAdd?.setTitle("Add".localized, for: .normal)
    }
    
    func setupTableView() {
        tblImage?.delegate = self
        tblImage?.dataSource = self
        tblImage?.separatorStyle = .none
        tblImage?.register(UINib(nibName: "AddImageTVCell", bundle: nil),
                           forCellReuseIdentifier: "AddImageTVCell")
    }
    
    func configureDataIfEditing() {
        guard isFromEdit, let property = objProperty else { return }
        
        arrExtraImages = property.images ?? []
        
        if let cover = property.coverImage, !cover.isEmpty {
            vwAddImage?.isHidden = true
            vwImageMain?.isHidden = false
            if let url = URL(string: cover){
                self.imgMain?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_new_placeholder"))
            }
            Utility.addIfValid(&dictParam, key: PARAMS.COVER_IMAGE, value: cover)
        } else {
            vwAddImage?.isHidden = false
            vwImageMain?.isHidden = true
        }
        
        DispatchQueue.main.async {
            self.reloadTable()
        }
        
    }
}

// MARK: - Handlers
private extension AddMediaVC {
    
    func handleNewImage(_ img: UIImage) {
        arrSelectedImages.append(img)
        arrSelected.append(convertImageToBase64String(img: img))
        reloadTable()
    }
    
    func handleThumbnailImage(_ img: UIImage) {
        vwAddImage?.isHidden = true
        vwImageMain?.isHidden = false
        imgMain?.image = img
        thumbImage = img
        Utility.addIfValid(&dictParam, key: PARAMS.COVER_IMAGE, value: convertImageToBase64String(img: img))
    }
    
    func navigateToOwnerContact() {
        let storyboard = UIStoryboard(name: "AddList", bundle: nil)
        guard let ownerContactVC = storyboard.instantiateViewController(withIdentifier: "OwnerContactVC") as? OwnerContactVC else { return }
        
        Utility.addIfValid(&dictParam, key: PARAMS.IMAGES, value: arrSelected)
        ownerContactVC.dictParam = dictParam
        ownerContactVC.isFromEdit = isFromEdit
        ownerContactVC.objProperty = objProperty
        navigationController?.pushViewController(ownerContactVC, animated: true)
    }
    
    func reloadTable() {
        let totalCount = arrExtraImages.count + arrSelectedImages.count
        tblHeight?.constant = CGFloat(totalCount) * Constants.rowHeight
        tblImage?.reloadData()
    }
}

// MARK: - UITableView
extension AddMediaVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrExtraImages.count + arrSelectedImages.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddImageTVCell", for: indexPath) as? AddImageTVCell else {
            return UITableViewCell()
        }
        
        if indexPath.row < arrExtraImages.count {
            let image = arrExtraImages[indexPath.row]
            if let url = URL(string: image){
                cell.imgProperty?.sd_setImage(with: url, placeholderImage: UIImage(named: "icn_new_placeholder"))
            }
        } else {
            let image = arrSelectedImages[indexPath.row - arrExtraImages.count]
            cell.imgProperty?.image = image
        }
        
        cell.btnDelete?.tag = indexPath.row
        cell.btnDelete?.addTarget(self, action: #selector(removeImage(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc private func removeImage(_ sender: UIButton) {
        let index = sender.tag
        if index < arrExtraImages.count {
            confirmDelete { [weak self] confirmed in
                guard let self = self else { return }
                if confirmed { self.wsDeleteImage(imageURL: self.arrExtraImages[index]) }
            }
        } else {
            let localIndex = index - arrExtraImages.count
            confirmDelete { [weak self] confirmed in
                guard let self = self else { return }
                if confirmed {
                    Utility.showNewToast(message: "Delete Image Successfully".localized)
                    self.arrSelectedImages.remove(at: localIndex)
                    self.arrSelected.remove(at: localIndex)
                    self.reloadTable()
                }
            }
        }
    }
    
    private func confirmDelete(completion: @escaping (Bool) -> Void) {
        showDeleteConfirmation(from: self, message: "Are you sure you want to delete this image?".localized, title: "Delete".localized, completion: completion)
    }
}

// MARK: - Web Services
extension AddMediaVC {
    
    func wsDeleteImage(imageURL: String) {
        Utility.showLoading()
        guard let propertyId = objProperty?.id else {
            Utility.hideLoading()
            Utility.showNewToast(message: "Property ID not found".localized)
            return
        }
        
        let url = "\(WebService.PROPERTY)\(propertyId)/image/?url=\(imageURL)"
        
        WebServices.Delete(url: url, type: Property.self) { [weak self] response in
            Utility.hideLoading()
            guard let self = self else { return }
            guard response != nil else { return }
            Utility.showNewToast(message: "Delete Image Successfully".localized)
            self.arrExtraImages.removeAll { $0 == imageURL }
            self.reloadTable()
        }
    }
}
