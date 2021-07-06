//
//  DGVoiceBGMList_Tc.swift
//  SwiftDemos
//  背景音乐下载 Cell
//  Created by 开十二 on 2021/7/7.
//

import UIKit

class DGVoiceBGMList_Tc: UITableViewCell {

    @IBOutlet weak var mMainView: UIView!
    @IBOutlet weak var mImgAvatar: UIImageView!
    @IBOutlet weak var mLabVoiceName: UILabel!
    @IBOutlet weak var mLabVoiceTime: UILabel!
    @IBOutlet weak var mImgDoneLogo: UIImageView!
    
    var model : DGVoiceMixFileModel! {
        didSet {
            guard let model = model else { return  }
            mLabVoiceName.text = model.voiceTitle
            mLabVoiceTime.text = "\(model.voiceTime ?? 0)"
            if model.localVoicePath != nil && model.localVoicePath != "" {
                mImgDoneLogo.isHidden = false
            } else {
                mImgDoneLogo.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mMainView.layer.shadowColor = UIColor(hex: "000000", alpha: 0.3).cgColor
        mMainView.layer.shadowOffset = CGSize(width: 3, height: 3)
        mMainView.layer.shadowRadius = 15
        mMainView.layer.shadowOpacity = 0.3
        mMainView.layer.cornerRadius = 15
        
    }

}
