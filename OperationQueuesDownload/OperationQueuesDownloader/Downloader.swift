//
//  Downloader.swift
//  OperationQueuesDownload
//
//  Created by cxz on 2018/11/15.
//  Copyright © 2018年 cxz. All rights reserved.
//

import UIKit
import Alamofire
import CryptoSwift

public typealias ProgressCallback = (_ progress: Double, _ completed: Int64, _ total: Int64)->()
public typealias CompletedCallback = (_ data: Data?, _ uri: String?, _ error: Error?)->()

public enum DownloadPolicy: Equatable {
    
    /// 覆盖
    case cover
    
    /// 取消下载
    case cancel
    
    /// 重命名
    case rename(String)
    
    public static func == (lhs: DownloadPolicy, rhs: DownloadPolicy) -> Bool {
        switch (lhs, rhs) {
        case (.cover, .cover): return true
        case (.cancel, .cancel): return true
        case (.rename(let s1), rename(let s2)) where s1 == s2: return true
        case _: return false
        }
    }
}

class Downloader: NSObject {
    
    typealias PauseCallback = (_ resumeData: Data?, _ uri: String?)->()
    
    /// 下载进度回调
    public var downloadProgressCallback: ProgressCallback?
    /// 下载完成后的回调
    public var completedCallback: CompletedCallback?
    //  取消下载回调
    public var cancelCallback: PauseCallback?
    
    private var failsUrl = [String]()
    
    private var resumeDatas: [String: Data?] = Dictionary()
    
    ///进度控制
    private var progressHandler: DownloadRequest.ProgressHandler = {(progress) in
        if Downloader.shared.downloadProgressCallback != nil {
            let completed = progress.completedUnitCount
            let total = progress.totalUnitCount
            let p = Double(completed)/Double(total)
            Downloader.shared.downloadProgressCallback!(p, completed, total)
        }
    }
    
    /// 下载完成后
    private var responseHandler: (DownloadResponse<Data>) -> () = { resp in
        // if judge error firstly, can not get download cancel task
//        if resp.error != nil {
//            debugPrint("\(String(describing: resp.error?.localizedDescription))")
//            return
//        }
        var url: String? = nil
        if resp.request?.url != nil {
            url = resp.request?.url?.absoluteString
        }
        if resp.result.isSuccess {
            if Downloader.shared.completedCallback != nil {
                Downloader.shared.completedCallback!(resp.value, url, resp.error)
            }
        }
        if resp.result.isFailure {
            guard let u = url else {
                /// 当执行完一次request.cancel()，第二次不会返回resp.request.url
                return
            }
            if Downloader.shared.cancelCallback != nil {
                Downloader.shared.cancelCallback!(resp.resumeData, u.md5())
            }
            if Downloader.shared.resumeDatas[u.md5()] != nil {
                debugPrint("resume data have been existed")
            }
            Downloader.shared.resumeDatas[u.md5()] = resp.resumeData
        }
    }
    
    public static var shared: Downloader = Downloader()
    
    //MARK: --- 单资源单线程下载 ---
    
    public func download(_ uri: String) -> DownloadRequest? {
        let config = DownloadConfig.init(uri)
        return self.download(config)
    }
    
    public func download(_ config: DownloadConfig) -> DownloadRequest? {
        guard let uri = config.uri else {
//            CCDebugprint("download uri is empty")
            return nil
        }
        
        let destination = self.joinDownloadDestination(config)
        let request = Alamofire.download(uri, to: destination).downloadProgress(closure: progressHandler).responseData(completionHandler: responseHandler)
        return request
    }

    //暂停
    public func cancel(_ request: DownloadRequest) -> Void {
        request.cancel()
    }

    // 继续下载(当前request不存在时)
    public func resume(_ config: DownloadConfig) -> DownloadRequest? {
        guard let u =  config.uri else {
            debugPrint("download uri empty")
            return nil
        }
        let destination = self.joinDownloadDestination(config)
        guard let d = self.resumeDatas[u.md5()] else {
            return self.download(config)
        }
        guard let data = d else {
            return self.download(config)
        }
        let request = Alamofire.download(resumingWith: data, to: destination).downloadProgress(closure: self.progressHandler).responseData(completionHandler: self.responseHandler)
        return request
    }
}

extension Downloader {
    // 拼接获取完整文件名 fileName + fileType
    private func join4WholeFileName(_ config: DownloadConfig) -> String {
        return config.fileType == nil ? config.fileName : "\(config.fileName).\(config.fileType!)"
    }
    
    // 配置本地存储路径
    private func filePath4DownloadConfig(_ config: DownloadConfig) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(self.join4WholeFileName(config))
        return fileURL
    }
    
    // 配置本地存储Destination
    private func joinDownloadDestination(_ config: DownloadConfig) -> DownloadRequest.DownloadFileDestination {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = self.filePath4DownloadConfig(config)
//            CCDebugprint("save url: \(fileURL.absoluteString)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        return destination
    }
    
    // 判断当前文件是否已经存在
    private func isExisted(_ config: DownloadConfig) -> Bool {
        return FileManager.default.fileExists(atPath: config.locatePath)
    }
    
}
