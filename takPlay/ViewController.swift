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
    


}

