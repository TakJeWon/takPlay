//
//  player.swift
//  takPlay
//
//  Created by 탁제원 on 4/15/24.
//

import UIKit
import AVKit

class PlayerViewController: UIViewController  {
    
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playSlider: UISlider!
    
    @IBOutlet weak var playerView: UIView!
    private var player = AVPlayer()
    
    var playUrl: URL?
    
    
    override func viewDidLoad() {
        self.viewDidLoad()
        
        settingView()
        playVideo()
    }
    
    func settingView(){
        self.playSlider.setValue(0, animated: false)
    }
    
    func playVideo(){
        playUrl = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        
        let item = AVPlayerItem(url: playUrl!)
        self.player.replaceCurrentItem(with: item)
        
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.playerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        self.playerView.layer.addSublayer(playerLayer)
        
        self.player.play()
        
        if (self.player.currentItem?.status == .readyToPlay){
            self.playSlider.minimumValue = 0
            self.playSlider.maximumValue = Float(CMTimeGetSeconds(item.duration))
            
            print("maximumValue : \(Float(CMTimeGetSeconds(item.duration)))")
        }
        
        self.playSlider.addTarget(self, action: #selector(changeValue), for: .valueChanged)
        
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] elapsedSeconds in
            let elapsedTimeSecondsFloat = CMTimeGetSeconds(elapsedSeconds)
            let totalTimeSecondsFloat = CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
            print(elapsedTimeSecondsFloat, totalTimeSecondsFloat)
        })
    }
    
    
    @objc private func changeValue(){
        self.player.seek(to: CMTime(seconds: Double(self.playSlider.value), preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { _ in
            
        })
    }
}
