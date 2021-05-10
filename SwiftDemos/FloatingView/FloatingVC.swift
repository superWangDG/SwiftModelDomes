//
//  FloatingVC.swift
//  SwiftDemos
//  悬浮窗口
//  Created by 开十二 on 2021/3/26.
//

import UIKit

class FloatingVC: UIViewController {

    lazy var mButton :UIButton! = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        button.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        button.setTitle("添加悬浮", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(mButton)
        mButton.frame = CGRect(x: 0, y: 90, width: 150, height: 35)
    }

    
    @objc func submitAction() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .yellow
        DGFloatingMainView.showWithView(rootView: view)
    }
}
