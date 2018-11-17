
//
//  DownloaderKits.swift
//  OperationQueuesDownload
//
//  Created by cxz on 2018/11/17.
//  Copyright © 2018年 cxz. All rights reserved.
//

import UIKit

///默认下载保存地址
public let default_locate_path = NSHomeDirectory() + "/Documents" + "/default_download"

public func CCDebugprint(_ items: Any...) {
    debugPrint("Thread:\(Thread.current) --- \(items)")
}
