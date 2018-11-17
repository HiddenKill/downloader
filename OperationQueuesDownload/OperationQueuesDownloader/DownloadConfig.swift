//
//  DownloadConfig.swift
//  OperationQueuesDownload
//
//  Created by cxz on 2018/11/16.
//  Copyright © 2018年 cxz. All rights reserved.
//

import UIKit
import CommonCrypto


class DownloadConfig: NSObject {
        
    /// 下载地址
    private(set) var uri: String?
    
    /// 本地保存路径
    private(set) var locatePath: String = default_locate_path
    
    /// 未设置则默认为 uri.MD5
    private(set) var fileName: String = ""

    /// 文件类型
    private(set) var fileType: String?
    
    //MARK: --- init ---
    /// return DownloadConfig object
    ///
    /// - Parameters:
    ///   - uri: the download url
    ///   - locatePath: the locate path for saving
    ///   - fileName: the file name
    ///   - fileType: the file type    eg: abc.mp3     fileName == abc   fileType == mp3
    init(_ uri: String, locate: String?, fileName: String?, fileType: String?) {
        super.init()
        self.uri = uri
        self.locatePath = locate ?? default_locate_path
        self.fileName = fileName ?? uri.md5()
        self.fileType = fileType
    }
    
    convenience init(_ uri: String, locate: String) {
        self.init(uri, locate: locate, fileName: nil, fileType: nil)
    }
    
    convenience init(_ uri: String) {
        self.init(uri, locate: default_locate_path)
    }
    
}
