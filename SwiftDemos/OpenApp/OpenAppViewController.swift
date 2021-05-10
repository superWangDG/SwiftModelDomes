//
//  OpenAppViewController.swift
//  SwiftDemos
//
//  Created by 开十二 on 2021/1/12.
//

import UIKit

class OpenAppViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        let button = UIButton(type: .custom)
        button.setTitle("打开应用", for: .normal)
        button.frame = CGRect(x: 0, y: 100, width: 200, height: 50)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func buttonAction() {
//        k12campusiOS
        
        // 带参数
        //  k12campusiOS:///parent/CXMyRecitationDetail_Vc/5
        
        let url = "k12campusios:///parent/CXRanking_Vc"
        
//        let url = "activelabeldome://"
        
        guard let urlLocal = URL(string: url), UIApplication.shared.canOpenURL(urlLocal) else {
            print("跳转失败")
            return
        }
//        UIApplication.shared.canOpenURL(urlLocal)
        UIApplication.shared.open(urlLocal, options: [:]) { (isOk) in
            print("跳转结果\(isOk)")
        }

    }

}
