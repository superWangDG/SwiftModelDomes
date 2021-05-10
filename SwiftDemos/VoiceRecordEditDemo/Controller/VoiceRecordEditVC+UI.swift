//
//  VoiceRecordEditVC+UI.swift
//  SwiftDemos
//  录音编辑页面 UI
//  Created by 开十二 on 2020/12/14.
//

import UIKit

extension VoiceRecordEditVC {

    func setupUI() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.mEditBackMainView)
        self.mEditBackMainView.addSubview(self.mLabShowTime)
        
        self.mEditBackMainView.addSubview(self.mBottomToolsView)
        self.mBottomToolsView.addSubview(self.mBtnNarrow)
        self.mBottomToolsView.addSubview(self.mBtnPlay)
        self.mBottomToolsView.addSubview(self.mBtnEdit)
        
        self.mEditBackMainView.addSubview(self.mVoiceScrollView)
        self.mVoiceScrollView.addSubview(self.mVoiceEditTop)
        self.mVoiceScrollView.addSubview(self.mContentEditView)
        self.mContentEditView.addSubview(self.mCSoundSpectrumView)
        
        self.mVoiceScrollView.addSubview(self.mVoiceEditTop)
        
        self.view.addSubview(self.mBtnClose)
        
        // 内容视图
        self.mVoiceScrollView.contentSize = CGSize(width: self.mContentEditView.frame.size.width, height: self.mVoiceScrollView.frame.size.height)
        
        
    }
    
    /// 创建标线视图
    /// - Parameter rootView: <#rootView description#>
    func createMarkingView(rootView : UIView) {
        
        // 使用最长可录制的秒数
        for i in 0 ..< currentRecordSecond {
            // 间隔的主视图
            let intervalView = UIView()
            intervalView.frame = CGRect(x: i * interval, y: 0, width: interval, height: 25)
            rootView.addSubview(intervalView)
            
            let centerLine = UIView()
            centerLine.backgroundColor = UIColor(red: 198 / 255.0, green: 201 / 255.0, blue: 211 / 255.0, alpha: 1)
            centerLine.frame = CGRect(x: intervalView.frame.size.width / 2.0 - 0.25, y: intervalView.frame.size.height - 9, width: 0.5, height: 9)
            intervalView.addSubview(centerLine)
            
            let lastLine = UIView()
            lastLine.backgroundColor = centerLine.backgroundColor
            lastLine.frame = CGRect(x: intervalView.frame.size.width - 0.5, y: centerLine.frame.origin.y, width: centerLine.frame.size.width, height: centerLine.frame.size.height)
            intervalView.addSubview(lastLine)
            
            // 添加当前的标题 (当最后一个时文字在最右侧)
            var timeX = lastLine.center.x - (25)
            var textAlignment = NSTextAlignment.center
            if i == currentRecordSecond - 1 {
                timeX = intervalView.frame.size.width - 50
                textAlignment = .right
            }
            
            let labTime = UILabel(frame: CGRect(x:timeX , y: 0, width: 50, height: 10))
            labTime.text = self.getDoubleWithToTimeMinute(second: Double(i + 1))
            labTime.textColor = centerLine.backgroundColor
            labTime.textAlignment = textAlignment
            labTime.font = UIFont.systemFont(ofSize: 11)
            intervalView.addSubview(labTime)
        }
            
    }
    
    /// 清除标线中的视图
    func clearCreateMarkingView() {
        for view in self.mVoiceEditTop.subviews {
            view.removeFromSuperview()
        }
    }
}
