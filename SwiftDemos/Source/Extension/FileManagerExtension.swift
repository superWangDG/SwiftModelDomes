//
//  FileManagerExtension.swift
//  k12campus
//
//  Created by k12 gz on 2020/12/2.
//  Copyright © 2020 k12 gz. All rights reserved.
//

import Foundation
import UIKit
//import Alamofire

extension FileManager {
    ///删除文件
    class func deleteFile(_ path: String) -> Void {
        let manager = FileManager.default
        //        创建一个字符串对象，该字符串对象表示文档目录下的一个文件夹
        //            let baseUrl = NSHomeDirectory() + "/Documents/txtFoldet"
        //        使用文件管理对象，判断文件夹是否存在，并把结果储存在常量中
        let exist = manager.fileExists(atPath: path)
        //        如果文件夹不存在，则执行之后的代码
        if exist
        {
            do{
                //                创建指定位置上的文件夹
                try manager.removeItem(atPath: path)
                print("Succes to delete folder")
            }
            catch{
                print("Error to create folder")
            }
        }
    }
    
    
    ///判断是否存在在文件 isCreat是否创建目录
    class func isExistFile(_ path: String,_ isCreat: Bool = false) -> Bool {
        let manager = FileManager.default
        //        创建一个字符串对象，该字符串对象表示文档目录下的一个文件夹
        //            let baseUrl = NSHomeDirectory() + "/Documents/txtFoldet"
        //        使用文件管理对象，判断文件夹是否存在，并把结果储存在常量中
        let exist = manager.fileExists(atPath: path)
        //        如果文件夹不存在，则执行之后的代码
        if !exist && isCreat {
            //判断是否存在目录
            let dir: String = URL(fileURLWithPath: path).deletingLastPathComponent().path
            if  manager.fileExists(atPath: dir) == false {
                createDir(dir)
            }
        }
        return exist
    }
    
    ///创建目录
    class func createDir(_ path: String) -> Void {
        let manager = FileManager.default
        do{
            //                创建指定位置上的文件夹
            try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            print("Succes to create folder")
        }
        catch{
            print("Error to create folder")
        }
    }
    
    // 存储文件
//    @discardableResult // 可不声明返回结果
//    func saveFileWithDataOrImage(path:String,obj:Any?) -> Data? {
//        if URL(string: path) == nil {
//            return nil
//        }
//        // 获取URL 文件的名称
//        var pathName = NSString(string: path).lastPathComponent
//        let pathSuffix = pathName.components(separatedBy: ".").last?.uppercased()
//        // 存储的路径
//        var savePath = ""
//        var saveData:Data?
//        
//        if pathSuffix == "JPG" || pathSuffix == "PNG" || pathSuffix == "GIF"{
//            // 存储图片
//            savePath = save_images_path
//            
//            if obj != nil {
//                if obj is UIImage {
//                    saveData = (obj as! UIImage).jpegData(compressionQuality: 1)
//                } else {
//                    saveData = (obj as! Data)
//                }
//            }
//        }
//        else if pathSuffix == "MP4" {
//            // 存储视频
//            if obj is UIImage || obj == nil {
//                // 属于视频但是传入的是 UIImage 对象则为 视频的第一帧预览
//                savePath = save_video_preview_path
//                if obj != nil {
//                    saveData = (obj as! UIImage).jpegData(compressionQuality: 1)
//                }
//                // 将后缀改为 图片类型
//                pathName = "\(pathName.components(separatedBy: ".").first!).jpg"
//                
//            } else {
//                savePath = save_video_path
//                // 存入视频文件
//                if obj != nil && obj is Data {
//                    saveData = (obj as! Data)
//                }
//            }
//        }
//        else if pathSuffix == "MP3" {
//            savePath = save_voice_mp3_path
//            // 存入视频文件
//            if obj != nil && obj is Data  {
//                saveData = (obj as! Data)
//            }
//        }
//        else {
//            print("判断存储路径失败")
//        }
//        // 保存的地址添加文件名
//        savePath = savePath.appendingPathComponent(pathName)
//        // 判断并创建文件夹
//        if !FileManager.isExistFile(savePath, true) {
//            if saveData != nil {
//                do {
//                    try saveData?.write(to: URL(fileURLWithPath: savePath))
//                    
//                    print("保存当前文件成功:\(NSString(string: savePath).lastPathComponent)")
//                } catch {
//                    print("文件保存出错")
//                    return nil
//                }
//            } else {
//                return nil
//            }
//        } else {
//            // 存在文件取出文件
//            do {
//                return try Data(contentsOf: URL(fileURLWithPath: savePath))
//            } catch {
//                print("文件读取出错")
//                return nil
//            }
//        }
//        return nil
//    }
//   
}
