//
//  player.swift
//  takPlay
//
//  Created by 탁제원 on 4/15/24.
//

import UIKit
import AVKit

class PlayerViewController: UIViewController  {
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var playerView: UIView!
    private var player = AVPlayer()
    
    var playUrl: URL?
    
    var isPlaying: Bool = false {
        didSet {
            let imageName = isPlaying ? "pause.fill" : "play.fill"
            let image = UIImage(systemName: imageName)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            playButton.setImage(image, for: .normal)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingView()
        playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.player.pause()
    }
    
    func settingView(){
        
        isPlaying = false
        
        // 원하는 이미지 크기와 색상으로 이미지 생성
        let originalImage = UIImage(systemName: "circlebadge.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        // 원하는 크기로 이미지 리사이징
        let newSize = CGSize(width: 15, height: 15)
        let resizedImage = UIGraphicsImageRenderer(size: newSize).image { _ in
            originalImage?.draw(in: CGRect(origin: .zero, size: newSize))
        }
        self.playSlider.setThumbImage(resizedImage, for: .normal)
        
        self.playSlider.minimumTrackTintColor = .white
        self.playSlider.setValue(0, animated: false)
    }
    
    func playVideo(){
        playUrl = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        
        let item = AVPlayerItem(url: playUrl!)
        self.player.replaceCurrentItem(with: item)
        
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.playerView.bounds
        playerLayer.videoGravity = .resizeAspect
        self.playerView.layer.addSublayer(playerLayer)
        
        // 재생 상태를 확인하고, 재생 가능한 상태가 되면 재생 시간을 설정합니다.
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
        
        self.playSlider.addTarget(self, action: #selector(changeValue), for: .valueChanged)
        
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] elapsedSeconds in
            let elapsedTimeSecondsFloat = CMTimeGetSeconds(elapsedSeconds)
            let totalTimeSecondsFloat = CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
            print(elapsedTimeSecondsFloat, totalTimeSecondsFloat)
            
            // 현재 시간을 표시합니다.
            let elapsedTime = CMTimeGetSeconds(self?.player.currentTime() ?? CMTime(value: 0, timescale: 1))
            self?.runningTimeLabel.text = self?.formatTime(seconds: elapsedTime)
            
            // 슬라이더 위치를 조정합니다.
            self?.playSlider.value = Float(elapsedTime)
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            if let statusNumber = change?[.newKey] as? Int {
                let status = AVPlayerItem.Status(rawValue: statusNumber)
                if status == .readyToPlay {
                    if let item = self.player.currentItem {
                        self.playSlider.minimumValue = 0
                        self.playSlider.maximumValue = Float(CMTimeGetSeconds(item.duration))
                        self.endTimeLabel.text = formatTime(seconds: CMTimeGetSeconds(item.duration))
                    }
                }
            }
        }
    }
    
    // 시간을 포맷하는 메서드
    func formatTime(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        if let formattedString = formatter.string(from: seconds) {
            // 시간이 0으로 표시되는 경우에는 시간 부분을 없애고 반환합니다.
            if formattedString.starts(with: "00:") {
                let index = formattedString.index(formattedString.startIndex, offsetBy: 3)
                return String(formattedString[index...])
            } else {
                return formattedString
            }
        } else {
            return "00:00"
        }
    }
    
    
    @objc private func changeValue(){
        self.player.seek(to: CMTime(seconds: Double(self.playSlider.value), preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { _ in
            
        })
    }
    
    @IBAction func onTouchedPlayButton(_ sender: Any) {
        if isPlaying {
            self.player.pause()
        } else {
            self.player.play()
        }
        isPlaying = !isPlaying
    }
    
    @IBAction func onTapBackButton(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
}
