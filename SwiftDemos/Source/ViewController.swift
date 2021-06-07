//
//  ViewController.swift
//  SwiftDemos
//
//  Created by 开十二 on 2020/12/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mTbaleView: UITableView!
    var demoList = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mTbaleView.tableFooterView = UIView()
        
        demoList.append(["title":NSStringFromClass(VoiceRecordEditVC.self),"des":"音频录制编辑Demo"])
        
        demoList.append(["title":NSStringFromClass(TestViewController.self),"des":"Memory Demo"])
        
//        demoList.append(["title":NSStringFromClass(VisionMainVC.self),"des":"图片识别 Demo"])
        demoList.append(["title":NSStringFromClass(OCRSwiftDemo.self),"des":"文字识别 Demo"])
        
        
        demoList.append(["title":NSStringFromClass(SwifterVC.self),"des":"对swift kit扩展的Demo"])
        
        demoList.append(["title":NSStringFromClass(OpenAppViewController.self),"des":"打开其他应用"])
        
        demoList.append(["title":NSStringFromClass(CAShapeLayerDome.self),"des":"动画应用"])
        
        demoList.append(["title":NSStringFromClass(FloatingVC.self),"des":"窗口悬浮"])
        
        demoList.append(["title":NSStringFromClass(DGVoiceNewEdit.self),"des":"音频混音"])
        
        demoList.append(["title":NSStringFromClass(AudioPlayerEditVC.self),"des":"音频播放"])
        
    }
}

extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.demoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell_id")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell_id")
//            cell?.textLabel?.text = self.demoList[indexPath.row]["title"]
//            cell?.detailTextLabel?.text = self.demoList[indexPath.row]["des"]
            cell?.textLabel?.text = self.demoList[indexPath.row]["des"]
            cell?.detailTextLabel?.text = self.demoList[indexPath.row]["title"]
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = self.demoList[indexPath.row]["title"]
        let vc = (NSClassFromString(title!) as! UIViewController.Type).init()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
//        let nav = UINavigationController(rootViewController: vc)
//        nav.title = title
        vc.title = self.demoList[indexPath.row]["des"]
//        self.present(nav, animated: true, completion: nil)
        navigationController?.pushViewController(vc)
//        self.present(vc, animated: true) {
//
//        }
    }
    
    
}

