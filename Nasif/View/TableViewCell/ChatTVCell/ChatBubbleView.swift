//
//  ChatBubbleView.swift
//  Nasif
//
//  Created by Denish Gediya on 11/10/25.
//

import UIKit

class ChatBubbleView: UIView {
    
    var isFromCurrentUser: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    var bubbleColor: UIColor = UIColor(red: 210/255, green: 238/255, blue: 250/255, alpha: 1) {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        
        let cornerRadius: CGFloat = 10
        let tailWidth: CGFloat = 8
        let tailHeight: CGFloat = 10
        
        let bubbleRect: CGRect
        if isFromCurrentUser {
            bubbleRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width - tailWidth, height: rect.height)
        } else {
            bubbleRect = CGRect(x: rect.minX + tailWidth, y: rect.minY, width: rect.width - tailWidth, height: rect.height)
        }
        
        let path = UIBezierPath(roundedRect: bubbleRect, cornerRadius: cornerRadius)
        
        let tailPath = UIBezierPath()
        
        // bottom thi 10 px upar
        let tailBaseY = bubbleRect.maxY - (tailHeight + 10)
        
        if isFromCurrentUser {
            tailPath.move(to: CGPoint(x: bubbleRect.maxX, y: tailBaseY))
            tailPath.addLine(to: CGPoint(x: bubbleRect.maxX + tailWidth, y: tailBaseY + tailHeight/2))
            tailPath.addLine(to: CGPoint(x: bubbleRect.maxX, y: tailBaseY + tailHeight))
        } else {
            tailPath.move(to: CGPoint(x: bubbleRect.minX, y: tailBaseY))
            tailPath.addLine(to: CGPoint(x: bubbleRect.minX - tailWidth, y: tailBaseY + tailHeight/2))
            tailPath.addLine(to: CGPoint(x: bubbleRect.minX, y: tailBaseY + tailHeight))
        }
        
        tailPath.close()
        path.append(tailPath)
        
        bubbleColor.setFill()
        path.fill()
    }

}
