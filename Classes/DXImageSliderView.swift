//
//  DXImageSliderView.swift
//  DXImageSliderView
//
//  Created by Yasir Romaya on 2022/6/1.
//  Copyright © 2022 Yasir Romaya. All rights reserved.
//

import UIKit

@objc public protocol DXImageSliderViewProtocol: AnyObject {
    
    @objc func imageSliderViewRegisterCellClasses() -> [String: AnyClass]
    
    @objc func imageSliderViewConfigureCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, realIndex: Int) -> UICollectionViewCell
    
    @objc optional func imageSliderViewBeginDragingIndex(_ imageSliderView: DXImageSliderView, index: Int)
    
    @objc optional func imageSliderViewDidScrollToIndex(_ imageSliderView: DXImageSliderView, index: Int)
    
    @objc optional func imageSliderViewShouldSelectedIndex(_ imageSliderView: DXImageSliderView)
    
    @objc optional func imageSliderViewShouldDeselectedIndex(_ imageSliderView: DXImageSliderView)
    
    @objc optional func imageSliderViewDidSelectedIndex(_ imageSliderView: DXImageSliderView, index: Int)
    
    @objc optional func imageSliderViewConfigurePageControl(_ imageSliderView: DXImageSliderView, pageControl: DXPageControl)
}

public class DXImageSliderView: UIView, UIGestureRecognizerDelegate {
    
    public var initialIndex: Int?
    
    public var currentIndex: Int { return getCurrentIndex() }
    
    public var currentCell: UICollectionViewCell? {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        return collectionView.cellForItem(at: indexPath)
    }
    
    
    public var timeInterval: Int = 3
    
    public var isAutomatic: Bool = true
    
    public var isInfinite: Bool = true {
        didSet { setItemsCount() }
    }

    
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet { flowLayout.scrollDirection = scrollDirection }
    }

    
    public var placeholderImage: UIImage? {
        didSet { placeholder.image = placeholderImage }
    }

    
    public var itemSize: CGSize? {
        didSet {
            guard let itemSize = itemSize else { return }
            let width = min(bounds.size.width, itemSize.width)
            let height = min(bounds.size.height, itemSize.height)
            flowLayout.itemSize = CGSize(width: width, height: height)
        }
    }

    
    public var itemZoomScale: CGFloat = 1 {
        didSet {
            collectionView.isPagingEnabled = itemZoomScale == 1
            flowLayout.scale = itemZoomScale
        }
    }

    
    public var itemSpacing: CGFloat = 0 {
        didSet { flowLayout.minimumLineSpacing = itemSpacing }
    }
    
    
    public weak var delegate: DXImageSliderViewProtocol? {
        didSet {
            guard let delegate = delegate else { return }
            let cellClasses = delegate.imageSliderViewRegisterCellClasses()
            if cellClasses.count > 0 {
                cellClasses.forEach {
                    let cellClass = $0.value as! UICollectionViewCell.Type
                    collectionView.register(cellClass.self, forCellWithReuseIdentifier: $0.key)
                }
            } else {
                fatalError("cell issue")
            }
        }
    }
    
    
    public func reloadItemsCount(_ count: Int) {
        cancelTimer()
        if isAutomatic { startTimer() }
        realItemsCount = count
        placeholder.isHidden = realItemsCount != 0
        setItemsCount()
        dealFirstPage()
        pageControl.numberOfPages = realItemsCount
        pageControl.currentPage = getCurrentIndex() % realItemsCount
    }
    
    
    public func scrollToNext() {
        timeRepeat()
    }
    
    func setItemsCount() {
        itemsCount = realItemsCount <= 1 || !isInfinite ? realItemsCount : realItemsCount * 200
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: true)
    }

    private lazy var flowLayout: DXImageSliderLayout = {
        let layout = DXImageSliderLayout()
        layout.minimumInteritemSpacing = 10000
        layout.minimumLineSpacing = itemSpacing
        layout.scrollDirection = scrollDirection
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.0)
        return collectionView
    }()
    
    private lazy var pageControl: DXPageControl = {
        let pageControl = DXPageControl()
        pageControl.isHidden = true
        return pageControl
    }()
    
    private lazy var placeholder = UIImageView()
    
    private var timer: Timer?
    private var itemsCount: Int = 0
    private var realItemsCount: Int = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupPlaceholder()
        setupCollectionView()
        setupPageControl()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlaceholder()
        setupCollectionView()
        setupPageControl()
    }
    
    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            startTimer()
        } else {
            cancelTimer()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        delegate?.imageSliderViewConfigurePageControl?(self, pageControl: pageControl)
        if flowLayout.itemSize != .zero { return }
        flowLayout.itemSize = itemSize != nil ? itemSize! : bounds.size
        dealFirstPage()
    }
}

// MARK: - UI

extension DXImageSliderView {
    private func setupPlaceholder() {
        addSubview(placeholder)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        let hCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|[placeholder]|",
                                                   options: NSLayoutConstraint.FormatOptions(),
                                                   metrics: nil,
                                                   views: ["placeholder": placeholder])
        let vCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|[placeholder]|",
                                                   options: NSLayoutConstraint.FormatOptions(),
                                                   metrics: nil,
                                                   views: ["placeholder": placeholder])
        addConstraints(hCons)
        addConstraints(vCons)
    }
    
    private func setupLongGestureRecognizerOnCollection() {
        
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let hCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|",
                                                   options: NSLayoutConstraint.FormatOptions(),
                                                   metrics: nil,
                                                   views: ["collectionView": collectionView])
        let vCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|",
                                                   options: NSLayoutConstraint.FormatOptions(),
                                                   metrics: nil,
                                                   views: ["collectionView": collectionView])
        addConstraints(hCons)
        addConstraints(vCons)
        
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPressedGesture)
    }
    
    private func setupPageControl() {
        pageControl = DXPageControl()
        addSubview(pageControl)
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate

extension DXImageSliderView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item % realItemsCount
        return delegate?.imageSliderViewConfigureCell(collectionView: collectionView, cellForItemAt: indexPath, realIndex: index) ?? UICollectionViewCell()
    }
    
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state != .ended {
            if isAutomatic { cancelTimer() }
            dealLastPage()
            dealFirstPage()
            guard let delegate = delegate else { return }
            let index = getCurrentIndex() % realItemsCount
            delegate.imageSliderViewBeginDragingIndex?(self, index: index)
            
            delegate.imageSliderViewShouldSelectedIndex?(self)
        }else {
            if isAutomatic { startTimer() }
            guard let delegate = delegate else { return }
            delegate.imageSliderViewShouldDeselectedIndex?(self)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let centerViewPoint = convert(collectionView.center, to: collectionView)
        guard let centerIndex = collectionView.indexPathForItem(at: centerViewPoint) else { return }
        if indexPath.item == centerIndex.item {
            let index = indexPath.item % realItemsCount
            delegate?.imageSliderViewDidSelectedIndex?(self, index: index)
        } else {
            let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
            collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension DXImageSliderView {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutomatic { cancelTimer() }
        dealLastPage()
        dealFirstPage()
        guard let delegate = delegate else { return }
        let index = getCurrentIndex() % realItemsCount
        delegate.imageSliderViewBeginDragingIndex?(self, index: index)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutomatic { startTimer() }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let delegate = delegate else { return }
        let index = getCurrentIndex() % realItemsCount
        pageControl.currentPage = index
        delegate.imageSliderViewDidScrollToIndex?(self, index: index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = getCurrentIndex() % realItemsCount
    }
}


extension DXImageSliderView {
    private func dealFirstPage() {
        if collectionView.frame.size == .zero { return }
        if getCurrentIndex() == 0, itemsCount > 1 {
            var targetIndex = isInfinite ? itemsCount / 2 : 0
            if let initialIndex = initialIndex {
                targetIndex += max(min(initialIndex, realItemsCount - 1), 0)
                self.initialIndex = nil
            }
            if let attributes = collectionView.layoutAttributesForItem(at: IndexPath(item: targetIndex, section: 0)) {
                if scrollDirection == .horizontal {
                    let edgeLeft = (collectionView.bounds.width - flowLayout.itemSize.width) / 2
                    collectionView.setContentOffset(CGPoint(x: attributes.frame.minX - edgeLeft, y: 0), animated: false)
                } else {
                    let edgeTop = (collectionView.bounds.height - flowLayout.itemSize.height) / 2
                    collectionView.setContentOffset(CGPoint(x: 0, y: attributes.frame.minY - edgeTop), animated: false)
                }
            }
        }
    }

    private func dealLastPage() {
        if getCurrentIndex() == itemsCount - 1, itemsCount > 1 {
            let targetIndex = isInfinite ? itemsCount / 2 - 1 : realItemsCount - 1
            let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
            collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: false)
        }
    }
}

extension DXImageSliderView {
    private func startTimer() {
        if !isAutomatic { return }
        if itemsCount <= 1 { return }
        cancelTimer()
        timer = Timer(timeInterval: Double(timeInterval), target: self, selector: #selector(timeRepeat), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timeRepeat() {
        let currentIndex = getCurrentIndex()
        var targetIndex = currentIndex + 1
        if currentIndex == itemsCount - 1 {
            if isInfinite == false {
                return
            }
            dealLastPage()
            targetIndex = itemsCount / 2
        }
        let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: true)
    }
    
    private func getCurrentIndex() -> Int {
        let itemWH = scrollDirection == .horizontal ? flowLayout.itemSize.width + itemSpacing : flowLayout.itemSize.height + itemSpacing
        let offsetXY = scrollDirection == .horizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        if itemWH == 0 { return 0 }
        let index = round(offsetXY / itemWH)
        return Int(index)
    }
}
