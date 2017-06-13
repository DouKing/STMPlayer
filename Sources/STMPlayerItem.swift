//
//  STMPlayerItem.swift
//  STMPlayer
//
//  Created by iosci on 2017/6/12.
//  Copyright © 2017年 secoo. All rights reserved.
//

import UIKit
import AVFoundation

open class STMPlayerItem: NSObject {

  var playURL: URL? {
    didSet {
      resetAsset()
    }
  }

  var playerAsset: AVAsset? {
    didSet {
      resetPlayerItem()
    }
  }

  var playerItem: AVPlayerItem? {
    didSet {
      if playerItem == oldValue { return }
      guard let block = playerItemDidChange else { return }
      block(oldValue)
    }
  }

  var playerItemDidChange: ((AVPlayerItem?) -> ())?

  //MARK: - Private -

  private func resetAsset() {
    guard let url = self.playURL else {
      playerAsset = nil
      return
    }
    playerAsset = AVAsset(url: url)
  }

  private func resetPlayerItem() {
    let oldAsset = playerItem?.asset
    if let oa = oldAsset as? AVURLAsset,
      let na = playerAsset as? AVURLAsset {
      if oa.url == na.url {
        return
      }
    }

    guard let asset = playerAsset else {
      playerItem = nil
      return
    }
    playerItem = AVPlayerItem(asset: asset)
  }
}
