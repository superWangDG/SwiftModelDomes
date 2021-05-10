//
//  VoiceRecordEditVC+Action.swift
//  SwiftDemos
//
//  Created by 开十二 on 2020/12/14.
//

import Foundation

extension VoiceRecordEditVC {
    
    /// 关闭当前窗口的事件
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 缩小编辑视图的事件
    @objc func narrowAction() {
        
    }
    
    @objc func playOrPasueAction() {
//        if self.voiceRecord.playState == 0 || self.voiceRecord.playState == 2  {
//            // 开始播放
//            self.voiceRecord.playRecorderAudio()
//        }
//        
//        else {
//            // 属于播放状态 暂停播放
//            self.voiceRecord.pauseRecorderAudio()
//        }
        
    }
    
    
    
    /// 根据秒数得到 分钟的数
    /// - Parameter second: 秒数
    /// - Returns: 例: 00:00
    func getDoubleWithToTimeMinute(second:Double) -> String {
        var strMinute = "\(Int(second / 60))"
        if Int(second / 60) < 10 {
            strMinute = "0\(Int(second / 60))"
        }
        
        var strSecond = "\(Int(second) % 60)"
        if Int(second) % 60 < 10 {
            strSecond = "0\(Int(second) % 60)"
        }
        return "\(strMinute):\(strSecond)"
    }
    
}
