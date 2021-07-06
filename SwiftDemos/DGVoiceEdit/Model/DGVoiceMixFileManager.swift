//
//  DGVoiceMixFileManager.swift
//  SwiftDemos
//  混音文件操作
//  Created by 开十二 on 2021/7/6.
//

import Foundation
import HandyJSON

/// 背景音频的model
struct DGVoiceMixFileModel:HandyJSON {
    var id:Int!                     // 音频ID
    var voiceTitle:String!          // 音频标题
    var voiceUrl:String!            // 音频网络地址
    var voiceTime:Double!           // 音频播放时长
    var voiceAvatar:String!         // 音频的图片地址
    var localVoicePath:String!      // 音频本地地址
    var localAvatarPath:String!     // 音频图片本地地址
    var addTime:String!             // 音频添加时间
}


class DGVoiceMixFileManager {
    public static var `default` = DGVoiceMixFileManager()
    
//    let bgmDir: String = "bgm"
    private let plistPath = NSTemporaryDirectory().appendingPathComponent("bgm").appendingPathComponent("VoiceMixingBGM.plist")
    
    private init() {
        createPlistFile()
    }
    
    
    /// 得到本地存储的数据
    /// - Returns: 存储的数据列表
    func getPlistData() -> [DGVoiceMixFileModel] {
        let array = NSArray(contentsOfFile: plistPath)
        if array != nil && array?.count ?? 0 > 0 {
            let dics = array as? [[String:Any]] ?? []
            var list:[DGVoiceMixFileModel] = []
            for item in dics {
                list.append(DGVoiceMixFileModel.deserialize(from: item)!)
            }
            return list
        }
        return []
    }
    
    // 创建Plist文件用于存储背景音乐的信息数据
    /// 创建持久化的文件
    func createPlistFile() {
        // 判断file 文件是否存在，如果没有则创建 file目录
        if !FileManager.isExistFile(plistPath,true) {
            do {
                try? NSDictionary().write(to: URL(fileURLWithPath: plistPath))
            }
        }
        print("DGVoiceMixFileManager------------------>创建持久化的BGM存储地址:\(plistPath)")
    }
    
    /// 清除Plist中的所有数据
    func clearAllPlistData() {
        try? NSDictionary().write(to: URL(fileURLWithPath: plistPath))
    }
    
    
    /// 根据ID 更新本地数据(如果本地没有存在的情况会插入数据)
    /// - Parameter model: <#model description#>
    func updateIDWithModel(model:DGVoiceMixFileModel) {
        var array = NSArray(contentsOfFile: plistPath)
        
        if array != nil && array?.count ?? 0 > 0 {
            var newList = [Any]()
            // 内部存在数据
            var isInsert = false
            for item in array! {
                var dic = item as! [String:Any]
                if (dic["id"] as? Int ?? 0) == model.id {
                    // 替换数据
                    dic = model.toJSON() ?? [:]
                    isInsert = true
                }
                newList.append(dic)
            }
            // 如果到这里 没有更新数据 则将数据直接插入
            if isInsert == false {
                newList.append(model.toJSON() ?? [:])
            }
            // 替换集合列表
            array = NSArray(array: newList)
        } else {
            // 内部没有存在数据
            array = NSArray(array: [model.toJSON() ?? [:]] )
        }
        try? array!.write(to: URL(fileURLWithPath: plistPath))
    }
    
    /// 存入背景音乐列表集合
    /// - Parameter list: <#list description#>
    func saveModelList(list:[DGVoiceMixFileModel]) {
        var array = NSArray(contentsOfFile: plistPath)
        var newList = [Any]()
        if array == nil || array?.count == 0 {
            // 没有存储过数据的情况(直接替换)
            array = NSArray(array: list.toJSON() as [Any] )
        } else {
            // 内部已经包含了数据（将数据循环遍历 后判断数据是否存在不存在则插入）
            newList = array as! [Any]
            for item in list.toJSON() {
                // 判断是否之前存在当前的数据   如果存在不操作，不存在执行插入操作
                if  item?["id"] != nil  {
                    // 返回的json 数据的ID
                    let jsonId = item?["id"] as? Int ?? 0
                    // 是否添加到Array
                    var isAppend = false
                    for i in 0 ..< (array?.count ?? 0) {
                        let dic = array?[i] as? [String:Any] ?? [:]
                        // 本地存储的ID
                        let dicId = dic["id"] as? Int ?? 0
                        if jsonId == dicId {
                            // 内部存在相等ID 跳出循环
                            break
                        }
                        if i == (array?.count ?? 0) - 1 {
                            // 完结后没有相同的 ID 添加数据
                            isAppend = true
                        }
                    }
                    // 插入数据
                    if isAppend {
                        newList.append(item!)
                    }
                }
            }
            array = NSArray(array: newList)
        }
        try? array!.write(to: URL(fileURLWithPath: plistPath))
    }

}
