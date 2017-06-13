//
//  STMPlayer.swift
//  STMPlayer
//
//  Created by iosci on 2017/6/12.
//  Copyright © 2017年 secoo. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol STMPlayerDelegate {
  func player(didChangeStatus player: STMPlayer)
}

@objc enum STMPlayerStatus: Int {
  case unknown
  case redayToPlay
  case failed
  case replacingItem
  case finishPlay
}

open class STMPlayer: NSObject {

  //MARK: - Override -

  deinit {
    removeProgressObserver()
    removeObserver(for: item.playerItem)
  }

  //MARK: - Public -

  var delegate: STMPlayerDelegate?

  var status: STMPlayerStatus = .unknown {
    didSet {
      delegate?.player(didChangeStatus: self)
    }
  }

  var totalBuffer: Double?
  var totalDuration: Double?
  var currentSeconds: Double?

  var playRate: Double? {
    guard let total = totalDuration, let current = currentSeconds else { return nil }
    if total.isNaN || current.isNaN {
      return nil
    }
    if total == 0 {
      return 0
    }
    return current / total
  }

  var bufferRate: Double? {
    guard let total = totalDuration, let buffer = totalBuffer else { return nil }
    if total.isNaN || buffer.isNaN {
      return nil
    }
    if total == 0 {
      return 0
    }
    return buffer / total
  }

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
    totalBuffer = nil
    totalDuration = nil
    currentSeconds = nil

    configurePlayer()

    removeObserver(for: oldPlayerItem)
    addObserver(for: item.playerItem)
  }

  private func configurePlayer() {
    if player == nil {
      status = .unknown
      player = AVPlayer(playerItem: item.playerItem)
      addProgressObserver()
      (view.layer as! AVPlayerLayer).player = player
    } else {
      status = .replacingItem
      player?.replaceCurrentItem(with: item.playerItem)
    }
  }

  //MARK: - Observer

  private var timeObserver: Any?
  private func addProgressObserver() {
    timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { [unowned self] (time) in
      let current = time.seconds
      if !current.isNaN {
        self.currentSeconds = current
      }

      guard let playerItem = self.item.playerItem else { return }
      let total = playerItem.duration.seconds
      if self.totalDuration == nil {
        if !total.isNaN {
          self.totalDuration = total
        }
      }

      if let currRate = self.playRate, currRate >= 1 {
        self.playbackFinish()
      }
    }
  }

  private func removeProgressObserver() {
    if let observer = timeObserver {
      player?.removeTimeObserver(observer)
    }
  }

  private func playbackFinish() {
    status = .finishPlay
  }
}

extension STMPlayer {
  private var itemStatus: String {
    return "status"
  }
  private var itemLoadedTimeRanges: String {
    return "loadedTimeRanges"
  }

  private func addObserver(for playerItem: AVPlayerItem?) {
    playerItem?.addObserver(self, forKeyPath: itemStatus, options: [.new], context: nil)
    playerItem?.addObserver(self, forKeyPath: itemLoadedTimeRanges, options: [.new], context: nil)
  }

  private func removeObserver(for playerItem: AVPlayerItem?) {
    playerItem?.removeObserver(self, forKeyPath: itemStatus)
    playerItem?.removeObserver(self, forKeyPath: itemLoadedTimeRanges)
  }

  override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let kp = keyPath, let playerItem = object as? AVPlayerItem else { return }
    if kp == itemStatus {
      if let status = change?[.newKey] {
        let s = status as! Int
        if s == AVPlayerStatus.readyToPlay.rawValue {
          self.status = .redayToPlay
        } else if s == AVPlayerStatus.unknown.rawValue {
          self.status = .unknown
        } else if s == AVPlayerStatus.failed.rawValue {
          self.status = .failed
        }
      }
    } else if kp == itemLoadedTimeRanges {
      let array = playerItem.loadedTimeRanges
      let timeRange = array.first as! CMTimeRange
      let start = timeRange.start.seconds
      let duration = timeRange.duration.seconds
      totalBuffer = start + duration
    }
  }
}
