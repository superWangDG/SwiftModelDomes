//
//  CAShapeLayerDome.swift
//  SwiftDemos
//
//  Created by 开十二 on 2021/3/25.
//

import UIKit

class CAShapeLayerDome: UIViewController {

    private var displayLink:CADisplayLink! = CADisplayLink()
    /// 录音动画视图
    lazy var mSpectrumView : SpectrumView! = {
        let spectrumView = SpectrumView(frame: CGRect(x: 0, y: 0, width: 23, height: 65))
//        spectrumView.middleInterval = 0
        spectrumView.itemLevelCallback = {
            [weak self] in
            guard let self = self else { return }
            let random = (0 ..< 160).random
            spectrumView.level = CGFloat(random)
        }
        return spectrumView
    }()
    
    
    lazy var mButton :UIButton! = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        button.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        button.setTitle("点击停止动画", for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(mSpectrumView)
        mSpectrumView.frame = CGRect(x: 40, y: 200, width: 60, height: 35)
        mSpectrumView.backgroundColor = .gray
        mSpectrumView.start()
        
        
        view.addSubview(mButton)
        mButton.frame = CGRect(x: 0, y: 350, width: 200, height: 40)
    }

    
    @objc func submitAction() {
        mSpectrumView.end()
    }
    
}


extension Range where Bound: FixedWidthInteger {

    var random: Bound { .random(in: self) }

    func random(_ n: Int) -> [Bound] { (0..<n).map { _ in random } }

}

extension ClosedRange where Bound: FixedWidthInteger  {

    var random: Bound { .random(in: self) }

    func random(_ n: Int) -> [Bound] { (0..<n).map { _ in random } }
}
