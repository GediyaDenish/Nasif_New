//
//  ImagePreviewVC.swift
//  Nasif
//
//  Created by Denish Gediya on 07/07/25.
//

import UIKit
import SDWebImage
import SDWebImageMapKit

class ImagePreviewVC: UIViewController {
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var cvImages: UICollectionView!
    @IBOutlet weak var pagerImages: UIPageControl!
    
    @IBOutlet weak var vwMain: UIView?
    @IBOutlet weak var imgMain: UIImageView?
    
    
    var arrImages: [String] = []
    var isFromHide: Bool = false
    var strImage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromHide == true {
            vwMain?.isHidden = true
            imgMain?.isHidden = false
            if let url = URL(string: self.strImage){
                imgMain?.sd_setImage(with: url, placeholderImage: UIImage(named: "Image"))
            }
        } else {
            vwMain?.isHidden = false
            imgMain?.isHidden = true
        }
        self.btnShare?.setupButton(borderColor: .clear,andCornerRadious: (self.btnShare?.frame.height ?? 0)/2)
        
        
        // Initialize the page control
        pagerImages.numberOfPages = arrImages.count
        pagerImages.currentPage = 0
        
        setupCollectionViewLayout()
        
        self.cvImages?.delegate = self
        self.cvImages?.dataSource = self
        self.cvImages?.showsHorizontalScrollIndicator = false
        self.cvImages?.register(UINib(nibName: "ImagesCVCell", bundle: nil), forCellWithReuseIdentifier: "ImagesCVCell")
        
        // Enable paging for the collection view
        self.cvImages?.isPagingEnabled = true
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickShare(_ sender: UIButton) {
        if isFromHide == true {
            guard let shareImage = self.imgMain?.image else {
                print("No Image Found")
                return
            }
            
            let text = "Sharing this image..."
            let items: [Any] = [text, shareImage]
            
            let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            avc.popoverPresentationController?.sourceView = sender
            
            self.present(avc, animated: true)
            
        } else {
            let currentIndex = pagerImages.currentPage
            
            guard arrImages.indices.contains(currentIndex),
                  let url = URL(string: arrImages[currentIndex]) else {
                print("Invalid image URL")
                return
            }
            
            // Load image from cache or download
            SDWebImageManager.shared.loadImage(
                with: url,
                options: .highPriority,
                progress: nil
            ) { (image, _, error, _, _, _) in
                
                if let error = error {
                    print("Image load error:", error.localizedDescription)
                    return
                }
                
                guard let finalImage = image else {
                    print("Image not found")
                    return
                }
                
                let text = "Sharing Image..."
                let items: [Any] = [text, finalImage]
                
                let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
                avc.popoverPresentationController?.sourceView = sender
                
                self.present(avc, animated: true)
            }
        }
        
    }
    
    // MARK: - Configure UICollectionView Layout for Pager Effect
    func setupCollectionViewLayout() {
        if let layout = cvImages.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0 // No space between cells
            layout.minimumInteritemSpacing = 0 // No space between items
            layout.itemSize = CGSize(width: self.cvImages.frame.width, height: self.cvImages.frame.height) // One image per screen
            layout.sectionInset = .zero // Remove any insets that could cause spacing
            
            // Ensure content inset is zero to prevent any edge cutting
            self.cvImages.contentInset = .zero
        }
    }
    
}

// MARK: - Collectionview Delegate & Datasource
extension ImagePreviewVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCVCell", for: indexPath) as? ImagesCVCell else {
            return UICollectionViewCell()
        }
        if let url = URL(string: arrImages[indexPath.item]){
            cell.imgImages?.sd_setImage(with: url, placeholderImage: UIImage(named: "Image"))
        }
        return cell
    }
    
    // Synchronize the Page Control with Collection View's scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pagerImages.currentPage = page // Update the page control
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Method
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size of each item to fill the entire screen width and height
        return CGSize(width: self.cvImages.frame.width, height: self.cvImages.frame.height)
    }
    
}
