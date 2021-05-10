//
//  SpectrumView.swift
//  GYSpectrum
//  音频音谱动画
//  Created by 开十二 on 2021/3/24.
//  Copyright © 2021 Kaiser All rights reserved.
//

import UIKit
import CoreGraphics

class SpectrumView: UIView {
    
    var itemColor:UIColor! {
        didSet {
            guard let itemLineLayers = itemLineLayers else {
                return
            }
            for itemLine in itemLineLayers {
                itemLine.strokeColor = itemColor.cgColor
            }
        }
    }
    
    // 等级 (-160 - 0) 或 (0 - 160)
    var level:CGFloat! {
        didSet {
            if level < 0 {
                level.negate()
            }
            // 音量的百分比
            var _level = 100 - ((level ?? 0) / 160) * 100
            
            if level == 0 {
                _level = 0
            }
            if _level < 20 {
                // 音量百分比不能小于 20%
                _level = 20
            }
            levels.remove(at: numberOfItems - 1)
            levels.insert(Int(_level), at: 0)
            
            updateItems()
        }
    }
    
    private var middleInterval:CGFloat! {
        didSet {
            setNeedsLayout()
        }
    }
    var itemLevelCallback:(()->Void)?
    
    private var numberOfItems:Int!
    private var levels:[Int]! = []
    private var itemLineLayers:[CAShapeLayer]! = []
    private var itemHeight:CGFloat! = 0
    private var itemWidth:CGFloat! = 0
    private var lineWidth:CGFloat! = 0
    private var displayLink:CADisplayLink!
    
    /// 开始动画效果
    func start() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(invoke))
            displayLink.preferredFramesPerSecond = 6
            displayLink.add(to: .current, forMode: .common)
        }
    }
    /// 关闭动画效果
    func end() {
        if displayLink == nil {
            return
        }
        displayLink.invalidate()
        displayLink = nil
    }
    
    @objc private func invoke() {
        itemLevelCallback?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        itemColor = UIColor(red: 33 / 255.0, green:  33 / 255.0, blue:  33 / 255.0, alpha: 1)
//        itemColor = UIColor.red
        setNumberOfItems(10)
        middleInterval = 0
        setLineWidth(width: 2)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        itemHeight = bounds.size.height
        itemWidth = bounds.size.width
        
        setLineWidth(width: itemWidth / 10.0 * 0.5)
    }
    
    /// 设置线条个数
    /// - Parameter number: <#number description#>
    func setNumberOfItems(_ number:Int) {
        
        if numberOfItems == number {
            return
        }
        numberOfItems = number
        levels = []
        for _ in 0 ..< numberOfItems {
            levels.append(0)
        }
        
        for itemLine in itemLineLayers {
            itemLine.removeFromSuperlayer()
        }
        
        itemLineLayers = []
        for _ in 0 ..< numberOfItems {
            let itemLine = CAShapeLayer()
            itemLine.lineCap = .butt
            itemLine.lineJoin = .round
            itemLine.strokeColor = UIColor.clear.cgColor
            itemLine.fillColor = UIColor.clear.cgColor
            itemLine.strokeColor = itemColor.cgColor
            itemLine.lineWidth = lineWidth
            
            layer.addSublayer(itemLine)
            itemLineLayers.append(itemLine)
        }
    }
    
    /// 设置横线的宽度
    /// - Parameter width: <#width description#>
    func setLineWidth(width:CGFloat) {
        guard let itemLineLayers = itemLineLayers else {
            return
        }
        if lineWidth != width {
            lineWidth = width
            for itemLine in itemLineLayers {
                itemLine.lineWidth = lineWidth
            }
        }
    }
    
    private func updateItems() {
        UIGraphicsBeginImageContext(frame.size)

        let lineOffset = lineWidth * 2.0
        var leftX = Int(lineWidth / 2.0 )
        let lineSumHeight = itemHeight * 0.8
        
        for i in 0 ..< itemLineLayers.count  {
            // 等级的比例
            let levelSclae = (CGFloat(Double(levels[i]) / 100.0))
            // 根据比例计算当前线条的总高
            let lineHeight = lineSumHeight * levelSclae
            
            let pathTop = (itemHeight / 2.0) - (lineHeight / 2.0)
            let pathBottom = pathTop + lineHeight
            
//            let pathTop = (itemHeight / 2.0) - (lineHeight / 2.0)
//            let pathBottom =  CGFloat(itemHeight)
            
            let linePathLeft = UIBezierPath()
            linePathLeft.move(to: CGPoint(x: leftX, y: Int(pathTop)))
            linePathLeft.addLine(to: CGPoint(x: leftX, y: Int(pathBottom)))
            
            itemLineLayers[i].path = linePathLeft.cgPath
            
            leftX += Int(lineOffset)
        }
        UIGraphicsEndImageContext()
    }
}
