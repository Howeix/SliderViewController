//
//  SliderViewController.swift
//  layoutDemo
//
//  Created by lifevc on 2019/6/12.
//  Copyright © 2019 LifeVC. All rights reserved.
//

import UIKit
//MARK: - SliderViewController
protocol SliderViewControllerDelegate: NSObjectProtocol {
    func SliderViewControllerScrollViewDidScroll(scrollView: UIScrollView)
}
class SliderViewController: UIViewController {
    public var delegate: SliderViewControllerDelegate?
    public let titleSliderView: TitleSliderView
    let viewControllers: [UIViewController]
    private var superVC: UIViewController?
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        return scrollView
    }()

    init(titles:[String], superVC: UIViewController? = nil, viewControllers: [UIViewController], titleSelColor: UIColor? = UIColor.black) {
        titleSliderView = TitleSliderView(titles: titles, titleSelColor: titleSelColor)
        self.superVC = superVC
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
        titleSliderView.delegate = self
        self.delegate = titleSliderView
        edgesForExtendedLayout = .bottom
        view.backgroundColor = UIColor.white
        setUI()
    }
    private func setUI() {
        view.addSubview(scrollView)
        view.addSubview(titleSliderView)
//        scrollView.frame = CGRect(x: 0, y: titleSliderView.frame.maxY, width: view.bounds.width, height: view.bounds.height - titleSliderView.bounds.height - 44 - UIApplication.shared.statusBarFrame.height)
         scrollView.frame = CGRect(x: 0, y: 40, width: view.bounds.width, height: view.bounds.height - titleSliderView.bounds.height - 44 - UIApplication.shared.statusBarFrame.height)
        scrollView.contentSize = CGSize(width: CGFloat(viewControllers.count) * ScreenW, height: scrollView.bounds.height)

        let viewW: CGFloat = scrollView.bounds.width
        let viewH: CGFloat = scrollView.bounds.height
        for (index,vc) in viewControllers.enumerated() {
            vc.view.frame = CGRect(x: CGFloat(index) * viewW, y: 0, width: viewW, height: viewH)
            scrollView.addSubview(vc.view)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SliderViewController: UIScrollViewDelegate,TitleSliderViewDelegate{
    func titleSliderViewDidClick(index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.scrollView.contentOffset.x = CGFloat(index) * ScreenW
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.SliderViewControllerScrollViewDidScroll(scrollView: scrollView)
    }
    
}


//MARK: - TitleSliderView
let FIXED_TAG_COUNT = 6
let ScreenW = UIScreen.main.bounds.width
var LabelW = ScreenW / CGFloat(FIXED_TAG_COUNT)

protocol TitleSliderViewDelegate: NSObjectProtocol {
    func titleSliderViewDidClick(index: Int)
}
class TitleSliderView: UIView {
    
    private var titleSelColor: UIColor?
    private var previousLabel: UILabel?
    private var labels = [UILabel]()
    private var sliderViewController: SliderViewController?
    public var titles = [String]()
    public var delegate: TitleSliderViewDelegate?
    private lazy var bottomLineView: UIView = {
        let bottomLineView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1.8))
        bottomLineView.layer.cornerRadius = bottomLineView.bounds.height * 0.5
        bottomLineView.layer.masksToBounds = true
        return bottomLineView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.bounces = false
        return scrollView
    }()
    
    init(titles: [String], titleFont: UIFont? = nil, titleSelColor: UIColor?) {
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenW, height: 40))
        self.titles = titles
        scrollView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.width, height: 40))
        
        addSubview(scrollView)
        self.titleSelColor = titleSelColor
        setLabels(titleFont: titleFont)
        bottomLineView.backgroundColor = titleSelColor
        scrollView.addSubview(bottomLineView)
        scrollView.bringSubviewToFront(bottomLineView)
    }
    
    private func setLabels(titleFont: UIFont?) {
        let lbY: CGFloat = 0
        let lbH: CGFloat = bounds.height
        for (index,title) in titles.enumerated() {
            let label = UILabel()
            label.tag = index + 2048
            label.textAlignment = .center
            label.textColor = UIColor.black
            label.text = title
            label.backgroundColor = .white
            titleFont != nil ? (label.font = titleFont) : (label.font = UIFont.systemFont(ofSize: 14, weight: .medium))
            
            scrollView.addSubview(label)
            if titles.count < FIXED_TAG_COUNT {
                LabelW = UIScreen.main.bounds.width / CGFloat(titles.count)
                label.frame = CGRect(x: CGFloat(CFloat(index)) * LabelW, y: lbY, width: LabelW, height: 40-2)
            }else{
                label.frame = CGRect(x: CGFloat(CFloat(index)) * LabelW, y: lbY, width: LabelW, height: 40-2)
            }
            
            label.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(lbClick(ges:)))
            label.addGestureRecognizer(tapGes)
//            let textWidth = (label.text! as NSString).size(withAttributes: [NSAttributedString.Key.font:label.font as Any]).width
//            titlesFontWidthArr.append(textWidth)
            if index == 0 {
                bottomLineView.center.x = label.center.x
                bottomLineView.frame.origin.y = label.frame.maxY
                bottomLineView.bounds.size.width = LabelW
                label.textColor = titleSelColor
                previousLabel = label
            }
            labels.append(label)
        }
        scrollView.contentSize = CGSize(width: CGFloat(LabelW * CGFloat(titles.count)), height: lbH)
    }

    @objc private func lbClick(ges: UIGestureRecognizer) {
        let label = ges.view as! UILabel
        delegate?.titleSliderViewDidClick(index: label.tag - 2048)
        
        UIView.animate(withDuration: 0.25) {
            self.bottomLineView.center.x = label.center.x
        }
        
        var offsetX = label.center.x - scrollView.frame.size.width * 0.5
        if offsetX < 0 {
            offsetX = 0
        }
        if offsetX > scrollView.contentSize.width - scrollView.frame.size.width {
            offsetX = scrollView.contentSize.width - scrollView.frame.size.width
        }
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



//class ExtendView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 40
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EXTENDVIEWCOLLECTIONVIEWCELLID", for: indexPath)
//
//
//        let btn = UIButton(type: .custom)
//
//        btn.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
//        let attrs = NSAttributedString(string: "哈哈", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12, weight: .medium), NSAttributedString.Key.foregroundColor:UIColor.red])
//        btn.setAttributedTitle(attrs, for: .normal)
//        btn.center = cell.contentView.center
//        cell.contentView.addSubview(btn)
//        cell.backgroundColor = .green
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
//    }
//
//
//    lazy var collectionView: UICollectionView = {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.itemSize = CGSize(width: 60, height: 25)
////        flowLayout.minimumLineSpacing = 10
//        flowLayout.minimumInteritemSpacing = 12
//        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80), collectionViewLayout: flowLayout)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.bounces = false
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EXTENDVIEWCOLLECTIONVIEWCELLID")
//        collectionView.backgroundColor = .white
//        collectionView.layer.borderColor = UIColor.lightGray.cgColor
//        collectionView.layer.borderWidth = 0.5
//        return collectionView
//    }()
//    lazy var extendBtn: UIButton = {
//       let extendBtn = UIButton(type: .custom)
//        extendBtn.setImage(#imageLiteral(resourceName: "anchor_post_bar_normal_18x18_"), for: .normal)
//        extendBtn.sizeToFit()
//        extendBtn.addTarget(self, action: #selector(extendBtnClick), for: .touchUpInside)
//        return extendBtn
//    }()
//
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = super.hitTest(point, with: event)
//        let tmpPoint = extendBtn.convert(point, from: self)
//        if extendBtn.point(inside: tmpPoint, with: event) {
//            return extendBtn
//        }
//        return view
//    }
//
//    @objc func extendBtnClick(){
//        extendBtn.isSelected = !extendBtn.isSelected
//        if extendBtn.isSelected {
//            UIView.animate(withDuration: 0.35) {
//                self.frame.origin.y += self.frame.height
//            }
//        }else{
//            UIView.animate(withDuration: 0.35) {
//                self.frame.origin.y -= self.frame.height
//            }
//        }
//    }
//
//    init() {
//        super.init(frame: CGRect(x: 0, y: -40, width: ScreenW, height: 80))
//        self.backgroundColor = .clear
//        extendBtn.frame.origin.x = frame.size.width - extendBtn.bounds.width
//        extendBtn.frame.origin.y = frame.height
//        addSubview(extendBtn)
//        addSubview(collectionView)
//        collectionView.reloadData()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}

extension TitleSliderView: SliderViewControllerDelegate {
    func SliderViewControllerScrollViewDidScroll(scrollView: UIScrollView) {
        let rate = scrollView.contentOffset.x / scrollView.bounds.width
        bottomLineView.center.x = rate * LabelW + LabelW * 0.5
        if let lastComponent = ("\(rate)" as NSString).components(separatedBy: ".").last{
            if Float(lastComponent) == 0 {
                let label = labels[Int(rate)]
                label.textColor = titleSelColor
                if previousLabel !== label {
                    previousLabel?.textColor = UIColor.black
                }
                previousLabel = label
                if let ges = label.gestureRecognizers?.first{
                    lbClick(ges: ges)
                }
            }
        }
    }
}
