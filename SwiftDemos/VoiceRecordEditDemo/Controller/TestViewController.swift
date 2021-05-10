//
//  TestViewController.swift
//  SwiftDemos
//
//  Created by 开十二 on 2020/12/15.
//

import UIKit

class TestViewController: UIViewController {

    /// 关闭按钮
    lazy var mBtnClose : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("关", for: .normal)
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        button.frame = CGRect(x: 25, y: 40, width: 31, height: 31)
        button.layer.cornerRadius = 15.5
        button.layer.masksToBounds = true
        button.backgroundColor = .lightGray
        return button
    }()
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.mBtnClose)
    }
    

    deinit {
        print("我靠 你出来了吧")
    }
}
