//
//  CopyableLabel.swift
//  Nasif
//
//  Created by Denish Gediya on 08/11/25.
//

import UIKit

class CopyableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestures()
    }
    
    private func setupGestures() {
        isUserInteractionEnabled = true
        
        // Long press to copy
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showCopyMenu))
        addGestureRecognizer(longPress)
        
        // Tap to open link
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Copy Support
    @objc private func showCopyMenu() {
        becomeFirstResponder()
        UIMenuController.shared.showMenu(from: self, rect: bounds)
    }
    
    override var canBecomeFirstResponder: Bool { true }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
    
    // MARK: - Link Tap Support
    @objc private func handleTap() {
        guard let text = self.text else { return }
        
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        
        if let match = matches?.first, let url = match.url {
            UIApplication.shared.open(url)
        }
    }
}

protocol LinkHandlerDelegate: AnyObject {
    func handleJoinGroup(groupId: String)
}


extension UILabel {
    
    weak var linkDelegate: LinkHandlerDelegate? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.delegate) as? LinkHandlerDelegate }
        set { objc_setAssociatedObject(self, &AssociatedKeys.delegate, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    private struct AssociatedKeys {
        static var delegate = "LinkHandlerDelegate"
    }
    
    func enableClickableLinks() {
        guard let text = self.text else { return }
        
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, range: NSRange(location: 0, length: text.utf16.count)) ?? []
        
        let attributed = NSMutableAttributedString(string: text)
        
        for match in matches {
            attributed.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: match.range)
            attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
        }
        
        self.attributedText = attributed
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:)))
        self.addGestureRecognizer(tap)
    }
    
    
    @objc private func handleTapOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.attributedText?.string else { return }
        
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, range: NSRange(location: 0, length: text.utf16.count)) ?? []
        
        let tapLocation = gesture.location(in: self)
        
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: self.bounds.size)
        
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let index = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        for result in matches {
            if NSLocationInRange(index, result.range), let url = result.url {
                
                let urlString = url.absoluteString
                
                // Detect join group URL
                if urlString.contains("nasif.com.sa") || urlString.contains("nasif.com.sa") {
                    if let groupId = URLComponents(string: urlString)?
                        .queryItems?
                        .first(where: { $0.name == "groupId" })?
                        .value {
                        
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        linkDelegate?.handleJoinGroup(groupId: groupId)
                        return
                    }
                }
                
                UIApplication.shared.open(url)
                return
            }
        }
    }
}

