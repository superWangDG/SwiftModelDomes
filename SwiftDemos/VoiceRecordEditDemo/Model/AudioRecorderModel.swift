//
//  AudioRecorderModel.swift
//  SwiftDemos
//  录音机的封装
//  Created by 开十二 on 2020/12/14.
//

import Foundation
import UIKit
import AVFoundation


let save_ready_recorder_path = NSTemporaryDirectory() + "/recorder/tmp"



class AudioRecorderModel : NSObject, AVAudioRecorderDelegate {
    
    var _audioRecorder:AVAudioRecorder?
    var voiceFileName = ""              // 录音文件存在地址
    var volumeChangeState = 0           // 音量等级
    var currentTime = 0.0               // 当前录音的时长
    var timerGCD : DispatchSourceTimer?
    /// 播放的状态 0:完成或未录音的状态 1:正在录音的状态 2:录音暂停的状态
    var playState = 0
    var mCurrentState = [String:Any]()  // 当前录音机的状态
    var volumeLevelList = [Int]()       // 录音分贝的等级状态
    var audioStateChangeBlock:((_ error:Error?,_ obj:[String:Any]?)->Void)? // 录音状态变更回调
    
    
    /// 装载录音机
    func setupVoice() {
        
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let millisecond = "\(CLongLong(round(timeInterval*1000)))"
        let file_name = "audio_recorder_\(millisecond).caf"   // 文件名后添加时间戳
        voiceFileName = file_name
        
        // 文件存储的路径
        let file_url = URL(string: NSString(string: save_ready_recorder_path).appendingPathComponent(file_name))
        print("AudioRecorderModel----------------------------->录音存储位置:\(save_ready_recorder_path)")
        
        self.mCurrentState["localPath"] = file_url!.absoluteString
        
        // 创建音频文件存储路径
        if !FileManager.isExistFile(file_url!.absoluteString,true) {
            let settings: [String: Any] = [
                AVFormatIDKey:NSNumber(value:kAudioFormatLinearPCM), // 编码格式
                AVSampleRateKey:NSNumber(value:441000),              // 采样率
                AVNumberOfChannelsKey:NSNumber(value:1),            // 通道数
                AVLinearPCMBitDepthKey:NSNumber(value: 16),         // 采集位数
                AVEncoderAudioQualityKey:NSNumber(value:(AVAudioQuality.min.rawValue))
            ]
            do{
                _audioRecorder = try AVAudioRecorder(url: file_url!, settings: settings)
                _audioRecorder?.isMeteringEnabled = true
                _audioRecorder?.delegate = self
                // 此处设置了 智能够使用录音机的声音
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            }
            catch {
                self.setBlock(error: error, obj: nil)
                print("AudioRecorderModel----------------------------->录音界面创建录音机失败:\(error)")
            }
        } else {
            let err = NSError(domain: "创建录音存储文件失败", code: 0, userInfo: nil)
            self.setBlock(error: err, obj: nil)
        
        }
    }
    
    
    /// 开启录音
    func startRecordWithAudio() {
        if self._audioRecorder == nil {
            return
        }
        print("AudioRecorderModel----------------------------->开始录音")
        self._audioRecorder?.prepareToRecord()
        self._audioRecorder?.record()
        
        // 开启定时器获取分贝 设置 0.2秒获取相关数据
        self.timerGCD = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timerGCD?.schedule(deadline: DispatchTime.now(), repeating: .milliseconds(200), leeway: .milliseconds(10))
        ///执行timer
        self.timerGCD?.setEventHandler(handler: {
            [weak self] in
            DispatchQueue.main.sync {
                if self?._audioRecorder == nil { 
                    self?.timerGCD?.cancel()
                    return
                }
                self?.levelTimerCallback()
            }
        })
        ///执行timer
        self.timerGCD?.resume()
    }
    
    
    /// 获取分贝以及计算 分贝的等级
    /// - Parameter timer: <#timer description#>
    @objc func levelTimerCallback() {
        // 播放器不存在时与 播放的状态不是正在播放时 不再进行之后的操作
        if self._audioRecorder == nil || self.playState != 1 {
            return
        }
        
        self.currentTime = Double(self._audioRecorder!.currentTime)
        
        // 刷新分贝数据
        self._audioRecorder?.updateMeters()
        // 获取分贝 大部分为 0-1之间
        let lowPassResults = pow(10, (0.05 * (self._audioRecorder?.peakPower(forChannel: 0))!))
        
        // 区分分贝等级 (因为需求 暂时分为四个等级)
        var lastVolume = 0
        if lowPassResults >= 0.067 && lowPassResults <= 0.267{
            lastVolume = 1
        }
        else if lowPassResults >= 0.267 && lowPassResults <= 0.48  {
            lastVolume = 2
        }
        else if  lowPassResults > 0.48 {
            lastVolume = 3
        }
        self.volumeChangeState = lastVolume
        self.volumeLevelList.append(lastVolume)
        self.mCurrentState["volumeLevels"] = self.volumeLevelList
        self.mCurrentState["currentTime"] = self.currentTime
        self.setBlock(error: nil, obj: self.mCurrentState)
    }
    
    
    /// 开始录音
    func playRecorderAudio() {
        if self._audioRecorder?.isRecording == false {
            // 必须为没有在录音的状态
            self.playState = 1
            self.startRecordWithAudio()
            self.mCurrentState["state"] = self.playState
            self.setBlock(error: nil, obj: self.mCurrentState)
        } else {
            self.pauseRecorderAudio()
        }
    }
    
    /// 暂停录音
    func pauseRecorderAudio() {
        self.playState = 2
        self._audioRecorder?.pause()
        self.mCurrentState["state"] = self.playState
        self.setBlock(error: nil, obj: self.mCurrentState)
    }
    
    /// 停止录音
    func stopRecorderAudio() {
        self.playState = 0
        self._audioRecorder?.stop()
        self.mCurrentState["state"] = self.playState
        self.setBlock(error: nil, obj: self.mCurrentState)
    }
    
    
    /// 删除保存的录音文件
    func delRecorderAudio() {
        self.timerGCD?.cancel()
        self.timerGCD = nil
        self._audioRecorder?.deleteRecording()
        self.mCurrentState = [String:Any]()
        self.volumeLevelList = []
    }
    
    func setBlock(error:Error?,obj:[String:Any]?) {
        if self.audioStateChangeBlock != nil {
            self.audioStateChangeBlock!(error,obj)
        }
        
        if self.playState == 0 {
            // 如果播放状态回归初始 0 的状态 取消计时器
            self.timerGCD?.cancel()
            self.timerGCD = nil;
        }
    }
    
    /// 录制完成
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.playState = 0
        self.mCurrentState["state"] = self.playState
        self.setBlock(error: nil, obj: self.mCurrentState)
    }
    
    /// 录制发生错误
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        self.playState = 0
        self.setBlock(error: error, obj: nil)
    }
}


