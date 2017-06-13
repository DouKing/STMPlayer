//
//  STMPlayer.swift
//  STMPlayer
//
//  Created by iosci on 2017/6/12.
//  Copyright © 2017年 secoo. All rights reserved.
//

import UIKit
import AVFoundation

open class STMPlayer: NSObject {

  //MARK: - Override -

  deinit {
    removeProgressObserver()
    removeObserver(for: item.playerItem)
  }

  //MARK: - Public -

  lazy var view: STMPlayerView = {
    return STMPlayerView()
  }()

  lazy var item: STMPlayerItem = {
    let i = STMPlayerItem()
    i.playerItemDidChange = { [unowned self] (oldItem) in
      self.resetPlayer(oldItem)
    }
    return i
  }()

  func play() {
    player?.play()
  }

  func pause() {
    player?.pause()
  }

  //MARK: - Private -

  private var player: AVPlayer?

  private func resetPlayer(_ oldPlayerItem: AVPlayerItem?) {
    if player == nil {
      player = AVPlayer(playerItem: item.playerItem)
      addProgressObserver()
      (view.layer as! AVPlayerLayer).player = player
    } else {
      player?.replaceCurrentItem(with: item.playerItem)
      debugPrint("replace playItem")
    }
    removeObserver(for: oldPlayerItem)
    addObserver(for: item.playerItem)
  }

  //MARK: - Observer

  private var timeObserver: Any?
  private func addProgressObserver() {
    timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { [unowned self] (time) in
      let current = time.seconds
      guard let playerItem = self.item.playerItem else { return }
      let total = playerItem.duration.seconds
      let rate = Float(current / total)
      debugPrint(current, total, rate)
      if rate >= 1 {
        self.playbackFinish()
      }
    }
  }

  private func removeProgressObserver() {
    if let observer = timeObserver {
      player?.removeTimeObserver(observer)
    }
  }

  let status = "status"
  let loadedTimeRanges = "loadedTimeRanges"

  private func addObserver(for playerItem: AVPlayerItem?) {
    playerItem?.addObserver(self, forKeyPath: status, options: [.new], context: nil)
    playerItem?.addObserver(self, forKeyPath: loadedTimeRanges, options: [.new], context: nil)
  }

  private func removeObserver(for playerItem: AVPlayerItem?) {
    playerItem?.removeObserver(self, forKeyPath: status)
    playerItem?.removeObserver(self, forKeyPath: loadedTimeRanges)
  }

  override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let kp = keyPath, let playerItem = object as? AVPlayerItem else { return }
    if kp == status {
      if let status = change?[.newKey] {
        let s = status as! Int
        if s == AVPlayerStatus.readyToPlay.rawValue {
          debugPrint("开始播放")
        }
      }
    } else if kp == loadedTimeRanges {
      let array = playerItem.loadedTimeRanges
      let timeRange = array.first as! CMTimeRange
      let start = timeRange.start.seconds
      let duration = timeRange.duration.seconds
      let totalBuffer = start + duration
      debugPrint("total buffer: \(totalBuffer)")
    }
  }

  private func playbackFinish() {
    debugPrint("视频播放完成")
  }
}
