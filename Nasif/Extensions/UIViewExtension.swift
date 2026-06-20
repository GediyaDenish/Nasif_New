//
//  UIViewExtension.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit

// MARK: - UIVIEW Extension
extension UIView {
    
    func setShadow(
        shadowColor: CGColor = UIColor.themeShadowColor.cgColor,
        shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0),
        shadowOpacity: Float = 0.7,
        shadowRadius: CGFloat = 5.0
    ) {
        
        self.layer.shadowColor = shadowColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
    }
    
    func setupButton(borderColor: UIColor = UIColor.clear, andCornerRadious: CGFloat = 0.0, backgroundColor: UIColor = UIColor.black) {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = andCornerRadious
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.backgroundColor = backgroundColor
    }
    
    func setupNewButton(borderColor: UIColor = UIColor.clear, andCornerRadious: CGFloat = 0.0, backgroundColor: UIColor = UIColor.themePrimaryColor) {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = andCornerRadious
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.backgroundColor = backgroundColor
    }
    
    func  setRound(withBorderColor: UIColor = UIColor.clear, andCornerRadious: CGFloat = 0.0, borderWidth: CGFloat = 1.0) {
        if andCornerRadious == 0.0 {
            var frame: CGRect = self.frame
            frame.size.height = min(self.frame.size.width, self.frame.size.height)
            frame.size.width = frame.size.height
            self.frame = frame
            self.layer.cornerRadius = self.layer.frame.size.width / 2
        } else {
            self.layer.cornerRadius = andCornerRadious
        }
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
        self.layer.borderColor = withBorderColor.cgColor
        
    }
    
    func applyShadow(
        color: UIColor = UIColor.black.withAlphaComponent(0.1),
        radius: CGFloat = 5,
        offset: CGSize = .zero,
        opacity: Float = 0.5
    ) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
    
    /// Apply WhatsApp-style bubble (Right side)
        func applyRightBubbleShape(
            color: UIColor = UIColor(red: 225/255, green: 245/255, blue: 254/255, alpha: 1)
        ) {
            self.backgroundColor = .clear
            self.layer.sublayers?.removeAll(where: { $0.name == "bubbleLayer" })
            
            let bubbleLayer = CAShapeLayer()
            bubbleLayer.name = "bubbleLayer"
            bubbleLayer.path = createRightBubblePath(in: self.bounds).cgPath
            bubbleLayer.fillColor = color.cgColor
            self.layer.insertSublayer(bubbleLayer, at: 0)
        }
        
        /// Apply WhatsApp-style bubble (Left side)
        func applyLeftBubbleShape(
            color: UIColor = UIColor.white
        ) {
            self.backgroundColor = .clear
            self.layer.sublayers?.removeAll(where: { $0.name == "bubbleLayer" })
            
            let bubbleLayer = CAShapeLayer()
            bubbleLayer.name = "bubbleLayer"
            bubbleLayer.path = createLeftBubblePath(in: self.bounds).cgPath
            bubbleLayer.fillColor = color.cgColor
            self.layer.insertSublayer(bubbleLayer, at: 0)
        }
        
        // MARK: - Right Bubble Path (Outgoing)
        private func createRightBubblePath(in rect: CGRect) -> UIBezierPath {
            let radius: CGFloat = 16
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                              controlPoint: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
                              controlPoint: CGPoint(x: rect.maxX, y: rect.maxY))
            
            // Tail
            path.addLine(to: CGPoint(x: rect.minX + 25, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX + 15, y: rect.maxY + 8),
                              controlPoint: CGPoint(x: rect.minX + 20, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX + 5, y: rect.maxY - 5),
                              controlPoint: CGPoint(x: rect.minX + 8, y: rect.maxY + 6))
            
            path.addLine(to: CGPoint(x: rect.minX + 5, y: rect.minY + radius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY),
                              controlPoint: CGPoint(x: rect.minX, y: rect.minY))
            path.close()
            
            return path
        }
        
        // MARK: - Left Bubble Path (Incoming)
        private func createLeftBubblePath(in rect: CGRect) -> UIBezierPath {
            let radius: CGFloat = 16
            let path = UIBezierPath()
            
            path.move(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY + radius),
                              controlPoint: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.maxY),
                              controlPoint: CGPoint(x: rect.minX, y: rect.maxY))
            
            // Tail
            path.addLine(to: CGPoint(x: rect.maxX - 25, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 15, y: rect.maxY + 8),
                              controlPoint: CGPoint(x: rect.maxX - 20, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 5, y: rect.maxY - 5),
                              controlPoint: CGPoint(x: rect.maxX - 8, y: rect.maxY + 6))
            
            path.addLine(to: CGPoint(x: rect.maxX - 5, y: rect.minY + radius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.minY),
                              controlPoint: CGPoint(x: rect.maxX, y: rect.minY))
            path.close()
            
            return path
        }
}
