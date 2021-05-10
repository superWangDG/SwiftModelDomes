//
//  AudioPlayerEditVC.swift
//  SwiftDemos
//
//  Created by 开十二 on 2021/4/23.
//

import UIKit

class AudioPlayerEditVC: UIViewController,WQAudioEditPlayDelegate {
    
    func playProgress(tool: WQAudioEditPlay, currentframe: Int64, totalFrame: Int64, currentRate: Double) {
        print("")
    }
    
    func playFinish(tool: WQAudioEditPlay) {
        print("")
    }
    
    var mBtnSave:UIButton! = {
        let button = UIButton(type: .system)
        button.setTitle("保存", for: .normal)
        button.frame = CGRect(x: 80, y: 120, width: 90, height: 40)
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return button
    }()
    
    var editActionTool:WQAudioEditAction!
    var editPlay:WQAudioEditPlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
//        let fileUrl = Bundle.main.url(forResource: "test", withExtension: "caf")
//        let fileUrl = Bundle.main.url(forResource: "1619080963120recordVoice", withExtension: "mp3")
        let fileUrl = Bundle.main.url(forResource: "1617772572256recordVoice", withExtension: "mp3")
        
        self.editActionTool = WQAudioEditAction.createActionTool(fileUrl: fileUrl!)
        self.editPlay = WQAudioEditPlay.createPlayTool(editActionTool: self.editActionTool!)
        self.editPlay.delegate = self
        
        self.editActionTool.cutAction(firstFrame: 10161900/3, endFrame: 10161900/2)
        self.editActionTool.pasteAction(locFrame: 100000)
        
        view.addSubview(mBtnSave)
        
    }
    
    @objc func saveAction() {
        let save = WQAudioSaveTool.createSaveTool(editPlay: self.editPlay, fileUrl: self.filePath(), actionTool: self.editActionTool)
        save.beginSave()
    }

    
    func filePath() -> String {
        let documentsFolders = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let fileName = "/save.caf"
        let path = documentsFolders?.appending(fileName)
        return (path ?? "") as String
    }

    
    
    
}
