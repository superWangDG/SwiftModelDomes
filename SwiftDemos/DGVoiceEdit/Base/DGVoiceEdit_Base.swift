//
//  DGVoiceEdit_Base.swift
//  SwiftDemos
//
//  Created by 开十二 on 2021/4/27.
//

import UIKit

class DGVoiceEdit_Base: UIViewController {

    
    override func viewDidLoad() {
        view.backgroundColor = .white
    }
    
    public lazy var mBtnEdit:UIButton! = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 30, y: 90, width: 120, height: 40)
        btn.setTitle("编辑", for: .normal)
        return btn
    }()
    
    
}
