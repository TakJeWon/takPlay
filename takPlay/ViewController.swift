//
//  ViewController.swift
//  takPlay
//
//  Created by 탁제원 on 4/13/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        Task {
          try await loadAsset()
        }
    }
    
    func loadAsset() async throws{
        print("loadasset!")
        let asset = AVAsset(url: URL(string: "https://gist.github.com/SeunghoonBaek/f35e0fd3db80bf55c2707cae5d0f7184")!)
        
        // 2024-04-14 이것도 안되네

        let (duration, tracks) = try await asset.load(.duration, .tracks)
        
        print("duration : %@", duration)
        print("tracks : %@", tracks)
    }
    


}

