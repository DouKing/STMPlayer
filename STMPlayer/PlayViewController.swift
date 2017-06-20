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
  @IBOutlet weak var bufferProgressView: UIProgressView!
  @IBOutlet weak var playProgressView: UIProgressView!
  @IBOutlet weak var rateLabel: UILabel!
  
  var shouldPlay: Bool = false

  var player: STMPlayer

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    player = STMPlayer()
    player.item.playURL = URL(string: "https://pic12.secooimg.com/video/siku1205.mp4")
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    player = STMPlayer()
    player.item.playURL = URL(string: "https://pic12.secooimg.com/video/siku1205.mp4")
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    player.delegate = self
    bgView.addSubview(player.view)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if shouldPlay {
      player.play()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    shouldPlay = player.isPlaying
    player.pause()
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

extension PlayViewController: STMPlayerDelegate {
  func player(didChangeStatus player: STMPlayer) {
    debugPrint("status: \(player.status)")
  }

  func player(didReceiveTotalDuration player: STMPlayer) {
    debugPrint("total: \(String(describing: player.totalDuration))")
  }

  func player(didUpdateTotalBuffer player: STMPlayer) {
    debugPrint("buffer: \(String(describing: player.totalBuffer))")
    bufferProgressView.setProgress(Float(player.bufferRate ?? 0), animated: true)
    updateProgress()
  }

  func player(didUpdateCurrentDuration player: STMPlayer) {
    debugPrint("current: \(String(describing: player.currentDuration))")
    playProgressView.setProgress(Float(player.playRate ?? 0), animated: true)
    updateProgress()
  }

  private func updateProgress() {
    let curr = String(format: "%.2f", player.currentDuration ?? 0)
    let buffer = String(format: "%.2f", player.totalBuffer ?? 0)
    let content = "\(curr)/\(buffer)"
    rateLabel.text = content
  }
}
