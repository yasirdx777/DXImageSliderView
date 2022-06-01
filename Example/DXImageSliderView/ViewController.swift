//
//  ViewController.swift
//  DXImageSliderView
//
//  Created by Yasir Romaya on 06/01/2022.
//  Copyright (c) 2022 Yasir Romaya. All rights reserved.
//

import UIKit
import DXImageSliderView
import Kingfisher

class CustomCollectionViewCell: UICollectionViewCell {
    lazy var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    
    let imageSliderData = ["https://marmotamaps.com/de/fx/wallpaper/download/faszinationen/Marmotamaps_Wallpaper_AiguilleDuDru_Smartphone_1080x1920.jpg", "https://marmotamaps.com/de/fx/wallpaper/download/faszinationen/Marmotamaps_Wallpaper_Berchtesgaden_Smartphone_1080x1920.jpg", "https://marmotamaps.com/de/fx/wallpaper/download/faszinationen/Marmotamaps_Wallpaper_Hoefats_Smartphone_1080x1920.jpg"]
    
    let imageSliderViewRatioToTheScreen:CGFloat = 2

    lazy var imageSliderView: DXImageSliderView = {
        let imageSliderView = DXImageSliderView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width / imageSliderViewRatioToTheScreen))
        imageSliderView.scrollDirection = .horizontal
        imageSliderView.delegate = self
        imageSliderView.reloadItemsCount(imageSliderData.count)
        imageSliderView.itemZoomScale = 1
        imageSliderView.itemSpacing = 0
        imageSliderView.initialIndex = 1
        imageSliderView.timeInterval = 3
        imageSliderView.isAutomatic = true
        imageSliderView.isInfinite = true
        imageSliderView.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.width /  imageSliderViewRatioToTheScreen)
        imageSliderView.center = self.view.center
        return imageSliderView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(imageSliderView)
    }

}

extension ViewController: DXImageSliderViewProtocol {
    
    func imageSliderViewRegisterCellClasses() -> [String: AnyClass] {
        return ["CustomCollectionViewCell": CustomCollectionViewCell.self]
    }
    
    func imageSliderViewConfigureCell(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, realIndex: Int) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        let item = imageSliderData[realIndex]
        cell.imageView.kf.setImage(with: URL(string: item)!, options: [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage,
        ])
        return cell
    }
    
    func imageSliderViewConfigurePageControl(_ imageSliderView: DXImageSliderView, pageControl: DXPageControl) {
        pageControl.isHidden = false
        pageControl.currentPageIndicatorTintColor =  .orange
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.frame = CGRect(x: 0, y: imageSliderView.bounds.height-25, width: imageSliderView.bounds.width, height: 25)
    }
    
    func imageSliderViewDidSelectedIndex(_ imageSliderView: DXImageSliderView, index: Int){
        print("item selected")
    }
}

