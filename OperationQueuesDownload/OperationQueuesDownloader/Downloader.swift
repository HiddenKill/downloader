//
//  Downloader.swift
//  OperationQueuesDownload
//
//  Created by cxz on 2018/11/15.
//  Copyright © 2018年 cxz. All rights reserved.
//

import UIKit
import Alamofire

public typealias ProgressCallback = (_ progress: Double, _ completed: Int64, _ total: Int64)->()
public typealias CompletedCallback = (_ data: Data?, _ uri: String)->()

class Downloader: NSObject {
    
    public var downloadProgressCallback: ProgressCallback?
    public var completedCallback: CompletedCallback?
    
    private var failsUrl = [String]()
    
    /// destination
    private var destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("pig.png")
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    
    public static func download(_ uri: String) -> Void {
        let request = Alamofire.download(uri).response { (resp) in
            debugPrint("download over")
            }.downloadProgress { (p) in
                debugPrint("\(p.completedUnitCount)")
        }
        request.responseData { (resp) in
            debugPrint("resp")
        }
    }
    
    public static func download(_ config: DownloadConfig) -> Void {
        guard let uri = config.uri else {
            debugPrint("当前url不存在")
            return
        }
        
        Alamofire.download(uri).responseData { (resp) in
            if resp.error != nil {
                debugPrint("\(resp.error.debugDescription)")
                return
            }
            guard let data = resp.value else {
                debugPrint("empty data")
                return
            }
        }
    }
}
