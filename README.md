# DXImageSliderView

[![Version](https://img.shields.io/cocoapods/v/DXImageSliderView.svg?style=flat)](https://cocoapods.org/pods/DXImageSliderView)
[![License](https://img.shields.io/cocoapods/l/DXImageSliderView.svg?style=flat)](https://cocoapods.org/pods/DXImageSliderView)
[![Platform](https://img.shields.io/cocoapods/p/DXImageSliderView.svg?style=flat)](https://cocoapods.org/pods/DXImageSliderView)

## Features

- Easy to use
- Light weight
- Customizable Page controller
- Touch to pause auto scrolling


![alt text](https://raw.githubusercontent.com/yasirdx777/DXImageSliderView/main/Example/DXImageSliderView/preview.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

DXImageSliderView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DXImageSliderView'
```

## Usage

First import DXImageSliderView

```swift
import DXImageSliderView
```

Then create the DXImageSliderView

```swift
    let imageSliderData = ["www.example.com/image1.jpg", "www.example.com/image2.jpg", "www.example.com/image3.jpg"]
    
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
```
And implement DXImageSliderView delegates

```swift
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
```

## Author

Yasir Romaya, yasir.romaya@gmail.com

## License

DXImageSliderView is available under the MIT license. See the LICENSE file for more info.
