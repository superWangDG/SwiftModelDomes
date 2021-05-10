//
//  DGVoiceMixTools.swift
//  SwiftDemos
//  Swift版本的音频混音
//  Created by 开十二 on 2021/5/6.
//

import AVFoundation

class DGVoiceMixTools {
    
    /// 合成音频（混音）
    /// - Parameters:
    ///   - toURL: 目标存储路径
    ///   - bgURL: 背景音乐的地址
    ///   - audio: 主要音频的地址
    ///   - startTime: 主音频开始的时间
    ///   - completed: 完成的回调
    static func sourceComposeToURL(_ toURL:URL,bgURL:URL,audio:URL,startTime:Float64,completed:((_ error:Error?)->Void)?) {
        // 背景音频的参数设置
        let mixComposition = AVMutableComposition()
        
        let recordAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let recordAudioAsset = AVURLAsset(url: audio)
        let audioDuration = recordAudioAsset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        let duration = CMTimeMake(value: Int64(audioDurationSeconds), timescale: 1)
        let audio_timeRange = CMTimeRange(start: CMTime(value: 0, timescale: 1), duration: duration)
        
        if CMTimeGetSeconds(AVURLAsset(url: bgURL).duration) == 0 {
            completed?(NSError(domain: "背景音频文件获取时长失败无法继续", code: 100000, userInfo: nil))
            return
        }
        if audioDurationSeconds == 0 {
            completed?(NSError(domain: "主音频文件获取时长失败无法继续", code: 100001, userInfo: nil))
            return
        }
        let bgAudioMixParams = insertBgVoice(mixComposition: mixComposition, recordAudioAsset: recordAudioAsset, backAudioUrl: bgURL)
        do {
            try recordAudioTrack?.insertTimeRange(audio_timeRange, of: recordAudioAsset.tracks(withMediaType: .audio).first!, at: CMTime.zero)
        } catch _ {
            
        }
        let backAudioMix = AVMutableAudioMix()
        backAudioMix.inputParameters = bgAudioMixParams
        
        exportM4AFile(mixComposition, exportUrl: toURL, backAudioMix: backAudioMix) { (error) in
            completed?(error)
        }
    }
    
    
    /// 循环插入背景音乐
    /// - Parameters:
    ///   - mixComposition: <#mixComposition description#>
    ///   - recordAudioAsset: <#recordAudioAsset description#>
    ///   - backAudioUrl: <#backAudioUrl description#>
    private static func insertBgVoice(mixComposition:AVMutableComposition,recordAudioAsset:AVURLAsset,backAudioUrl:URL) -> [AVMutableAudioMixInputParameters] {
        let backAudioAsset = AVURLAsset(url: backAudioUrl)
        // 获取音频的完成时间
        let recordDuration = CMTimeGetSeconds(recordAudioAsset.duration)
        let bgDuration = CMTimeGetSeconds(backAudioAsset.duration)
        
        // 判断主音频的时间如果小于背景音乐 证明无需循环添加音轨资源
        var count:Int = Int(ceilf(Float(recordDuration / bgDuration)))
        if recordDuration < bgDuration {
            count = 1
        }
        
        var audioMixParams = [AVMutableAudioMixInputParameters]()
        var beginTime = CMTime.zero
        for i in 0 ..< count {
            let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            var currentDuration = bgDuration * Float64((i + 1))
            var duration = backAudioAsset.duration
            
            if currentDuration > recordDuration {
                currentDuration = bgDuration - (currentDuration - recordDuration)
                duration = CMTime(value: CMTimeValue(currentDuration), timescale: 1)
            }
            
            let count_bg_timeRange = CMTimeRange(start: .zero, duration: duration)
            
            do {
                try compositionAudioTrack?.insertTimeRange(count_bg_timeRange, of: backAudioAsset.tracks(withMediaType: .audio).first!, at: beginTime)
            } catch _ {
                
            }
            
            let minColumeMix = AVMutableAudioMixInputParameters(track: compositionAudioTrack)
            minColumeMix.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0.5, timeRange: CMTimeRange(start: CMTime(value: 0, timescale: 1), duration: CMTime(value: 2, timescale: 1)))
            audioMixParams.append(minColumeMix)
            beginTime = CMTimeAdd(beginTime, backAudioAsset.duration)
        }
        
        return audioMixParams
    }
    
    private static func exportM4AFile(_ mixComposition:AVMutableComposition,exportUrl:URL,backAudioMix:AVMutableAudioMix,completed:((_ error:Error?)->Void)?) {
        
        let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetAppleM4A)
        // 导出地址
        assetExport?.outputURL = exportUrl
        // 导出格式
        assetExport?.outputFileType = .m4a
        // 导出参数
        assetExport?.audioMix = backAudioMix
        // 导出回调
        assetExport?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                switch assetExport?.status {
                case .failed:
                    completed?(NSError(domain: "音频合成失败", code: 404, userInfo: nil))
                    break
                case .cancelled:
                    completed?(NSError(domain: "音频合成已取消", code: 403, userInfo: nil))
                    break
                case .completed:
                    completed?(nil)
                    break
                default:
                    completed?(NSError(domain: "音频合成未知错误", code: 500, userInfo: nil))
                    break
                }
            }
        })
    }
}
