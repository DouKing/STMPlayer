//
//  STMPlayerView.swift
//  STMPlayer
//
//  Created by iosci on 2017/6/12.
//  Copyright © 2017年 secoo. All rights reserved.
//

import UIKit
import AVFoundation

open class STMPlayerView: UIView {

  //MARK: - Override -

  override open class var layerClass: Swift.AnyClass {
    return AVPlayerLayer.self
  }

}

open class STMPlayerControlView: UIView {

}

open class STMPlayerNavigationView: UIView {

}
