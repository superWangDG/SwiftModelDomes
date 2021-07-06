//
//  DGVoiceBGMList_Vc.swift
//  SwiftDemos
//
//  Created by 开十二 on 2021/7/7.
//

import UIKit

class DGVoiceBGMList_Vc: UIViewController {

    /// 数据集合
    private var mDataList:[DGVoiceMixFileModel] = []
    /// Cell ID
    private let VoiceBGMList_Tc = "DGVoiceBGMList_Tc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "选择背景音乐"
        
        view.addSubview(mTableView)
        
        mTableView.frame = view.bounds
        
        getListData()
    }
    
    func getListData() {
        mDataList = DGVoiceMixFileManager.default.getPlistData()
        
    }
    
    private lazy var mTableView:UITableView! = {
        let table = UITableView(frame: .zero)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.rowHeight = 60
        table.register(UINib(nibName: VoiceBGMList_Tc, bundle: nil), forCellReuseIdentifier: VoiceBGMList_Tc)
        return table
    }()

}


extension DGVoiceBGMList_Vc: UITableViewDelegate,UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VoiceBGMList_Tc) as! DGVoiceBGMList_Tc
        cell.model = mDataList[indexPath.row]
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = mDataList[indexPath.row]
        // 当前model
        if model.localVoicePath != nil && model.localVoicePath != "" {
            // 没有下载到本地的情况（使用音频的网络地址下载音频）
        } else {
            // 当前本地已经存在数据（选中本地的音频前往混音或者合成）
        }
    }
    
}
