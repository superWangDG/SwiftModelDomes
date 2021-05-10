//
//  DGVoiceEdit_VC.swift
//  SwiftDemos
//
//  Created by 开十二 on 2021/4/27.
//

import UIKit
import AVFoundation


class DGVoiceEdit_VC: DGVoiceEdit_Base {
    
    
    /// 音频指令集
    var audioMixParams: [AVMutableAudioMixInputParameters] = []
    /// 音频合成器
    var mutableAudioMix: AVMutableAudioMix?
    var assetAudioTrack: AVAssetTrack?
    /// 音视频组合对象
    var mutableComposition: AVMutableComposition?
    var cacheComposition: AVMutableComposition?
    
    var trackDegree: Int = 0
    var totalDuration: CMTime?
    
    /// 标记是否在执行拼接操作
    var isAppending = false
    
    var oneAsset:AVURLAsset!
    var twoAsset:AVURLAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 获取主音频的资源
        let oneURL = Bundle.main.url(forResource: "voice", withExtension: "mp3")
        if oneURL != nil {
            oneAsset = AVURLAsset(url: oneURL!)
        }
        
        // 获取副音频的资源
        let twoURL = Bundle.main.url(forResource: "main_bgm", withExtension: "mp3")
        if twoURL != nil {
            twoAsset = AVURLAsset(url: twoURL!)
            
        }
        
        view.addSubview(mBtnEdit)
        mBtnEdit.setTitle("开始合成", for: .normal)
        mBtnEdit.addTarget(self, action: #selector(editAction), for: .touchUpInside)
    }
    
    @objc func editAction() {
        guard (oneAsset != nil) else {
            print("主音频获取失败")
            return
        }
        
        guard (twoAsset != nil) else {
            print("副音频获取失败")
            return
        }
        
        mergeVoice()
    }
    
    
    /// 开始合成音频文件
    func mergeVoice() {
        //可以看做轨道集合
        let compostion = AVMutableComposition()
        
        //创建音频轨道素材----此处创建的为音轨属性，可以理解为合成物所需要的原料 ，对音轨的加工都在这个方法里面进行，此处为音频合成MediaType为 AVMediaTypeAudio
        let appendedAudioTrack:AVMutableCompositionTrack = compostion.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let appendedAudioTrack2:AVMutableCompositionTrack = compostion.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        
        //将初始资产再加工生成可用于拼接的（音轨资产） tracksWithMediaType()输出为[AVAssetTrack]数组取处于第一位的资源，也可能产物就是一个，只不过相当于用了个筐来盛放
        let assetTrack1:AVAssetTrack = oneAsset.tracks(withMediaType: AVMediaType.audio).first!
        
        let assetTrack2:AVAssetTrack = twoAsset.tracks(withMediaType: AVMediaType.audio).first!
        
        
        //控制时间范围
        let timeRange1 = CMTimeRangeMake(start: CMTime.zero, duration: oneAsset.duration) // 得到第一个音频的时长
        //        let timeRange2 = CMTimeRangeMake(start: CMTime.zero, duration: twoAsset.duration) // 得到第二个音频的时长
        
        
        let startTime = CMTimeMakeWithSeconds(0, preferredTimescale: 1)
        
        // 混音降低音量
        let audioMix = AVMutableAudioMix()
        let assetParame1 = AVMutableAudioMixInputParameters(track: assetTrack1)
        assetParame1.setVolume(0.01, at: startTime)
        let assetParame2 = AVMutableAudioMixInputParameters(track: assetTrack2)
        assetParame2.setVolume(0.01, at: CMTime.zero)
//        audioMix.inputParameters = [assetParame2,assetParame1]
        audioMix.inputParameters = [assetParame2]
        
        //        print("音频音量1:\(assetTrack1.preferredVolume)\t 2:\(assetTrack2.preferredVolume)")
        //******音频合并，插入音轨文件，---音轨拼接（只要选好插入的时间点，插入的音轨资源可将多个assetTrack1（音轨资产）拼接到一起）
        try! appendedAudioTrack2.insertTimeRange(timeRange1, of: assetTrack2, at:CMTime.zero)//这里kCMTimeZero可以跟换一下，单必须是CMTime类型的，如果都是用kCMTimeZero，就会声音重叠
        try! appendedAudioTrack.insertTimeRange(timeRange1, of: assetTrack1, at:CMTime.zero)
        
        
        
        
        //********导出合并后的音频文件
        let exportSession:AVAssetExportSession = AVAssetExportSession(asset: compostion, presetName:AVAssetExportPresetAppleM4A)!
        
        //这里就用到了上面的composition,composition作为原料加上下面的各种属性最终生成了指定路径下的目标文件
        let realPath = NSHomeDirectory() + "/tmp/total.m4a" //指定路径
        print("创建文件的地址\(realPath)")
        exportSession.audioMix = audioMix
        exportSession.outputURL = URL(fileURLWithPath: realPath)
        exportSession.outputFileType = AVFileType.m4a
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed: print("混音失败\(exportSession.error!)"); break
            case .completed: print("混音完成"); break
            case .waiting: print("混音正在执行中..."); break
            default:break
            }
        })
    }
    
    func trackAsset(_ composition:AVMutableComposition,urlAsset:AVURLAsset,kTimeRange:CMTimeRange? = nil) {
        
        //创建音频轨道素材----此处创建的为音轨属性，可以理解为合成物所需要的原料 ，对音轨的加工都在这个方法里面进行，此处为音频合成MediaType为 AVMediaTypeAudio
        let appendedAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)!
        //将初始资产再加工生成可用于拼接的（音轨资产） tracksWithMediaType()输出为[AVAssetTrack]数组取处于第一位的资源，也可能产物就是一个，只不过相当于用了个筐来盛放
        let assetTrack:AVAssetTrack = urlAsset.tracks(withMediaType: AVMediaType.audio).first!
        
        var timeRange:CMTimeRange!
        
        if kTimeRange == nil {
            timeRange = CMTimeRangeMake(start: CMTime.zero, duration: urlAsset.duration) // 得到第音频的时长
        } else {
            timeRange = kTimeRange
        }
        
        try! appendedAudioTrack.insertTimeRange(timeRange, of: assetTrack, at:CMTime.zero)
    }
    
}
