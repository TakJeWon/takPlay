//
//  ViewController.swift
//  takPlay
//
//  Created by 탁제원 on 4/13/24.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var playbackBtn: UIButton!
    @IBOutlet weak var playerviewBtn: UIButton!
    @IBOutlet weak var videoBackgroundView: UIView!
    
    private var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    @IBAction func onTouchedPlaybackBtn(_ sender: Any) {
        
        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        
        playVideo(url: url!)
        
    }
    
    func playVideo(url: URL){
        
        let playerController = AVPlayerViewController()
        let player = AVPlayer(url: url)
        
        playerController.player = player
        
        self.present(playerController, animated: true) {
            player.play()
        }
    }
    
    @IBAction func onTouchedPlayerViewBtn(_ sender: Any) {
        
        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        
        let item = AVPlayerItem(url: url!)
        self.player.replaceCurrentItem(with: item)
        
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.videoBackgroundView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        self.videoBackgroundView.layer.addSublayer(playerLayer)
        
        self.player.play()
        
        
    }
    

}

