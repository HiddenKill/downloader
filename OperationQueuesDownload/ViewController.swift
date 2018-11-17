//
//  ViewController.swift
//  OperationQueuesDownload
//
//  Created by cxz on 2018/11/15.
//  Copyright © 2018年 cxz. All rights reserved.
//

import UIKit
import Alamofire
//http://www.w3school.com.cn/example/html5/mov_bbb.mp4
//http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4
let test_video_download_uri = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"

let test_image_download_uri = "http://image.baidu.com/search/down?tn=download&ipn=dwnl&word=download&ie=utf8&fr=result&url=http%3A%2F%2Fpic14.nipic.com%2F20110605%2F1369025_165540642000_2.jpg&thumburl=http%3A%2F%2Fimg3.imgtn.bdimg.com%2Fit%2Fu%3D2200166214%2C500725521%26fm%3D26%26gp%3D0.jpg"

let test_huge_video_download_uri = "http://ultravideo.cs.tut.fi/video/Beauty_1920x1080_120fps_420_8bit_YUV_RAW.7z"

public let SCREEN_WIDTH = UIScreen.main.bounds.size.width
public let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

class ViewController: UIViewController {
    
    private var request: DownloadRequest?
    
    /// progress
    lazy private var progress: UIProgressView = {
        let p = UIProgressView.init(progressViewStyle: .default)
        p.frame = CGRect.init(x: 20, y: 200, width: SCREEN_WIDTH-40, height: 5)
        p.trackTintColor = .black
        p.progressTintColor = .red
        return p
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = SCREEN_WIDTH/3
        let leading = SCREEN_WIDTH/6
        
        let resume = UIButton(type: .custom)
        resume.setTitle("开始", for: .normal)
        resume.setTitleColor(.black, for: .normal)
        resume.addTarget(self, action: #selector(startTouchEvent(_:)), for: .touchUpInside)
        resume.frame = CGRect.init(x: leading, y: 100, width: width, height: 50)
        self.view.addSubview(resume)
        
        let pause = UIButton(type: .custom)
        pause.setTitle("暂停", for: .normal)
        pause.setTitleColor(.black, for: .normal)
        pause.setTitle("继续", for: .selected)
        pause.setTitleColor(.black, for: .selected)
        pause.addTarget(self, action: #selector(pauseOrResumeTouchEvent(_:)), for: .touchUpInside)
        pause.frame = CGRect.init(x: SCREEN_WIDTH-leading-width, y: 100, width: width, height: 50)
        self.view.addSubview(pause)
        
        self.view.addSubview(self.progress)
        
        Downloader.shared.downloadProgressCallback = {[weak self] (p, c, t) in
            debugPrint(p)
            self?.progress.progress = Float(p)
        }
        
        Downloader.shared.completedCallback = {[weak self] (d, uri, error) in
            
        }
        
    }
    
    @objc private func startTouchEvent(_ sender: UIButton) -> Void {
        self.request = Downloader.shared.download(test_video_download_uri)
    }
    
    @objc private func pauseOrResumeTouchEvent(_ sender: UIButton) -> Void {
        guard let r = self.request else {
            debugPrint("当前暂无下载任务")
            return
        }
        if sender.isSelected {
            let config = DownloadConfig(test_video_download_uri)
            guard let request = Downloader.shared.resume(config) else {
                return
            }
            self.request = request
        } else {
            Downloader.shared.cancel(r)
        }
        sender.isSelected = !sender.isSelected
    }
}

