//
//  DXPageControl.swift
//  DXPageControl
//
//  Created by Yasir Romaya on 2022/6/1.
//  Copyright © 2022 Yasir Romaya. All rights reserved.
//

import UIKit

public enum DXPageControlAlignment {
    case center
    case left
    case right
}

public class DXPageControl: UIControl {
    public var numberOfPages: Int = 0 {
        didSet {
            items.forEach { $0.removeFromSuperview() }
            items.removeAll()
            for _ in 0 ..< numberOfPages {
                let item = UIImageView()
                addSubview(item)
                items.append(item)
            }
        }
    }

    
    public var spacing: CGFloat = 8
    
    public var dotSize = CGSize(width: 8, height: 8)
    
    public var currentDotSize: CGSize?
    
    public var alignment: DXPageControlAlignment = .center
    
    public var dotRadius: CGFloat?
    
    public var currentDotRadius: CGFloat?
    
    public var currentPage: Int = 0 { didSet { setNeedsLayout() } }
    
    public var currentPageIndicatorTintColor = UIColor.white
    
    public var pageIndicatorTintColor = UIColor.gray

    private var items = [UIImageView]()

    override public func layoutSubviews() {
        super.layoutSubviews()
        for (index, item) in items.enumerated() {
            let itemFrame = getFrame(index: index)
            item.frame = itemFrame
            if index == currentPage {
                item.backgroundColor = currentPageIndicatorTintColor
                let cornerRadius = currentDotRadius == nil ? itemFrame.size.height/2 : currentDotRadius!
                item.layer.cornerRadius = cornerRadius
            } else {
                item.backgroundColor = pageIndicatorTintColor
                let cornerRadius = dotRadius == nil ? itemFrame.size.height/2 : dotRadius!
                item.layer.cornerRadius = cornerRadius
            }
        }
    }

    private func getFrame(index: Int) -> CGRect {
        let itemW = dotSize.width + spacing
        let currentSize = currentDotSize == nil ? dotSize : currentDotSize!
        let currentItemW = currentSize.width + spacing
        let totalWidth = itemW*CGFloat(numberOfPages-1) + currentItemW + spacing
        var orignX: CGFloat = 0
        switch alignment {
        case .center:
            orignX = (frame.size.width-totalWidth)/2 + spacing
        case .left:
            orignX = spacing
        case .right:
            orignX = frame.size.width-totalWidth + spacing
        }
        var x: CGFloat = 0
        if index <= currentPage {
            x = orignX + CGFloat(index)*itemW
        } else {
            x = orignX + CGFloat(index-1)*itemW + currentItemW
        }
        let width = index == currentPage ? currentSize.width : dotSize.width
        let height = index == currentPage ? currentSize.height : dotSize.height
        let y = (frame.size.height-height)/2
        return CGRect(x: x, y: y, width: width, height: height)
    }

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self { return nil }
        return hitView
    }
}
