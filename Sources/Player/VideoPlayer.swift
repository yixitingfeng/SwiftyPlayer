//
//  VideoPlayer.swift
//  SwiftyPlayer
//
//  Created by shiwei on 2020/9/28.
//

import AVFoundation
import MediaPlayer

public class VideoPlayer: Player {

    /// 视频播放承载视图的容器 View
    ///
    /// 播放器本身弱引用持有容器 View，避免循环引用
    public weak var videoPlayerView: VideoPlayerView? {
        didSet {
            self.videoPlayerView?.avPlayer = player
        }
    }

    /// 是否支持后台播放
    ///
    /// 对于视频默认不支持后台播放，应用退到后台时自动暂停。
    ///
    /// - Warning: 如果需要后台播放视频，请设置相应的支持后台播放的 category
    public var isBackgroundPlaybackSupported = false

    /// 视频内容拉伸模式
    public var videoGravity: VideoPlayerGravity {
        get {
            guard let videoPlayerView = videoPlayerView
            else {
                return .resizeAspect
            }
            return VideoPlayerGravity(rawValue: videoPlayerView.playerLayer.videoGravity.rawValue)
        }
        set {
            let videoGravity = AVLayerVideoGravity(rawValue: newValue.rawValue)
            videoPlayerView?.playerLayer.videoGravity = videoGravity
        }
    }

    // MARK: Event producers

    let applicationStatus = ApplicationStatusProducer()

    // MARK: Properties

    var stateBeforeEnterBackground: PlayerState?

    override var player: AVPlayer? {
        didSet {
            DispatchQueue.main.safeAsync {
                self.videoPlayerView?.avPlayer = self.player
            }
        }
    }

    public override init() {
        super.init()
        applicationStatus.eventListener = self
        // start application status listener
        applicationStatus.startProducingEvents()
    }

    public override func stop() {
        super.stop()
        applicationStatus.stopProducingEvents()
    }

    public override func onEvent(_ event: Event, generateBy eventProducer: EventProducer) {
        if let event = event as? ApplicationStatusProducer.ApplicationStatusEvent {
            handleApplicationStatusEvent(from: eventProducer, with: event)
        } else {
            super.onEvent(event, generateBy: eventProducer)
        }
    }

    /// 截取播放器指定时间点的画面帧
    ///
    /// - Parameters:
    ///   - time: 指定截取的时间点，默认截取调用方法的时间点
    ///   - completion: 截取的 UIImage 对象
    public func takeScreenshot(at time: TimeInterval? = nil, completion: @escaping (UIImage?) -> Void) {
        guard let player = player,
              let asset = avPlayerItem?.asset
        else {
            completion(nil)
            return
        }
        DispatchQueue.global(qos: .background).async {
            let assetIg = AVAssetImageGenerator(asset: asset)
            assetIg.appliesPreferredTrackTransform = true
            assetIg.apertureMode = .encodedPixels
            let cmTime: CMTime
            if let time = time {
                cmTime = CMTime(timeInterval: time)
            } else {
                cmTime = player.currentTime()
            }
            let thumbnail: CGImage
            do {
                thumbnail = try assetIg.copyCGImage(at: cmTime, actualTime: nil)
            } catch {
                return completion(nil)
            }
            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnail))
            }
        }
    }

}
