//
//  ViewController.swift
//  takPlay
//
//  Created by 탁제원 on 4/13/24.
//

import UIKit
import AVKit
import AVFoundation
import Photos
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var playbackBtn: UIButton!
    
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
    
    @IBAction func onTouchEditVideoBtn(_ sender: Any) {
        
        PHPhotoLibrary.requestAuthorization{ status in
            guard status == .authorized else {
                print("not authorized :( ")
                return
            }
        }
        
        
        let videoPicker = UIImagePickerController()
        
        videoPicker.sourceType = .photoLibrary
        videoPicker.mediaTypes = [UTType.movie.identifier]
        
        videoPicker.delegate = self
        self.present(videoPicker, animated: true, completion: nil)
    }
    
    @IBAction func onTouchEditImageBtn(_ sender: Any) {
        
        PHPhotoLibrary.requestAuthorization{ status in
            guard status == .authorized else {
                print("not authorized :( ")
                return
            }
        }
        
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [UTType.image.identifier]
        
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         // 선택된 비디오의 URL을 가져옴
         if let videoURL = info[.mediaURL] as? URL {
             
             // 비디오 선택기를 닫음
             picker.dismiss(animated: true, completion: nil)
             
             guard let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else {
                 return
             }
             
             playerViewController.modalTransitionStyle = .crossDissolve
             playerViewController.modalPresentationStyle = .fullScreen
             
             playerViewController.playUrl = videoURL
             
             self.present(playerViewController, animated: true)
         }
     }
    
}

