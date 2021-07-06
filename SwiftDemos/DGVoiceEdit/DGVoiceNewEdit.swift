//
//  DGVoiceNewEdit.swift
//  SwiftDemos
//
//  Created by 开十二 on 2021/5/6.
//

import AVKit

class DGVoiceNewEdit:DGVoiceEdit_Base {
    
    /// 合成后音频的地址
    var desUrl:URL!
    /// 主要音频的地址
    var voicePath:URL!
    /// 背景音频的地址
    var bgPath:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mBtnEdit)
        mBtnEdit.setTitle("开始合成", for: .normal)
        mBtnEdit.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
//        let mBtnPushList = UIButto
        let btnList = UIButton(type: .system)
        btnList.frame = CGRect(x: 40, y: 200, width: 200, height: 35)
        btnList.addTarget(self, action: #selector(pushListAction), for: .touchUpInside)
        btnList.setTitle("选择音乐", for: .normal)
        view.addSubview(btnList)
        
        setupConfig()
    }
    
    func setupConfig() {
        // 创建本地存储
//        let model = DGVoiceMixFileModel(id: 1, voiceTitle: "背景音乐", voiceUrl: "www.baidu.com", voiceTime: 30, voiceAvatar: "www.baidu.com", localVoicePath: "www.baidu.com")
//
//        let model1 = DGVoiceMixFileModel(id: 2, voiceTitle: "背景音乐1", voiceUrl: "www.baidu.com", voiceTime: 30, voiceAvatar: "www.baidu.com", localVoicePath: "www.baidu.com")
//
//        let model2 = DGVoiceMixFileModel(id: 3, voiceTitle: "背景音乐2", voiceUrl: "www.baidu.com", voiceTime: 30, voiceAvatar: "www.baidu.com", localVoicePath: "www.baidu.com")
//
//        let model3 = DGVoiceMixFileModel(id: 5, voiceTitle: "背景音乐新增", voiceUrl: "www.baidu.com", voiceTime: 30, voiceAvatar: "www.baidu.com", localVoicePath: "www.baidu.com")
//
//        let model4 = DGVoiceMixFileModel(id: 7, voiceTitle: "背景音乐新增", voiceUrl: "www.baidu.com", voiceTime: 30, voiceAvatar: "www.baidu.com", localVoicePath: "www.baidu.com")
//
//        DGVoiceMixFileManager.default.saveModelList(list: [model,model4,model1,model2,model3])
//        DGVoiceMixFileManager.default
        
        let pathLocation = NSHomeDirectory() + "/tmp/total.m4a"
        desUrl = URL(fileURLWithPath: pathLocation)
        voicePath = URL(fileURLWithPath: Bundle.main.path(forResource: "recordVoice", ofType: "mp3") ?? "")
        bgPath = URL(fileURLWithPath: Bundle.main.path(forResource: "main_bgm", ofType: "mp3") ?? "")
    }
    
    
    /// 进入音频选择列表
    @objc func pushListAction() {
        navigationController?.pushViewController(DGVoiceBGMList_Vc())
    }
    
    @objc func editAction() {
        
        // 开始 合成音频文件 swift 版本
        DGVoiceMixTools.sourceComposeToURL(desUrl, bgURL: bgPath, audio: voicePath, startTime: 1) { (error) in
            if error == nil {
                print("DGVoiceNewEdit------------------------->音频合成已完成")
            } else {
                print("DGVoiceNewEdit------------------------->音频出错\(error.debugDescription)")
            }
        }
    }
    
    // 删除目标文件
    func removeFile(sourceUrl:String){
        let fileManger = FileManager.default
        do{
            try fileManger.removeItem(atPath: sourceUrl)
            print("Success to remove file.")
        }catch{
            print("Failed to remove file.\(error)")
        }
    }
    
}
