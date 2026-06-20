//
//  ContentSizedTableView.swift
//  Nasif
//
//  Created by Denish Gediya on 08/07/25.
//

import Foundation
import UIKit

final class ContentSizedTableView: UITableView {
    
    var maxHeight: CGFloat? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        var tableViewHeight = contentSize.height
        if let maxHeight = maxHeight {
            tableViewHeight = min(contentSize.height, maxHeight)
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: tableViewHeight)
    }
}

