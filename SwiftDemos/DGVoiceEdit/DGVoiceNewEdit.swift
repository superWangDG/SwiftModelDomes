//
//  DGVoiceNewEdit.swift
//  SwiftDemos
//
//  Created by 开十二 on 2021/5/6.
//

import Foundation

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
        
        setupConfig()
    }
    
    func setupConfig() {
        let pathLocation = NSHomeDirectory() + "/tmp/total.m4a"
        desUrl = URL(fileURLWithPath: pathLocation)
        //        voicePath = URL(fileURLWithPath: Bundle.main.path(forResource: "voice", ofType: "mp3") ?? "")
        //        bgPath = URL(fileURLWithPath: Bundle.main.path(forResource: "main_bgm", ofType: "mp3") ?? "")
        //
        voicePath = URL(fileURLWithPath: Bundle.main.path(forResource: "recordVoice", ofType: "mp3") ?? "")
        bgPath = URL(fileURLWithPath: Bundle.main.path(forResource: "main_bgm", ofType: "mp3") ?? "")
    }
    
    @objc func editAction() {
        
//        removeFile(sourceUrl: desUrl.absoluteString)
        
        //        print("DGVoiceNewEdit------------------------->音频合成后的存储地址:\(desUrl.absoluteString)")
        // 开始 合成音频文件 swift 版本
        DGVoiceMixTools.sourceComposeToURL(desUrl, bgURL: bgPath, audio: voicePath, startTime: 1) { (error) in
            if error == nil {
                print("DGVoiceNewEdit------------------------->音频合成已完成")
            } else {
                print("DGVoiceNewEdit------------------------->音频出错\(error.debugDescription)")
            }
        }
        //
                // 开始 合成音频文件 oc 版本
//                MixTool.sourceCompose(to: desUrl, back: bgPath, audioUrl: voicePath, startTime: 0) { (error) in
//                    if error == nil {
//                        print("DGVoiceNewEdit------------------------->音频合成已完成")
//                    } else {
//                        print("DGVoiceNewEdit------------------------->音频出错\(error.debugDescription)")
//                    }
//                }
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
