//
//  VoiceRecordEditVC.swift
//  SwiftDemos
//  录音编辑页面
//  Created by 开十二 on 2020/12/14.
//

import UIKit
//import 

class VoiceRecordEditVC: UIViewController {

    
    /// 最大可录制的秒数 ：默认 9000秒为2.5小时
    var recordMaxSecond = 9000
    /// 间隔
    var interval = 70
    
    /// 当前已录制多少秒
    var currentRecordSecond = 10
    
    
    /// 初始化录音机
    lazy var voiceRecord:AudioRecorderModel? = {
        return AudioRecorderModel()
    }()
    
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
    
    deinit {
        self.voiceRecord = nil
        print("我都输出了  你猜呢?")
    }
    
    /// 编辑的背景视图
    lazy var mEditBackMainView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        view.layer.borderColor = UIColor(red: 244 / 255.0, green: 244 / 255.0, blue: 244 / 255.0, alpha: 1).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.frame = CGRect(x: 12, y: -10, width: UIScreen.main.bounds.width - 24, height: 480)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
    
        return view
    }()
    
    /// 显示音频的时间
    lazy var mLabShowTime:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkGray
        label.frame = CGRect(x: 0, y: 80, width: self.mEditBackMainView.frame.size.width, height: 30)
        label.text = "00:00"
        return label
    }()
    
    /// 底部工具视图
    lazy var mBottomToolsView:UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y:  self.mEditBackMainView.frame.size.height - 60, width: self.mEditBackMainView.frame.size.width, height: 60)
        view.backgroundColor = .clear
        return view
    }()
    
    /// 中间展示编辑视图的按钮
    lazy var mBtnNarrow : UIButton = {
        let button = UIButton(type: .custom)
//        button.setTitle("小", for: .normal)
        button.setImage(UIImage(named: "ic_record_arrow"), for: .normal)
        button.addTarget(self, action: #selector(narrowAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.frame = CGRect(x: mBottomToolsView.frame.size.width / 2.0 - 22, y: mBottomToolsView.frame.size.height - 32, width: 44, height: 20)
        return button
    }()
    /// 播放的按钮
    lazy var mBtnPlay : UIButton = {
        let button = UIButton(type: .custom)
//        button.setTitle("放", for: .normal)
        button.setImage(UIImage(named: "ic_record_play"), for: .normal)
        button.setImage(UIImage(named: "ic_record_pause"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(playOrPasueAction), for: .touchUpInside)
        let x = (self.mBtnNarrow.frame.origin.x + (self.mBtnNarrow.frame.size.width / 2.0)) / 2.0 - 10
        button.frame = CGRect(x: x, y: self.mBtnNarrow.center.y - 10, width: 20, height: 20)
//        button.setImage(UIImage(named: ""), for: .normal)
//        button.setImage(UIImage(named: ""), for: .selected)
        return button
    }()
    /// 裁剪的按钮
    lazy var mBtnEdit : UIButton = {
        let button = UIButton(type: .custom)
//        button.setTitle("裁", for: .normal)
        button.setImage(UIImage(named: "ic_record_edit"), for: .normal)
        button.addTarget(self, action: #selector(narrowAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        let x = self.mBtnNarrow.center.x + ((self.mBtnNarrow.frame.origin.x + (self.mBtnNarrow.frame.size.width / 2.0)) / 2.0 - 10)
        button.frame = CGRect(x: x, y: self.mBtnNarrow.center.y - 10, width: 20, height: 20)
        return button
    }()
    
    /// 编辑音频的视图
    lazy var mVoiceScrollView : UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: self.mBottomToolsView.frame.origin.y - 160, width: self.mEditBackMainView.frame.size.width, height: 160))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
                
        return scrollView
    }()
    
    /// 顶部标志线
    lazy var mVoiceEditTop : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: currentRecordSecond * interval, height: 25)
      
        // 创建标线视图
        self.createMarkingView(rootView: view)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 25, width: view.frame.size.width, height: 0.5))
        lineView.backgroundColor = UIColor(red: 198 / 255.0, green: 201 / 255.0, blue: 211 / 255.0, alpha: 1)
        view.addSubview(lineView)

        return view
    }()
    
    
    /// 编辑的内容视图
    lazy var mContentEditView : UIView = {
       let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: mVoiceEditTop.frame.size.width, height: mVoiceScrollView.frame.size.height)
        return view
    }()
    
    /// 音谱的视图
    lazy var mCSoundSpectrumView : UIView = {
       let view = UIView()
        view.frame = CGRect(x: 0, y: mVoiceEditTop.frame.size.height + 1, width: mContentEditView.frame.size.width, height: mContentEditView.frame.size.height - mVoiceEditTop.frame.size.height - 1)
            
        view.backgroundColor = UIColor(red: 249 / 255, green: 249 / 255, blue: 249 / 255, alpha: 1)
        
        let line = UIView()
        line.frame = CGRect(x:  0, y: view.frame.size.height / 2.0 - 0.25, width: view.frame.size.width, height: 0.5)
        line.backgroundColor = UIColor(red: 227 / 255.0, green: 227 / 255.0, blue: 229 / 255.0, alpha: 1)
        view.addSubview(line)
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.voiceRecord?.setupVoice()
        
        self.voiceRecord?.audioStateChangeBlock = {
            [weak self] (error,objDic) in
            if error != nil {
                // 存在错误提示 无法进行下一步
            } else {
                // 正常的操作
                if objDic?["state"] == nil {
                    return
                }
                let state = objDic!["state"] as! Int
                if state == 1 {
                    // 正在录音中 获取录音时长
                    if objDic!["currentTime"] != nil && Int(objDic!["currentTime"] as! Double) > 10 {
                        self?.currentRecordSecond = Int(objDic!["currentTime"] as! Double)
                        self?.clearCreateMarkingView()
                        self?.createMarkingView(rootView: self!.mVoiceEditTop)

                        self?.mContentEditView.frame = CGRect(x: 0, y: 0, width: self!.mVoiceEditTop.frame.size.width, height: self!.mVoiceScrollView.frame.size.height)
                        self?.mVoiceScrollView.contentSize = CGSize(width: self!.mContentEditView.frame.size.width, height: self!.mVoiceScrollView.frame.size.height)

                        print("开始创建声音波形:\(self!.currentRecordSecond)")
                    }

                }

            }
        }
    }
}
