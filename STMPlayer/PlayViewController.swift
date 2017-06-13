//
//  PlayViewController.swift
//  STMPlayer
//
//  Created by iosci on 2017/6/12.
//  Copyright © 2017年 secoo. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController {

  @IBOutlet weak var bgView: UIView!

  lazy var player: STMPlayer = {
    let p = STMPlayer()
    p.item.playURL = URL(string: "https://pic12.secooimg.com/video/siku1205.mp4")
    return p
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    bgView.addSubview(player.view)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    player.view.frame = bgView.bounds
  }

  @IBAction func play(_ sender: UIButton) {
    player.play()
  }

  @IBAction func pause(_ sender: UIButton) {
    player.pause()
  }

  @IBAction func playList1(_ sender: Any) {
//    player.item.playURL = URL(string: "http://baobab.wdjcdn.com/14573563182394.mp4")
    player.item.playerAsset = AVURLAsset(url: URL(string: "http://baobab.wdjcdn.com/14573563182394.mp4")!)
  }
  
  @IBAction func playList2(_ sender: Any) {
    player.item.playURL = URL(string: "http://baobab.wdjcdn.com/1458625865688ONE.mp4")
  }
  
}
