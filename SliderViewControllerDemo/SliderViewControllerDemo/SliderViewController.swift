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
    private let titleSliderView: TitleSliderView
    private let viewControllers: [UIViewController]
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
        view.addSubview(titleSliderView)
        view.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: titleSliderView.frame.maxY, width: view.bounds.width, height: view.bounds.height - titleSliderView.bounds.height - 44 - UIApplication.shared.statusBarFrame.height)
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
let ScreenW = UIScreen.main.bounds.width
let LabelW = ScreenW / 6

protocol TitleSliderViewDelegate: NSObjectProtocol {
    func titleSliderViewDidClick(index: Int)
}
class TitleSliderView: UIView {
    private var titleSelColor: UIColor?
    private var previousLabel: UILabel?
    private var labels = [UILabel]()
    private var sliderViewController: SliderViewController?
    private var titles = [String]()
    var delegate: TitleSliderViewDelegate?
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
        scrollView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
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
            titleFont != nil ? (label.font = titleFont) : (label.font = UIFont.systemFont(ofSize: 14, weight: .medium))
            
            scrollView.addSubview(label)
            label.frame = CGRect(x: CGFloat(CFloat(index)) * LabelW, y: lbY, width: LabelW, height: lbH-2)
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

extension TitleSliderView: SliderViewControllerDelegate {
    
    func SliderViewControllerScrollViewDidScroll(scrollView: UIScrollView) {
        let rate = scrollView.contentOffset.x / scrollView.bounds.width
        bottomLineView.center.x = rate * LabelW + LabelW * 0.5
        
        if let lastComponent = ("\(rate)" as NSString).components(separatedBy: ".").last{
            if Float(lastComponent) == 0{
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
