//
//  DownloadConfig.swift
//  OperationQueuesDownload
//
//  Created by cxz on 2018/11/16.
//  Copyright © 2018年 cxz. All rights reserved.
//

import UIKit

public let default_locate_path = NSHomeDirectory() + "/Documents" + "/default_download"

class DownloadConfig: NSObject {
        
    /// 下载地址
    private(set) var uri: String?
    
    /// 本地保存路径
    private(set) var locatePath: String = default_locate_path
    
    //MARK: --- init ---
    /// return DownloadConfig object
    ///
    /// - Parameters:
    ///   - uri: the download url
    ///   - locatePath: the locate path for saving
    init(_ uri: String, locate: String) {
        super.init()
        self.uri = uri
        self.locatePath = locate
    }
    
    convenience init(_ uri: String) {
        self.init(uri, locate: default_locate_path)
    }
    
}
