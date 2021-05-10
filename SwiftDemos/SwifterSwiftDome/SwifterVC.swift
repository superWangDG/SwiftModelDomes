//
//  SwifterVC.swift
//  SwiftDemos
//  SwifterSwiftDome
//  Created by 开十二 on 2020/12/29.
//

import UIKit
import SwifterSwift

class SwifterVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK:- Date的部分处理功能
        print("date转为String:\(Date().string(withFormat: "yyyy年MM月dd日 HH:mm:ss"))")
        
        let oldDate = Date(timeIntervalSince1970: 1608435787)
        let otherDate = Date(timeIntervalSince1970: 1608781387)
        print("使用测试的固定时间:\(oldDate.string(withFormat: "yyyy年MM月dd日 HH:mm:ss"))")
        
        print("得到当前的年:\(Date().year),得到当前的月:\(Date().month),得到当前的日:\(Date().day)")
        
        print("得到当前的小时:\(Date().hour),得到当前的分:\(Date().minute),得到当前的秒:\(Date().second)")
        
        print("检查当前日期是否为未来的日期:\(Date().isInFuture),检查当前日期是否为过去的日期:\(Date().isInPast),检查当前日期是否为当天的日期:\(Date().isInToday),检查当前日期是否为昨天以内:\(Date().isInYesterday),检查当前日期是否为明天以内:\(Date().isInTomorrow),检查当前日期是否为本周以内:\(Date().isInWeekend),检查当前日期是否为在工作日以内:\(Date().isWorkday),检查当前日期是否为在当前所在的这个星期以内:\(Date().isInCurrentWeek),检查当前日期是否为在当前所在的这个月份以内:\(Date().isInCurrentMonth),检查当前日期是否为在当前所在的这个年以内:\(Date().isInCurrentYear)")
        let secodsSince = Date().secondsSince(oldDate)
        let minutesSince = Date().minutesSince(oldDate)
        let hoursSince = Date().hoursSince(oldDate)
        let daysSince = Date().daysSince(oldDate)
        print("当前时间与测试时间相差的秒数:\(secodsSince),当前时间与测试时间相差的分钟数:\(minutesSince),当前时间与测试时间相差的小时数:\(hoursSince),当前时间与测试时间相差的天数:\(daysSince)")
        let isBetween = Date().isBetween(oldDate, otherDate, includeBounds: false)
        print("使用当前时间判断是否在时间之前\(isBetween)")
        //MARK:- FileManager的部分处理功能
        
        // 创建临时文件存储
        do {
            let temURL = try FileManager.default.createTemporaryDirectory()
            print("创建临时文件路径:\(temURL.absoluteString)")
        } catch  {
            
        }
        
        //MARK:- Data的部分处理功能
        //Data().string(encoding: .utf8)    data类型转 utf8 的字符串类型
        
        //MARK:- NSAttributedString的部分处理功能
        let asContent = NSAttributedString(string: "test")
        // 使用系统并加粗字体
        let boldContent = asContent.bolded
        // 添加划线
        let underLined = asContent.underlined
        // 使用系统字体并且倾斜
        let italicized = asContent.italicized
        // 添加删除线
        let struckthrough = asContent.struckthrough
        // 修改 NSAttributedString 的字典属性
//        asContent.attributes = [.foregroundColor:UIColor.yellow]
//        asContent.applying(attributes: <#T##[NSAttributedString.Key : Any]#>, toRangesMatching: <#T##String#>)
        // 改变颜色
        asContent.colored(with: .red)
//        k12campusiOS:///parent/CXMyRecitationDetail_Vc/5
        //MARK:- URL的部分处理功能
        var testURL = URL(string: "https://help.aliyun.com/knowledge_detail/39522.html?spm=a2c4g.11186623.2.12.66df65362tedZB") // 接入SwifterSwift 后初始化 如果失败 返回的结果会为 nil
        let param = testURL?.queryParameters // 将URL 请求的地址转为本地的字典类型
        testURL?.appendQueryParameters(["userkey":"new"])   // 将新的参数插入 URL中
        testURL?.queryValue(for: "userKey") // 查询url中指定Key 的Value
        testURL?.deletingAllPathComponents()    // 只显示 url 地址前面的域名
        testURL?.droppedScheme() //生成没有 http 的地址
        testURL?.thumbnail() // 获取地址 视频文件的 首帧图片（带参可获得指定的帧时图片） 使用时属于耗时请求  需要放在子线程中操作
        
        //MARK:- UserDefaults中所有的 操作进行了 扩展封装
        
        //MARK:- UIAlertController
        let alert = UIAlertController(title: "标题", message: "内容名", defaultActionButtonTitle: "确认", tintColor: .red)
        alert.addAction(title: "关闭") { (action) in
            
        }
        alert.addTextField(text: "", placeholder: "卧槽Text的输入框", editingChangedTarget: nil, editingChangedSelector: #selector(valueChange))
        alert.show()
        
        //MARK:- UIAlertController
        let inferredEnvironment = UIApplication.shared.inferredEnvironment  // 当前app运行的环境
        UIApplication.shared.displayName    // 获取当前App的名称
        UIApplication.shared.buildNumber    // 获取App的构建版本号
        UIApplication.shared.version        // 获取App当前的版本号
        
        
        
    }
    
    
    
    
    @objc func valueChange(text:UITextField) {
        
    }
}
